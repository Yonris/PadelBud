# Court Price Editing - User Guide

## How to Edit Court Prices

### Step 1: Navigate to Court Schedule
1. Open PadelBud app
2. Sign in as a court manager
3. Go to navigation menu → "My Clubs"
4. Select your club from the list

### Step 2: View Court Schedule
You'll see a list of courts with:
- Court name and icon
- Number of available time slots
- **Edit button (pencil icon)** ← NEW
- Expand/collapse arrow

Example:
```
┌─────────────────────────────────────────┐
│  🎾 Court 1                   ✏️ ⌄      │
│  12 Available                           │
└─────────────────────────────────────────┘
```

### Step 3: Click Edit Button
Tap the **pencil icon (✏️)** next to the court name to open the price editor.

### Step 4: Edit Price Dialog
A dialog will appear:
```
┌──────────────────────────────────────┐
│ Edit Price - Court 1                 │
├──────────────────────────────────────┤
│ $ [____150____]                      │
│                                      │
│ This will update the price for all   │
│ time slots of this court             │
├──────────────────────────────────────┤
│  [Cancel]              [Update]      │
└──────────────────────────────────────┘
```

### Step 5: Enter New Price
- Clear the current price
- Type the new price (e.g., 175)
- Accepts decimal values (e.g., 150.50)

### Step 6: Confirm Update
- Click **"Update"** button
- Wait for confirmation

### Step 7: Success Confirmation
You'll see a green success message:
```
✓ Price updated successfully
```

The dialog closes automatically and the UI updates to show the new price.

## Price Format

### Accepted Formats
- Whole numbers: `150`, `200`
- Decimals: `150.50`, `199.99`
- Small amounts: `1`, `10`

### NOT Accepted
- ❌ Negative numbers: `-50`
- ❌ Text: `"expensive"`
- ❌ Empty field: (leave blank)
- ❌ Invalid characters: `$150`, `150%`

## Tips & Tricks

### Tip 1: Pre-filled Current Price
The dialog shows the current price from your court's first available slot. You can:
- Edit it directly
- Or clear and type a completely new price

### Tip 2: Bulk Update
One click updates ALL time slots for that court:
- Morning slots updated ✓
- Afternoon slots updated ✓
- Evening slots updated ✓
- All in one go!

### Tip 3: Instant Update
Changes appear immediately in the app:
- No page refresh needed
- Time slots instantly show new price
- Try refreshing browser to verify in database

### Tip 4: Error Correction
If you see an error:
```
⚠️ Error: Please enter a valid price
```

This means:
- Price must be a number
- Price cannot be negative
- Price cannot be empty
- Try again with a valid price

## Troubleshooting

### Problem: Button doesn't appear
- Make sure you're viewing a court with time slots
- Scroll right if on mobile (button might be off-screen)

### Problem: Price won't update
- Check internet connection
- Verify you're the court manager
- Try clicking "Update" again

### Problem: Only some slots updated
- This shouldn't happen (batch update)
- If it does, contact support

### Problem: See someone else's price
- Sign out and sign back in
- Verify you're logged in as the correct manager
- Clear app cache if issue persists

## Keyboard Tips (Mobile/Tablet)

1. **Number keyboard**: Dialog opens number keypad for easy input
2. **Decimal point**: Tap `.` button to add decimal places
3. **Backspace**: Easy to correct typos
4. **Clear**: Select all and delete to start fresh

## What Gets Updated?

When you edit a price, ALL of these are updated:
- ✓ Morning time slots
- ✓ Afternoon time slots
- ✓ Evening time slots
- ✓ Weekday slots
- ✓ Weekend slots
- ✓ Future slots
- ✓ Past slots (if any)

Everything for that specific court is updated at once.

## Example Scenarios

### Scenario 1: Happy Hour Pricing
```
Normal price: 150
Happy hour price: 99
→ Edit price to 99 during happy hour times
```

### Scenario 2: Peak Season Increase
```
Off-season: 120
Peak season: 180
→ Create separate clubs or edit price when season changes
```

### Scenario 3: Bulk Price Adjustment
```
Current: 150
New rate: 175 (17% increase)
→ One click to update all slots
```

## Prices Are Stored In

When you update a price, it's saved in your Firestore database:
```
/time_slots/{slotId}
  - price: 150 (updated value)
  - courtId: {courtId}
  - available: true/false
  - start: 2025-12-08T18:00:00Z
  - end: 2025-12-08T19:00:00Z
```

Each time slot has its own copy of the price for easy retrieval during bookings.

## Localization

The feature supports multiple languages:
- 🇬🇧 **English**: "Edit Price", "Price updated successfully"
- 🇮🇱 **Hebrew**: "עריכת מחיר", "המחיר עודכן בהצלחה"

Language automatically switches based on app language settings.
