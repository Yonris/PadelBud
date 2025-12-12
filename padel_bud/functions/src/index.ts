import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { getDistance } from "geolib";

admin.initializeApp();
const db = admin.firestore();
const playersPerMatch = 4;

// --- Helpers ---
function convertGeoPoint(point: any) {
    if (!point) return null;
    const lat = point.latitude ?? point.lat;
    const lng = point.longitude ?? point.lng;
    if (lat == null || lng == null) return null;
    return { latitude: lat, longitude: lng };
}

function getClosestClubs(clubsSnap: FirebaseFirestore.QuerySnapshot, userLocation: any) {
    return clubsSnap.docs
        .map((doc) => {
            const club = doc.data();
            const point = convertGeoPoint(club.location);
            if (!point) return { id: doc.id, distance: Number.MAX_SAFE_INTEGER };
            const distance = getDistance(userLocation, point);
            return { id: doc.id, distance };
        })
        .sort((a, b) => a.distance - b.distance)
        .slice(0, 3)
        .map((c) => c.id);
}

async function getCourtsOfClub(clubId: string) {
    const snap = await db.collection("courts").where("clubId", "==", clubId).get();
    return snap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

async function findPlayersForClub(clubId: string, start: Date, end: Date) {
    const snap = await db
        .collection("search_requests")
        .where("dateTime", ">=", start)
        .where("dateTime", "<=", end)
        .where("closeClubs", "array-contains", clubId)
        .where("available", "==", true)
        .get();

    return snap.docs.map((d) => {
        const data = d.data();
        return {
            id: d.id,
            userId: data.userId,
            location: data.location,
            dateTime: data.dateTime,
            available: data.available,
            docRef: d,
        };
    });
}

function calculateDistance(loc1: any, loc2: any): number {
    if (!loc1 || !loc2) return Number.MAX_SAFE_INTEGER;
    return getDistance(loc1, loc2);
}

async function findMatchingTimeSlotForCourt(courtId: string, desiredTime: Date) {
    const slotsSnap = await db
        .collection("time_slots")
        .where("courtId", "==", courtId)
        .where("available", "==", true)
        .get();

    const buffer = 2 * 60 * 60 * 1000; // +/- 2 hours for START time
    const windowStart = new Date(desiredTime.getTime() - buffer);
    const windowEnd = new Date(desiredTime.getTime() + buffer);

    for (const slotDoc of slotsSnap.docs) {
        const slot = slotDoc.data();
        const slotStart = slot.start.toDate();

        // Check if slot START time falls within the window
        if (slotStart >= windowStart && slotStart <= windowEnd) {
            console.log(`⏰ Found matching time slot ${slotDoc.id} (starts at ${slotStart})`);
            return { id: slotDoc.id, ...slot };
        }
    }

    return null;
}

async function createMatch(players: any[], dateTime: Date, timeSlotId: string, courtId: string) {
    const matchRef = db.collection("matches").doc();

    const batch = db.batch();

    batch.set(matchRef, {
        userIds: players.map((p) => p.userId),
        dateTime,
        courtId,
        timeSlotId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    players.forEach((p) => {
        batch.update(db.collection("search_requests").doc(p.id), {
            available: false,
        });
    });

    players.forEach((p) => {
        const userRef = db.collection("users").doc(p.userId);
        batch.update(userRef, {
            matchId: matchRef.id,
            buddiesState: 2,
        });
    });

    batch.update(db.collection("time_slots").doc(timeSlotId), {
        available: false,
    });

    await batch.commit();
    return matchRef.id;
}

// ---------------- MAIN TRIGGER ----------------

export const onSearchRequestCreated = onDocumentCreated(
    "search_requests/{requestId}",
    async (event) => {
        const snap = event.data;
        if (!snap) return;

        const data = snap.data();
        const requestDate = data.dateTime.toDate();
        const userLocation = convertGeoPoint(data.location);
        const requestUserId = data.userId;

        console.log(`📌 New search request: ${snap.id} from user ${requestUserId}`);

        // 1. Get 3 closest clubs
        const clubsSnap = await db.collection("clubs").get();
        const closeClubs = getClosestClubs(clubsSnap, userLocation);
        console.log(`✅ Step 1 - Closest clubs: ${closeClubs}`);

        await db.collection("search_requests").doc(snap.id).update({
            closeClubs, available: true
        });

        // 2. Check time window: ±2 hours
        const windowStart = new Date(requestDate.getTime() - 2 * 60 * 60 * 1000);
        const windowEnd = new Date(requestDate.getTime() + 2 * 60 * 60 * 1000);

        for (const clubId of closeClubs) {
            console.log(`🔍 Checking club ${clubId}`);

            // 2. Find available time slots that START within ±2 hours
            const courts = await getCourtsOfClub(clubId);
            console.log(`Club ${clubId} has ${courts.length} courts`);

            let foundTimeSlot = null;
            let foundCourtId = null;

            for (const court of courts) {
                const timeSlot = await findMatchingTimeSlotForCourt(court.id, requestDate);
                if (timeSlot) {
                    foundTimeSlot = timeSlot;
                    foundCourtId = court.id;
                    break;
                }
            }

            if (!foundTimeSlot) {
                console.log(`❌ No available time slot within ±2 hours in club ${clubId}`);
                continue;
            }

            console.log(`✅ Step 2 - Found matching time slot in club ${clubId}`);

            // 3. Find other requests within ±2 hour window
            const partners = await findPlayersForClub(clubId, windowStart, windowEnd);
            
            // Filter out the current user and exclude current request
            const otherRequests = partners.filter(p => p.userId !== requestUserId && p.id !== snap.id);
            console.log(`✅ Step 3 - Found ${otherRequests.length} other requests in ±2 hour window`);

            if (otherRequests.length < playersPerMatch - 1) {
                console.log(`❌ Not enough partners (need ${playersPerMatch - 1}, found ${otherRequests.length})`);
                continue;
            }

            // 4. Get 3 closest requests
            const closestRequests = otherRequests
                .map(req => {
                    const reqLocation = convertGeoPoint(req.location);
                    const distance = calculateDistance(userLocation, reqLocation);
                    return { ...req, distance };
                })
                .sort((a, b) => a.distance - b.distance)
                .slice(0, playersPerMatch - 1);

            console.log(`✅ Step 4 - Selected ${closestRequests.length} closest requests`);

            // Create match with current player + 3 closest
            const matchPlayers = [
                { id: snap.id, userId: requestUserId },
                ...closestRequests
            ];

            const matchId = await createMatch(
                matchPlayers,
                requestDate,
                foundTimeSlot.id,
                foundCourtId!
            );

            console.log(`✅ Match created: ${matchId}`);
            return; // stop after match created
        }

        console.log("⚠ No match could be created for this search request.");
     }
);

// Helper function to generate time slots for a court
async function generateTimeSlotsForCourt(courtId: string, daysAhead: number = 7) {
    try {
        const courtDoc = await db.collection("courts").doc(courtId).get();
        if (!courtDoc.exists) {
            console.log(`Court ${courtId} not found`);
            return 0;
        }

        const court = courtDoc.data();
        if (!court || !court.clubId) {
            console.log(`Court ${courtId} has no clubId`);
            return 0;
        }

        // Get the club to fetch the schedule
        const clubDoc = await db.collection("clubs").doc(court.clubId).get();
        if (!clubDoc.exists) {
            console.log(`Club ${court.clubId} not found`);
            return 0;
        }

        const club = clubDoc.data();
        if (!club || !club.schedule) {
            console.log(`Club ${court.clubId} has no schedule`);
            return 0;
        }

        let slotsCreated = 0;
        const now = new Date();

        for (let dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
            const date = new Date(now);
            date.setDate(date.getDate() + dayOffset);
            date.setHours(0, 0, 0, 0);

            const weekdayName = [
                "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday",
                "Sunday",
            ][date.getDay() === 0 ? 6 : date.getDay() - 1];

            const daySched = club.schedule[weekdayName];
            if (!daySched || daySched.closed) {
                continue;
            }

            const startTime = daySched.start;
            const endTime = daySched.end;

            if (!startTime || !endTime) {
                continue;
            }

            // Parse time strings (format: "HH:mm")
            const [startHour, startMin] = startTime.split(":").map(Number);
            const [endHour, endMin] = endTime.split(":").map(Number);

            const startMinutes = startHour * 60 + startMin;
            const endMinutes = endHour * 60 + endMin;
            const gameDuration = court.gameDuration || 60;

            // Generate time slots for this day
            for (let t = startMinutes; t + gameDuration <= endMinutes; t += gameDuration) {
                const slotStart = new Date(date);
                slotStart.setHours(Math.floor(t / 60), t % 60, 0, 0);

                const slotEnd = new Date(slotStart);
                slotEnd.setMinutes(slotEnd.getMinutes() + gameDuration);

                // Create a deterministic document ID based on court, date, and time
                const slotStartISO = slotStart.toISOString().replace(/[:.]/g, "-");
                const slotId = `${courtId}_${slotStartISO}`;

                // Check if slot already exists
                const existingDoc = await db.collection("time_slots").doc(slotId).get();

                if (!existingDoc.exists) {
                    // Create new slot
                    await db.collection("time_slots").doc(slotId).set({
                        courtId: courtId,
                        start: slotStart,
                        end: slotEnd,
                        available: true,
                        buddies: 0,
                        price: 25, // Default price, can be customized
                    });
                    slotsCreated++;
                }
            }
        }

        return slotsCreated;
    } catch (error) {
        console.error(`Error generating time slots for court ${courtId}:`, error);
        return 0;
    }
}

// TRIGGER: When a new court is created, generate initial time slots
export const onCourtCreated = onDocumentCreated(
    "courts/{courtId}",
    async (event) => {
        const snap = event.data;
        if (!snap) return;

        const courtId = snap.id;
        console.log(`🏸 New court created: ${courtId}. Generating initial time slots...`);

        try {
            const slotsCreated = await generateTimeSlotsForCourt(courtId, 7);
            console.log(`✅ Generated ${slotsCreated} time slots for court ${courtId}`);
        } catch (error) {
            console.error(`❌ Error creating time slots for court ${courtId}:`, error);
            throw error;
        }
    }
);

// SCHEDULED FUNCTION: Generate daily time slots for all courts
export const generateDailyTimeSlots = onSchedule(
    { schedule: "every day 00:01", timeZone: "UTC" },
    async (context) => {
        try {
            console.log("Starting daily time slot generation...");

            const courtsSnap = await db.collection("courts").get();
            if (courtsSnap.empty) {
                console.log("No courts found");
                return;
            }

            let totalSlotsCreated = 0;

            for (const courtDoc of courtsSnap.docs) {
                const courtId = courtDoc.id;
                const slotsCreated = await generateTimeSlotsForCourt(courtId, 7);
                totalSlotsCreated += slotsCreated;
            }

            console.log(`Daily time slot generation complete. Created ${totalSlotsCreated} slots.`);
        } catch (error) {
            console.error("Error generating daily time slots:", error);
            throw error;
        }
    }
);
