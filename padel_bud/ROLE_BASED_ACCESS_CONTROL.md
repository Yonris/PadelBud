# Role-Based Access Control Implementation

## Summary
Implemented role-based access control so that each court manager can only see their own clubs and courts.

## Changes Made

### 1. **Models** 
Added `managerId` field to track ownership:
- `lib/models/club_model.dart`: Added `String managerId` field
- `lib/models/court_model.dart`: Added `String managerId` field

Both models now include:
- Constructor parameter for `managerId` (required)
- Serialization in `toJson()`
- Deserialization in `fromDocument()` with fallback to empty string for backward compatibility

### 2. **Repositories**
Added filtered query methods:
- `lib/repositories/club_repository.dart`: Added `getClubsByManager(String managerId)` method
- `lib/repositories/court_repository.dart`: Added `getCourtsByManager(String managerId)` method

Both methods use Firestore `where()` clause to filter by `managerId`.

### 3. **Pages**

#### Club Manager Dashboard (`lib/presentation/pages/club_manager_dashboard_page.dart`)
- Changed from `StatefulWidget` to `ConsumerStatefulWidget` (to access user provider)
- Updated `_loadClubs()` to:
  - Get current user ID from auth provider
  - Call `getClubsByManager(userId)` instead of `getClubs()`
  - Show only clubs owned by the current manager

#### Club Manager Court Schedule (`lib/presentation/pages/club_manager_court_schedule_page.dart`)
- Changed from `StatefulWidget` to `ConsumerStatefulWidget`
- Updated `_loadData()` to:
  - Get current user ID from auth provider
  - Call `getCourtsByManager(userId)` instead of `getCourts()`
  - Filter courts by both club ID and manager ID

#### Add Court Page (`lib/presentation/pages/add_court_page.dart`)
- Updated `_submit()` method to:
  - Capture current user ID: `final userId = ref.read(authProvider).user?.uid ?? '';`
  - Pass `managerId: userId` when creating `ClubModel`
  - Pass `managerId: userId` when creating `CourtModel` instances

## Implementation Details

### Manager ID Storage
When a court manager creates a club, their user ID is stored as `managerId` in the club document. All courts under that club also store the same `managerId`. This enables:
- Direct filtering by manager ID in queries
- Easy verification of ownership
- Support for future features (analytics, reports by manager)

### Backward Compatibility
The `fromDocument()` methods use fallback values (`?? ''`) to handle documents that don't yet have `managerId` set. This allows existing data to be read safely.

### Security Note
Client-side filtering is implemented here. For production, add Firestore security rules:
```
match /clubs/{document=**} {
  allow read, write: if request.auth.uid == resource.data.managerId;
}
match /courts/{document=**} {
  allow read, write: if request.auth.uid == resource.data.managerId;
}
```

## Testing
When testing, ensure:
1. Create a club as User A - it should have User A's ID as `managerId`
2. Switch to User B - the club created by User A should NOT be visible
3. Create a club as User B - only User B should see their own clubs
4. Same logic applies to courts

## Migration Notes
Existing clubs and courts in Firestore without a `managerId` field will:
- Load with empty string `managerId` (due to fallback in `fromDocument()`)
- Not appear in filtered queries (since empty string won't match user IDs)
- Need to be manually updated or re-created with proper `managerId`

To migrate existing data, run a Firestore script to set `managerId` based on who created them, or have managers re-create their clubs/courts.
