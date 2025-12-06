# Complete Translations for PadelBud

## Overview
The app now has complete bilingual support for **English** and **Hebrew** using Flutter's built-in localization system (`flutter_localizations` and the `intl` package).

## What Was Added

### 1. **Expanded Localization Strings** (150+ strings)
The `AppLocalizations` abstract class now includes comprehensive translations for:

#### **Basic Navigation & App** (6 strings)
- appTitle, home, back, next, skip, done

#### **Authentication** (12 strings)
- login, logout, email, password, signUp, forgotPassword, resetPassword, phoneNumber, selectState, countryCode, verifyPhone, verificationCode, resendCode, googleSignIn, appleSignIn

#### **Navigation Tabs** (7 strings)
- bookCourt, myCourts, myClubs, schedule, profile, settings, language

#### **Role Selection** (4 strings)
- selectRole, playerRole, clubOwnerRole, roleDescription

#### **Match/Game Related** (13 strings)
- matchFound, matchDetails, players, location, time, date, duration, level, court, club, joinMatch, leaveMatch, score, result, matchStatus, upcomingMatches, pastMatches, activeMatches

#### **Club Management** (15 strings)
- createClub, clubName, clubLocation, clubDescription, courtName, courtType, numberOfCourts, clubAddress, clubPhone, clubEmail, openingHours, closingHours, pricePerHour, surfaceType, lighting, facilities, rules

#### **Forms & Actions** (11 strings)
- save, saveChanges, cancel, delete, edit, add, remove, ok, close, confirm, confirmDelete, deleteConfirmation

#### **Messages** (10 strings)
- error, success, loading, noData, noCourts, noMatches, noClubs, tryAgain, errorLoadingData, connectionError

#### **Court Status** (4 strings)
- fullCourt, availableCourt, bookingClosed, comingSoon

#### **Photos & Media** (12 strings)
- uploadPhoto, selectPhoto, camera, gallery, changePhoto, removePhoto, clubPhoto, playerPhoto, uploadingPhoto, photoUploadSuccess, photoUploadFailed, selectPhotoFromCamera, selectPhotoFromGallery

#### **Search & Filter** (10 strings)
- searchClubs, allClubs, nearbyClubs, search, filter, sortBy, distance, km, rating, reviews

#### **Time Related** (13 strings)
- hour, hours, minute, minutes, second, day, days, today, tomorrow, yesterday, week, month

#### **Social** (18 strings)
- buddies, addBuddy, removeBuddy, viewProfile, editProfile, myProfile, firstName, lastName, age, skill, joinedDate, friends, followers, following, statistics, matchesPlayed, wins, losses, bio

#### **Settings** (12 strings)
- preferences, notifications, privacy, about, version, contactUs, feedback, terms, privacyPolicy, darkMode, lightMode

#### **Errors & Validations** (9 strings)
- fieldRequired, invalidEmail, passwordTooShort, passwordMismatch, invalidPhoneNumber, userNotFound, invalidCredentials, accountExists, somethingWentWrong

#### **Payment & Booking** (14 strings)
- payment, price, total, paymentMethod, creditCard, debitCard, paypal, apple, google, bookNow, bookedSuccessfully, bookingCancelled, refund, receipt

#### **Player Levels** (4 strings)
- beginner, intermediate, advanced, professional

#### **Days of Week** (7 strings)
- monday, tuesday, wednesday, thursday, friday, saturday, sunday

#### **Months** (12 strings)
- january, february, march, april, may, june, july, august, september, october, november, december

## File Structure

```
lib/
  core/
    app_localizations.dart          # Main localization file (1150 lines)
    app_localizations_delegate.dart # Delegate for loading translations
    app_localizations_ext.dart      # Extension for easy access
```

## How to Use

### In Widgets
Access translations using the extension method:

```dart
import 'package:padel_bud/core/app_localizations_ext.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.bookCourt); // Automatically uses current locale
  }
}
```

### Change Language
The app uses a `localeProvider` (Riverpod) to manage the current locale:

```dart
// In any widget with WidgetRef
ref.read(localeProvider.notifier).state = Locale('he'); // Switch to Hebrew
ref.read(localeProvider.notifier).state = Locale('en'); // Switch to English
```

## Supported Languages
- **English** (en) - AppLocalizationsEn
- **Hebrew** (he) - AppLocalizationsHe

## Integration Points

The localization is already integrated in:
1. **app.dart** - Configured with localization delegates and supported locales
2. **providers/locale_provider.dart** - Manages the current language setting
3. **All screens** - Can use `context.l10n.stringKey` to access translations

## HTML/RTL Support
Hebrew is an RTL (Right-to-Left) language. The app configuration in `app.dart` already includes:
- `GlobalWidgetsLocalizations.delegate` - Handles RTL/LTR direction
- Proper locale configuration for both languages

## Testing Localization

To test the translations:
1. Run the app in both English and Hebrew
2. Change the device language or use the language selector in settings
3. All UI text should update automatically

## Adding New Strings

To add new localization strings:
1. Add the abstract getter to the `AppLocalizations` class
2. Add the English translation to `AppLocalizationsEn`
3. Add the Hebrew translation to `AppLocalizationsHe`
4. Use it in widgets: `context.l10n.newStringKey`

## Example
```dart
// Add to AppLocalizations abstract class
String get newFeature;

// Add to AppLocalizationsEn
@override
String get newFeature => 'New Feature';

// Add to AppLocalizationsHe
@override
String get newFeature => 'תכונה חדשה';

// Use in widget
Text(context.l10n.newFeature)
```

## Notes
- All 150+ strings are fully translated in both English and Hebrew
- The system uses Flutter's standard localization approach
- Both languages are fully supported with proper RTL handling for Hebrew
- Easy to extend with additional languages in the future
