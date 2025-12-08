# Testing Role-Based Access Control

## Test Cases

### Test 1: Court Manager A Only Sees Their Own Clubs
1. Sign in as User A (court manager role)
2. Navigate to "My Clubs" dashboard
3. Create a club named "Club A"
4. Verify "Club A" appears in the dashboard
5. Sign out

### Test 2: Court Manager B Cannot See Manager A's Clubs
1. Sign in as User B (court manager role) 
2. Navigate to "My Clubs" dashboard
3. Verify "Club A" (created by User A) does NOT appear
4. Create a club named "Club B"
5. Verify only "Club B" appears
6. Sign out

### Test 3: Court Manager A Still Only Sees Their Club
1. Sign back in as User A
2. Navigate to "My Clubs" dashboard
3. Verify only "Club A" appears
4. "Club B" should NOT be visible
5. Sign out

### Test 4: Courts Are Also Filtered by Manager
1. Sign in as User A
2. Navigate to "Club A" courts schedule
3. Create 3 courts
4. Verify all 3 courts appear in the schedule
5. Navigate back and sign out

### Test 5: Court Manager B's Courts Are Separate
1. Sign in as User B
2. Navigate to "Club B" courts schedule
3. Create 2 courts
4. Verify only the 2 new courts appear (NOT User A's 3 courts)
5. Sign out

### Test 6: Court Manager A's Courts Still Separate
1. Sign in as User A
2. Navigate to "Club A" courts schedule
3. Verify the original 3 courts still appear
4. User B's courts should NOT be visible
5. Sign out

## Database Verification

To verify data in Firestore:
1. Go to Firebase Console → Firestore Database
2. Check `/clubs` collection:
   - Each club document should have a `managerId` field
   - The value should match the UID of the creating user
3. Check `/courts` collection:
   - Each court document should have a `managerId` field
   - The value should match the UID of the creating manager

## Edge Cases

### Missing managerId
- If a document doesn't have `managerId` set:
  - It will default to empty string in `fromDocument()`
  - It won't appear in any manager's filtered view (good for security)
  - This might happen for old data pre-implementation

### Null User ID
- If user is not logged in:
  - `userId` will be null
  - Method returns early without loading any clubs/courts
  - Empty view is shown with loading spinner

### Multiple Managers (Future)
- Current implementation: 1 manager per club
- To support multiple managers per club in future:
  - Change `managerId: String` to `managerIds: List<String>`
  - Update queries to use `array-contains`
  - Update UI to show multi-manager clubs
