# User Role System - Implementation Guide

## Overview
The app now supports two user roles: **Players** and **Court Managers**.

## Changes Made

### 1. **User Model** (`lib/models/user_model.dart`)
Added new fields:
- `role: UserRole` - Enum defining the user's role (player or courtManager)
- `roleSelected: bool` - Tracks if the user has completed role selection

```dart
enum UserRole { player, courtManager }
```

### 2. **User Provider** (`lib/providers/user_provider.dart`)
Updated `UserState` with:
- `role` field
- `roleSelected` field
- `setUserRole()` method to update user role

### 3. **User Repository** (`lib/repositories/user_repository.dart`)
Updated `updateUserData()` method to handle role and roleSelected fields

### 4. **New Role Selection Page** (`lib/presentation/pages/role_selection_page.dart`)
Beautiful UI for users to select their role during signup:
- Player: Find courts and book with other players
- Court Manager: Manage courts and bookings

### 5. **Updated Phone Input Page** (`lib/presentation/pages/phone_input_page.dart`)
Modified to redirect users based on role selection:
- If role selected → Main Navigation
- If not → Role Selection Page

## User Flow

```
Login (Phone) 
    ↓
Verify SMS Code
    ↓
Role Selection (NEW)
    ↓
Main Navigation
```

## Firestore Schema Update

User documents now include:
```json
{
  "id": "user_id",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "phoneNumber": "+972...",
  "role": "player",          // NEW: "player" or "courtManager"
  "roleSelected": true,      // NEW: Boolean flag
  "...other fields"
}
```

## Future Implementation

### For Players:
- Browse courts by distance
- Book time slots
- Find buddies for matches
- View bookings

### For Court Managers:
- Manage court information
- View bookings
- Manage time slots
- View analytics

## API Usage

### Setting User Role
```dart
// In any ConsumerWidget or ConsumerState
await ref.read(userProvider.notifier).setUserRole(UserRole.player);
```

### Checking User Role
```dart
final userRole = ref.watch(userProvider).role;

if (userRole == UserRole.courtManager) {
  // Show court manager features
} else {
  // Show player features
}
```

### Checking if Role Selected
```dart
final isRoleSelected = ref.watch(userProvider).roleSelected;

if (!isRoleSelected) {
  // Redirect to role selection
}
```

## Next Steps

1. Create role-specific navigation/dashboards
2. Add role-based features for court managers
3. Add role-based features for players
4. Set Firestore security rules based on roles
5. Add role management in admin panel (if needed)
