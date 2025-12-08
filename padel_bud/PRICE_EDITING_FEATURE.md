# Court Price Editing Feature

## Overview
Court managers can now edit prices for their courts. When a manager edits the price, it updates the price for all time slots associated with that court.

## Implementation Details

### 1. **TimeSlotRepository** (`lib/repositories/time_slot_repository.dart`)
Added new method:
- `updateCourtPrices(String courtId, double newPrice)` 
  - Uses Firestore batch operations to atomically update all time slots for a court
  - Updates all documents with matching `courtId` in the `time_slots` collection
  - Sets the new price value for each matching slot

### 2. **Club Manager Court Schedule Page** (`lib/presentation/pages/club_manager_court_schedule_page.dart`)
Added price editing UI:
- **Edit Price Button**: Added an `IconButton` with `Icons.edit_outlined` in the court card header
  - Appears next to the court name
  - Styled with green color matching the theme
  - Tappable without conflicting with expand/collapse behavior

- **`_showEditPriceDialog()` method**: 
  - Shows an `AlertDialog` when edit button is tapped
  - Contains a `TextField` for entering the new price
  - Pre-fills with the current price from the first time slot
  - Shows a warning message: "This will update the price for all time slots of this court"
  - Provides Cancel and Update buttons

- **`_updateCourtPrice()` method**:
  - Validates the entered price (must be a valid number >= 0)
  - Calls `updateCourtPrices()` in the repository
  - Updates local state (TimeSlotModel objects)
  - Shows success/error snackbars
  - Closes the dialog automatically

### 3. **Localization** (`lib/core/app_localizations.dart`)
Added new localization strings:
- `editPrice`: "Edit Price" (En) / "עריכת מחיר" (He)
- `enterValidPrice`: "Please enter a valid price" (En) / "אנא הזן מחיר תקף" (He)
- `priceUpdated`: "Price updated successfully" (En) / "המחיר עודכן בהצלחה" (He)
- `willUpdateAllSlots`: "This will update the price for all time slots of this court" (En) / "פעולה זו תעדכן את המחיר לכל משבצות הזמן של המגרש הזה" (He)
- `update`: "Update" (En) / "עדכן" (He)

## User Workflow

1. Court manager navigates to "My Clubs" → selects a club
2. Views the court schedule with all time slots
3. Sees an edit icon button next to each court name
4. Taps the edit button to open the price editor dialog
5. Enters a new price (decimal values allowed)
6. Confirms with the "Update" button
7. Dialog closes and a success message appears
8. All time slots for that court are updated with the new price
9. UI immediately reflects the change

## Technical Details

### Batch Operations
Uses Firestore batch operations for efficiency:
- Fetches all time slots for the court in one query
- Updates all slots atomically in one batch commit
- Prevents partial updates if an error occurs

### Local State Management
Updates local `_courtTimeSlots` map immediately:
- Updates TimeSlotModel price in memory
- Calls `setState()` to re-render the UI
- Shows prices to user instantly (no page refresh needed)

### Validation
Validates prices:
- Must be parseable as a double
- Must be >= 0 (no negative prices)
- Shows error message if validation fails
- Dialog remains open for user to correct input

### Error Handling
Catches and displays errors:
- Repository errors are shown in snackbar
- Dialog closes even on error
- User can retry immediately

## Database Changes
No schema changes required. Existing `TimeSlotModel` already has a `price: double` field.

## Future Enhancements
1. **Bulk Price Updates**: Update prices for multiple courts at once
2. **Price History**: Track price changes over time
3. **Scheduled Price Changes**: Set prices to change at specific dates
4. **Discounts**: Apply percentage/fixed discounts
5. **Dynamic Pricing**: Different prices based on time of day, day of week, or demand
6. **Club-Level Price**: Update all courts in a club with one action
7. **Audit Trail**: Log who changed prices and when

## Testing
To test the feature:
1. Sign in as a court manager
2. Go to "My Clubs" and select a club
3. View the court schedule
4. Click the edit icon next to a court name
5. Enter a new price (e.g., 150)
6. Click "Update"
7. Verify the success message appears
8. Verify the price is updated in the time slots list
9. Refresh the page to verify the price persists in Firestore

## Security Note
Currently client-side only. For production, add Firestore security rules:
```
match /time_slots/{document=**} {
  allow write: if request.auth.uid == get(/databases/$(database)/documents/courts/$(get(resource.data.courtId).data.managerId)).data.managerId;
}
```

Or simpler: Verify manager ownership before allowing price updates in the app logic.
