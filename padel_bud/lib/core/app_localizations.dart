import 'package:flutter/material.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'he') {
      return AppLocalizationsHe();
    }
    return AppLocalizationsEn();
  }

  // Basic Navigation & App
  String get appTitle;
  String get home;
  String get back;
  String get next;
  String get skip;
  String get done;

  // Authentication
  String get login;
  String get logout;
  String get email;
  String get password;
  String get signUp;
  String get forgotPassword;
  String get resetPassword;
  String get phoneNumber;
  String get selectState;
  String get countryCode;
  String get verifyPhone;
  String get verificationCode;
  String get resendCode;
  String get googleSignIn;
  String get appleSignIn;
  String get booked;

  // Navigation Tabs
  String get book;
  String get bookCourt;
  String get myCourts;
  String get myClubs;
  String get schedule;
  String get profile;
  String get settings;
  String get language;

  // Role Selection
  String get selectRole;
  String get playerRole;
  String get clubOwnerRole;
  String get roleDescription;

  // Match/Game Related
  String get matchFound;
  String get matchDetails;
  String get players;
  String get location;
  String get time;
  String get date;
  String get duration;
  String get level;
  String get court;
  String get club;
  String get joinMatch;
  String get leaveMatch;
  String get score;
  String get result;
  String get matchStatus;
  String get upcomingMatches;
  String get pastMatches;
  String get activeMatches;
  // Club Management
  String get createClub;
  String get clubName;
  String get clubLocation;
  String get clubDescription;
  String get courtName;
  String get courtType;
  String get numberOfCourts;
  String get courts;
  String get clubAddress;
  String get clubPhone;
  String get clubEmail;
  String get openingHours;
  String get closingHours;
  String get pricePerHour;
  String get surfaceType;
  String get lighting;
  String get facilities;
  String get rules;

  // Forms & Actions
  String get save;
  String get saveChanges;
  String get cancel;
  String get delete;
  String get edit;
  String get add;
  String get remove;
  String get ok;
  String get close;
  String get confirm;
  String get confirmDelete;
  String get deleteConfirmation;

  // Messages
  String get error;
  String get success;
  String get loading;
  String get noData;
  String get noCourts;
  String get noMatches;
  String get noClubs;
  String get tryAgain;
  String get errorLoadingData;
  String get connectionError;

  // Court Status
  String get fullCourt;
  String get availableCourt;
  String get bookingClosed;
  String get comingSoon;

  // Photos & Media
  String get uploadPhoto;
  String get selectPhoto;
  String get camera;
  String get gallery;
  String get changePhoto;
  String get removePhoto;
  String get clubPhoto;
  String get playerPhoto;
  String get uploadingPhoto;
  String get photoUploadSuccess;
  String get photoUploadFailed;
  String get selectPhotoFromCamera;
  String get selectPhotoFromGallery;

  // Search & Filter
  String get searchClubs;
  String get allClubs;
  String get nearbyClubs;
  String get search;
  String get filter;
  String get sortBy;
  String get distance;
  String get km;
  String get rating;
  String get reviews;

  // Time Related
  String get hour;
  String get hours;
  String get minute;
  String get minutes;
  String get second;
  String get day;
  String get days;
  String get today;
  String get tomorrow;
  String get yesterday;
  String get week;
  String get month;

  // Social
  String get buddies;
  String get addBuddy;
  String get removeBuddy;
  String get viewProfile;
  String get editProfile;
  String get myProfile;
  String get firstName;
  String get lastName;
  String get age;
  String get skill;
  String get joinedDate;
  String get friends;
  String get followers;
  String get following;
  String get statistics;
  String get matchesPlayed;
  String get wins;
  String get losses;
  String get bio;

  // Settings
  String get preferences;
  String get notifications;
  String get privacy;
  String get about;
  String get version;
  String get contactUs;
  String get feedback;
  String get terms;
  String get privacyPolicy;
  String get darkMode;
  String get lightMode;

  // Errors & Validations
  String get fieldRequired;
  String get invalidEmail;
  String get passwordTooShort;
  String get passwordMismatch;
  String get invalidPhoneNumber;
  String get userNotFound;
  String get invalidCredentials;
  String get accountExists;
  String get somethingWentWrong;

  // Payment & Booking
  String get payment;
  String get price;
  String get total;
  String get paymentMethod;
  String get creditCard;
  String get debitCard;
  String get paypal;
  String get apple;
  String get google;
  String get bookNow;
  String get bookedSuccessfully;
  String get bookingCancelled;
  String get refund;
  String get receipt;
  String get completePayment;


  // Player Levels
  String get beginner;
  String get intermediate;
  String get advanced;
  String get professional;

  // Days of Week
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;

  // Months
  String get january;
  String get february;
  String get march;
  String get april;
  String get may;
  String get june;
  String get july;
  String get august;
  String get september;
  String get october;
  String get november;
  String get december;

  // Additional UI Strings
  String get waitingForLocation;
  String get noClubsAvailable;
  String get errorBooking;
  String get bookingSuccess;
  String get thisSlotNotAvailable;
  String get failedToUploadImage;
  String get errorUploadingImage;
  String get selectLanguage;
  String get englishLanguage;
  String get hebrewLanguage;
  String get notAvailable;
  String get noAvailableSlots;
  String get pickALocation;
  String get appDescription;
  String get continueWithPhone;
  String get termsAndPrivacy;
  String get joinThousands;

  // Additional Missing Strings
  String get welcomeToPadelBud;
  String get signInWithYourPhoneNumber;
  String get countryState;
  String get verificationCodeTitle;
  String get enterSixDigitCode;
  String get pleaseEnterPhoneNumber;
  String get sendVerificationCode;
  String get weWillSendCode;
  String get pleaseEnterValidCode;
  String get hintPhoneNumber;
  String get selectPaymentMethod;
  String get refundAmount;
  String get myCubs;
  String get noClubsCreated;
  String get noMatchFound;
  String get findingPlayers;
  String get searchingForPlayers;
  String get matchingYouWithPlayers;
  String get cancelSearch;
  String get paymentSuccessful;
  String get paymentFailed;
  String get confirmPayment;
  String get amount;

  // Club Creation & Management
  String get clubInformation;
  String get addClubPhoto;
  String get tapToChangePhoto;
  String get tapToUploadPhoto;
  String get operatingHours;
  String get createCourt;
  String get markAsClosed;
  String get closed;
  String get notSet;
  String get startTime;
  String get endTime;
  String get copyToAllDays;
  String get failedToAddClub;
  String get clubAddedSuccessfully;
  String get gameDuration;
  String get pricePerGame;
  String get enterPrice;
  String get enterClubName;
  String get enterNumberOfCourts;
  String get validNumber;
  String get clubAddedSuccess;

  // Buddies/Find Match
  String get findBuddies;
  String get whenWantToPlay;
  String get selectDateAndTimeToFindPlayers;
  String get selectDate;
  String get selectTime;
  String get findMatch;
  String get noPlayersFound;
  String get acceptMatch;

  String get available;

  // Price Management
  String get editPrice;
  String get enterValidPrice;
  String get priceUpdated;
  String get willUpdateAllSlots;
  String get update;

  // Currency Management
  String get changeCurrency;
  String get currencyUpdated;
  String get selectCurrency;
  
  // Court Schedule Page
  String get clubDetails;
  String get courtSchedule;
  String get editClubDetails;
  String get setPricesForCourts;
  String get currentPrice;
  String get noCourtsFound;
  String get currency;
  String get pricing;

}

class AppLocalizationsEn extends AppLocalizations {
  // Basic Navigation & App
  @override
  String get appTitle => 'PadelBud';
  @override
  String get home => 'Home';
  @override
  String get back => 'Back';
  @override
  String get next => 'Next';
  @override
  String get skip => 'Skip';
  @override
  String get done => 'Done';

  // Authentication
  @override
  String get login => 'Login';
  @override
  String get logout => 'Logout';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get signUp => 'Sign Up';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get resetPassword => 'Reset Password';
  @override
  String get phoneNumber => 'Phone Number';
  @override
  String get selectState => 'Select State';
  @override
  String get countryCode => 'Country Code';
  @override
  String get verifyPhone => 'Verify Phone';
  @override
  String get verificationCode => 'Verification Code';
  @override
  String get resendCode => 'Resend Code';
  @override
  String get googleSignIn => 'Sign in with Google';
  @override
  String get appleSignIn => 'Sign in with Apple';

  // Navigation Tabs
  @override
  String get bookCourt => 'Book a Court';
  @override
  String get myCourts => 'My Courts';
  @override
  String get myClubs => 'My Clubs';
  @override
  String get schedule => 'Schedule';
  @override
  String get profile => 'Profile';
  @override
  String get settings => 'Settings';
  @override
  String get language => 'Language';

  // Role Selection
  @override
  String get selectRole => 'Select Role';
  @override
  String get playerRole => 'Player';
  @override
  String get clubOwnerRole => 'Club Owner';
  @override
  String get roleDescription => 'Choose your role to get started';

  // Match/Game Related
  @override
  String get matchFound => 'Match Found';
  @override
  String get matchDetails => 'Match Details';
  @override
  String get players => 'Players';
  @override
  String get location => 'Location';
  @override
  String get time => 'Time';
  @override
  String get date => 'Date';
  @override
  String get duration => 'Duration';
  @override
  String get level => 'Level';
  @override
  String get court => 'Court';
  @override
  String get club => 'Club';
  @override
  String get joinMatch => 'Join Match';
  @override
  String get leaveMatch => 'Leave Match';
  @override
  String get score => 'Score';
  @override
  String get result => 'Result';
  @override
  String get matchStatus => 'Match Status';
  @override
  String get upcomingMatches => 'Upcoming Matches';
  @override
  String get pastMatches => 'Past Matches';
  @override
  String get activeMatches => 'Active Matches';

  // Club Management
  @override
  String get createClub => 'Create Club';
  @override
  String get clubName => 'Club Name';
  @override
  String get clubLocation => 'Club Location';
  @override
  String get clubDescription => 'Club Description';
  @override
  String get courtName => 'Court Name';
  @override
  String get courtType => 'Court Type';
  @override
  String get numberOfCourts => 'Number of Courts';
  @override
  String get courts => 'Courts';
  @override
  String get clubAddress => 'Club Address';
  @override
  String get clubPhone => 'Club Phone';
  @override
  String get clubEmail => 'Club Email';
  @override
  String get openingHours => 'Opening Hours';
  @override
  String get closingHours => 'Closing Hours';
  @override
  String get pricePerHour => 'Price per Hour';
  @override
  String get surfaceType => 'Surface Type';
  @override
  String get lighting => 'Lighting';
  @override
  String get facilities => 'Facilities';
  @override
  String get rules => 'Rules';

  // Forms & Actions
  @override
  String get save => 'Save';
  @override
  String get saveChanges => 'Save Changes';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get add => 'Add';
  @override
  String get remove => 'Remove';
  @override
  String get ok => 'OK';
  @override
  String get close => 'Close';
  @override
  String get confirm => 'Confirm';
  @override
  String get confirmDelete => 'Confirm Delete';
  @override
  String get deleteConfirmation => 'Are you sure you want to delete?';

  // Messages
  @override
  String get error => 'Error';
  @override
  String get success => 'Success';
  @override
  String get loading => 'Loading...';
  @override
  String get noData => 'No Data';
  @override
  String get noCourts => 'No Courts Available';
  @override
  String get noMatches => 'No Matches Found';
  @override
  String get noClubs => 'No Clubs Found';
  @override
  String get tryAgain => 'Try Again';
  @override
  String get errorLoadingData => 'Error Loading Data';
  @override
  String get connectionError => 'Connection Error';

  // Court Status
  @override
  String get fullCourt => 'Full';
  @override
  String get availableCourt => 'Available';
  @override
  String get bookingClosed => 'Booking Closed';
  @override
  String get comingSoon => 'Coming Soon';

  // Photos & Media
  @override
  String get uploadPhoto => 'Upload Photo';
  @override
  String get selectPhoto => 'Select Photo';
  @override
  String get camera => 'Camera';
  @override
  String get gallery => 'Gallery';
  @override
  String get changePhoto => 'Change Photo';
  @override
  String get removePhoto => 'Remove Photo';
  @override
  String get clubPhoto => 'Club Photo';
  @override
  String get playerPhoto => 'Player Photo';
  @override
  String get uploadingPhoto => 'Uploading Photo...';
  @override
  String get photoUploadSuccess => 'Photo uploaded successfully';
  @override
  String get photoUploadFailed => 'Failed to upload photo';
  @override
  String get selectPhotoFromCamera => 'Take a photo';
  @override
  String get selectPhotoFromGallery => 'Choose from gallery';

  // Search & Filter
  @override
  String get searchClubs => 'Search Clubs';
  @override
  String get allClubs => 'All Clubs';
  @override
  String get nearbyClubs => 'Nearby Clubs';
  @override
  String get search => 'Search';
  @override
  String get filter => 'Filter';
  @override
  String get sortBy => 'Sort by';
  @override
  String get distance => 'Distance';
  @override
  String get km => 'km';
  @override
  String get rating => 'Rating';
  @override
  String get reviews => 'Reviews';

  // Time Related
  @override
  String get hour => 'hour';
  @override
  String get hours => 'hours';
  @override
  String get minute => 'minute';
  @override
  String get minutes => 'minutes';
  @override
  String get second => 'second';
  @override
  String get day => 'day';
  @override
  String get days => 'days';
  @override
  String get today => 'Today';
  @override
  String get tomorrow => 'Tomorrow';
  @override
  String get yesterday => 'Yesterday';
  @override
  String get week => 'This Week';
  @override
  String get month => 'This Month';

  // Social
  @override
  String get buddies => 'Buddies';
  @override
  String get addBuddy => 'Add Buddy';
  @override
  String get removeBuddy => 'Remove Buddy';
  @override
  String get viewProfile => 'View Profile';
  @override
  String get editProfile => 'Edit Profile';
  @override
  String get myProfile => 'My Profile';
  @override
  String get firstName => 'First Name';
  @override
  String get lastName => 'Last Name';
  @override
  String get age => 'Age';
  @override
  String get skill => 'Skill Level';
  @override
  String get joinedDate => 'Joined';
  @override
  String get friends => 'Friends';
  @override
  String get followers => 'Followers';
  @override
  String get following => 'Following';
  @override
  String get statistics => 'Statistics';
  @override
  String get matchesPlayed => 'Matches Played';
  @override
  String get wins => 'Wins';
  @override
  String get losses => 'Losses';
  @override
  String get bio => 'Bio';

  // Settings
  @override
  String get preferences => 'Preferences';
  @override
  String get notifications => 'Notifications';
  @override
  String get privacy => 'Privacy';
  @override
  String get about => 'About';
  @override
  String get version => 'Version';
  @override
  String get contactUs => 'Contact Us';
  @override
  String get feedback => 'Feedback';
  @override
  String get terms => 'Terms of Service';
  @override
  String get privacyPolicy => 'Privacy Policy';
  @override
  String get darkMode => 'Dark Mode';
  @override
  String get lightMode => 'Light Mode';

  // Errors & Validations
  @override
  String get fieldRequired => 'This field is required';
  @override
  String get invalidEmail => 'Invalid email address';
  @override
  String get passwordTooShort => 'Password must be at least 6 characters';
  @override
  String get passwordMismatch => 'Passwords do not match';
  @override
  String get invalidPhoneNumber => 'Invalid phone number';
  @override
  String get userNotFound => 'User not found';
  @override
  String get invalidCredentials => 'Invalid email or password';
  @override
  String get accountExists => 'Account already exists';
  @override
  String get somethingWentWrong => 'Something went wrong';

  // Payment & Booking
  @override
  String get payment => 'Payment';
  @override
  String get price => 'Price';
  @override
  String get total => 'Total';
  @override
  String get paymentMethod => 'Payment Method';
  @override
  String get creditCard => 'Credit Card';
  @override
  String get debitCard => 'Debit Card';
  @override
  String get paypal => 'PayPal';
  @override
  String get apple => 'Apple Pay';
  @override
  String get google => 'Google Pay';
  @override
  String get bookNow => 'Book Now';
  @override
  String get bookedSuccessfully => 'Booked Successfully';
  @override
  String get bookingCancelled => 'Booking Cancelled';
  @override
  String get refund => 'Refund';
  @override
  String get receipt => 'Receipt';
  @override
  String get completePayment => 'Complete Payment';

  // Player Levels
  @override
  String get beginner => 'Beginner';
  @override
  String get intermediate => 'Intermediate';
  @override
  String get advanced => 'Advanced';
  @override
  String get professional => 'Professional';

  // Days of Week
  @override
  String get monday => 'Monday';
  @override
  String get tuesday => 'Tuesday';
  @override
  String get wednesday => 'Wednesday';
  @override
  String get thursday => 'Thursday';
  @override
  String get friday => 'Friday';
  @override
  String get saturday => 'Saturday';
  @override
  String get sunday => 'Sunday';

  // Months
  @override
  String get january => 'January';
  @override
  String get february => 'February';
  @override
  String get march => 'March';
  @override
  String get april => 'April';
  @override
  String get may => 'May';
  @override
  String get june => 'June';
  @override
  String get july => 'July';
  @override
  String get august => 'August';
  @override
  String get september => 'September';
  @override
  String get october => 'October';
  @override
  String get november => 'November';
  @override
  String get december => 'December';

  // Additional UI Strings
  @override
  String get waitingForLocation => 'Waiting for location...';
  @override
  String get noClubsAvailable => 'No clubs available in your area';
  @override
  String get errorBooking => 'Error booking slot';
  @override
  String get bookingSuccess => 'Booked successfully';
  @override
  String get thisSlotNotAvailable => 'This slot is not available';
  @override
  String get failedToUploadImage => 'Failed to upload image';
  @override
  String get errorUploadingImage => 'Error uploading image';
  @override
  String get selectLanguage => 'Select Language';
  @override
  String get englishLanguage => 'English';
  @override
  String get hebrewLanguage => 'Hebrew';
  @override
  String get notAvailable => 'Not Available';
  @override
  String get noAvailableSlots => 'No available slots.';
  @override
  String get pickALocation => 'Pick a location';
  @override
  String get appDescription => 'Find your perfect match and book courts';
  @override
  String get continueWithPhone => 'Continue with Phone';
  @override
  String get termsAndPrivacy =>
      'By signing up, you agree to our Terms and Privacy Policy';
  @override
  String get joinThousands => '🎾 Join thousands of padel players';

  // Additional Missing Strings
  @override
  String get welcomeToPadelBud => 'Welcome to PadelBud';
  @override
  String get signInWithYourPhoneNumber =>
      'Sign in with your phone number to get started';
  @override
  String get countryState => 'Country/State';
  @override
  String get verificationCodeTitle => 'Verification Code';
  @override
  String get enterSixDigitCode => 'Enter the 6-digit code sent to your phone';
  @override
  String get pleaseEnterPhoneNumber => 'Please enter a phone number';
  @override
  String get sendVerificationCode => 'Send Verification Code';
  @override
  String get weWillSendCode => 'We\'ll send you a verification code via SMS';
  @override
  String get pleaseEnterValidCode => 'Please enter a valid 6-digit code';
  @override
  String get hintPhoneNumber => '50 123 4567';
  @override
  String get selectPaymentMethod => 'Select Payment Method';
  @override
  String get refundAmount => 'Refund Amount';
  @override
  String get myCubs => 'My Clubs';
  @override
  String get noClubsCreated => 'No clubs created yet';
  @override
  String get noMatchFound => 'No match found';
  @override
  String get findingPlayers => 'Finding Players';
  @override
  String get searchingForPlayers => 'Searching for Players';
  @override
  String get matchingYouWithPlayers =>
      'We\'re matching you with players in your area...';
  @override
  String get cancelSearch => 'Cancel Search';
  @override
  String get paymentSuccessful => 'Payment successful!';
  @override
  String get paymentFailed => 'Payment failed';
  @override
  String get confirmPayment => 'Confirm Payment';
  @override
  String get amount => 'Amount';

  // Club Creation & Management
  @override
  String get clubInformation => 'Club Information';
  @override
  String get addClubPhoto => 'Add Club Photo';
  @override
  String get tapToChangePhoto => 'Tap to change photo';
  @override
  String get tapToUploadPhoto => 'Tap to upload a photo';
  @override
  String get operatingHours => 'Operating Hours';
  @override
  String get createCourt => 'Create Court';
  @override
  String get markAsClosed => 'Mark as closed';
  @override
  String get closed => 'Closed';
  @override
  String get notSet => 'Not set';
  @override
  String get startTime => 'Open';
  @override
  String get endTime => 'Close';
  @override
  String get copyToAllDays => 'Copy to All Days';
  @override
  String get failedToAddClub => 'Failed to add club';
  @override
  String get clubAddedSuccessfully => 'Club added successfully';
  @override
  String get gameDuration => 'Game Duration';
  @override
  String get pricePerGame => 'Price per Game';
  @override
  String get enterPrice => 'Enter price';
  @override
  String get enterClubName => 'Enter club name';
  @override
  String get enterNumberOfCourts => 'Enter number of courts';
  @override
  String get validNumber => 'Enter a valid number';
  @override
  String get clubAddedSuccess => 'Club with {0} court(s) added successfully!';
  
  // Buddies/Find Match
  @override
  String get findBuddies => 'Find Buddies';
  @override
  String get whenWantToPlay => 'When do you want to play?';
  @override
  String get selectDateAndTimeToFindPlayers => 'Select a date and time to find players';
  @override
  String get selectDate => 'Select a date';
  @override
  String get selectTime => 'Select a time';
  @override
  String get findMatch => 'Find a Match';
  @override
  String get noPlayersFound => 'No players found';
  @override
  String get acceptMatch => 'Accept Match';
  
  @override
  String get available => 'Available';
  @override
  String get booked => 'Booked';
  @override
  String get book => 'Book';

  // Price Management
  @override
  String get editPrice => 'Edit Price';
  @override
  String get enterValidPrice => 'Please enter a valid price';
  @override
  String get priceUpdated => 'Price updated successfully';
  @override
  String get willUpdateAllSlots => 'This will update the price for all time slots of this court';
  @override
  String get update => 'Update';

  // Currency Management
  @override
  String get changeCurrency => 'Change Currency';
  @override
  String get currencyUpdated => 'Currency updated successfully';
  @override
  String get selectCurrency => 'Select Currency';

  // Court Schedule Page
  @override
  String get clubDetails => 'Club Details';
  @override
  String get courtSchedule => 'Court Schedule';
  @override
  String get editClubDetails => 'Edit Club Details';
  @override
  String get setPricesForCourts => 'Set prices for your courts';
  @override
  String get currentPrice => 'Current Price';
  @override
  String get noCourtsFound => 'No courts found';
  @override
  String get currency => 'Currency';
  @override
  String get pricing => 'Pricing';

}

class AppLocalizationsHe extends AppLocalizations {
  // Basic Navigation & App
  @override
  String get appTitle => 'PadelBud';
  @override
  String get home => 'בית';
  @override
  String get back => 'חזור';
  @override
  String get next => 'הבא';
  @override
  String get skip => 'דלג';
  @override
  String get done => 'בוצע';

  // Authentication
  @override
  String get login => 'התחברות';
  @override
  String get logout => 'התנתקות';
  @override
  String get email => 'אימייל';
  @override
  String get password => 'סיסמה';
  @override
  String get signUp => 'הרשמה';
  @override
  String get forgotPassword => 'שכחת סיסמה?';
  @override
  String get resetPassword => 'אפס סיסמה';
  @override
  String get phoneNumber => 'מספר טלפון';
  @override
  String get selectState => 'בחר מדינה';
  @override
  String get countryCode => 'קוד מדינה';
  @override
  String get verifyPhone => 'אמת טלפון';
  @override
  String get verificationCode => 'קוד אימות';
  @override
  String get resendCode => 'שלח מחדש קוד';
  @override
  String get googleSignIn => 'התחברות עם Google';
  @override
  String get appleSignIn => 'התחברות עם Apple';

  // Navigation Tabs
  @override
  String get bookCourt => 'הזמנת מגרש';
  @override
  String get myCourts => 'המגרשים שלי';
  @override
  String get myClubs => 'המועדונים שלי';
  @override
  String get schedule => 'לוח זמנים';
  @override
  String get profile => 'פרופיל';
  @override
  String get settings => 'הגדרות';
  @override
  String get language => 'שפה';

  // Role Selection
  @override
  String get selectRole => 'בחר תפקיד';
  @override
  String get playerRole => 'שחקן';
  @override
  String get clubOwnerRole => 'בעלים של מועדון';
  @override
  String get roleDescription => 'בחר בתפקידך כדי להתחיל';

  // Match/Game Related
  @override
  String get matchDetails => 'פרטי המשחק';
  @override
  String get players => 'שחקנים';
  @override
  String get location => 'מיקום';
  @override
  String get time => 'זמן';
  @override
  String get date => 'תאריך';
  @override
  String get duration => 'משך';
  @override
  String get level => 'רמה';
  @override
  String get court => 'מגרש';
  @override
  String get club => 'מועדון';
  @override
  String get joinMatch => 'הצטרף למשחק';
  @override
  String get leaveMatch => 'עזוב משחק';
  @override
  String get score => 'ניקוד';
  @override
  String get result => 'תוצאה';
  @override
  String get matchStatus => 'סטטוס המשחק';
  @override
  String get upcomingMatches => 'משחקים קרובים';
  @override
  String get pastMatches => 'משחקים קודמים';
  @override
  String get activeMatches => 'משחקים פעילים';

  // Club Management
  @override
  String get createClub => 'צור מועדון';
  @override
  String get clubName => 'שם המועדון';
  @override
  String get clubLocation => 'מיקום המועדון';
  @override
  String get clubDescription => 'תיאור המועדון';
  @override
  String get courtName => 'שם המגרש';
  @override
  String get courtType => 'סוג המגרש';
  @override
  String get numberOfCourts => 'מספר מגרשים';
  @override
  String get clubAddress => 'כתובת המועדון';
  @override
  String get clubPhone => 'טלפון המועדון';
  @override
  String get clubEmail => 'אימייל המועדון';
  @override
  String get openingHours => 'שעות פתיחה';
  @override
  String get closingHours => 'שעות סגירה';
  @override
  String get pricePerHour => 'מחיר לשעה';
  @override
  String get surfaceType => 'סוג הגג';
  @override
  String get lighting => 'תאורה';
  @override
  String get facilities => 'מתקנים';
  @override
  String get rules => 'כללים';

  // Forms & Actions
  @override
  String get save => 'שמור';
  @override
  String get saveChanges => 'שמור שינויים';
  @override
  String get cancel => 'ביטול';
  @override
  String get delete => 'מחק';
  @override
  String get edit => 'ערוך';
  @override
  String get add => 'הוסף';
  @override
  String get remove => 'הסר';
  @override
  String get ok => 'אישור';
  @override
  String get close => 'סגור';
  @override
  String get confirm => 'אישור';
  @override
  String get confirmDelete => 'אישור מחיקה';
  @override
  String get deleteConfirmation => 'האם אתה בטוח שברצונך למחוק?';

  // Messages
  @override
  String get error => 'שגיאה';
  @override
  String get success => 'הצלחה';
  @override
  String get loading => 'טוען...';
  @override
  String get noData => 'אין נתונים';
  @override
  String get noCourts => 'אין מגרשים זמינים';
  @override
  String get noMatches => 'לא נמצאו משחקים';
  @override
  String get noClubs => 'לא נמצאו מועדונים';
  @override
  String get tryAgain => 'נסה שוב';
  @override
  String get errorLoadingData => 'שגיאה בטעינת נתונים';
  @override
  String get connectionError => 'שגיאת חיבור';

  // Court Status
  @override
  String get fullCourt => 'מלא';
  @override
  String get availableCourt => 'זמין';
  @override
  String get bookingClosed => 'ההזמנה סגורה';
  @override
  String get comingSoon => 'בקרוב';

  // Photos & Media
  @override
  String get uploadPhoto => 'העלה תמונה';
  @override
  String get selectPhoto => 'בחר תמונה';
  @override
  String get camera => 'מצלמה';
  @override
  String get gallery => 'גלריה';
  @override
  String get changePhoto => 'שנה תמונה';
  @override
  String get removePhoto => 'הסר תמונה';
  @override
  String get clubPhoto => 'תמונת המועדון';
  @override
  String get playerPhoto => 'תמונת השחקן';
  @override
  String get uploadingPhoto => 'מעלה תמונה...';
  @override
  String get photoUploadSuccess => 'התמונה הועלתה בהצלחה';
  @override
  String get photoUploadFailed => 'כשל בהעלאת התמונה';
  @override
  String get selectPhotoFromCamera => 'צילום תמונה';
  @override
  String get selectPhotoFromGallery => 'בחירה מהגלריה';

  // Search & Filter
  @override
  String get searchClubs => 'חיפוש מועדונים';
  @override
  String get allClubs => 'כל המועדונים';
  @override
  String get nearbyClubs => 'מועדונים קרובים';
  @override
  String get search => 'חיפוש';
  @override
  String get filter => 'סינון';
  @override
  String get sortBy => 'מיין לפי';
  @override
  String get distance => 'מרחק';
  @override
  String get km => 'ק"מ';
  @override
  String get rating => 'דירוג';
  @override
  String get reviews => 'ביקורות';

  // Time Related
  @override
  String get hour => 'שעה';
  @override
  String get hours => 'שעות';
  @override
  String get minute => 'דקה';
  @override
  String get minutes => 'דקות';
  @override
  String get second => 'שנייה';
  @override
  String get day => 'יום';
  @override
  String get days => 'ימים';
  @override
  String get today => 'היום';
  @override
  String get tomorrow => 'מחר';
  @override
  String get yesterday => 'אתמול';
  @override
  String get week => 'שבוע זה';
  @override
  String get month => 'חודש זה';

  // Social
  @override
  String get buddies => 'חברים';
  @override
  String get addBuddy => 'הוסף חבר';
  @override
  String get removeBuddy => 'הסר חבר';
  @override
  String get viewProfile => 'הצג פרופיל';
  @override
  String get editProfile => 'ערוך פרופיל';
  @override
  String get myProfile => 'הפרופיל שלי';
  @override
  String get firstName => 'שם פרטי';
  @override
  String get lastName => 'שם משפחה';
  @override
  String get age => 'גיל';
  @override
  String get skill => 'רמת מיומנות';
  @override
  String get joinedDate => 'הצטרף';
  @override
  String get friends => 'חברים';
  @override
  String get followers => 'עוקבים';
  @override
  String get following => 'עוקב אחרי';
  @override
  String get statistics => 'סטטיסטיקה';
  @override
  String get matchesPlayed => 'משחקים שנשחקו';
  @override
  String get wins => 'ניצחונות';
  @override
  String get losses => 'הפסדים';
  @override
  String get bio => 'ביוגרפיה';

  // Settings
  @override
  String get preferences => 'העדפות';
  @override
  String get notifications => 'התנבעות';
  @override
  String get privacy => 'פרטיות';
  @override
  String get about => 'אודות';
  @override
  String get version => 'גרסה';
  @override
  String get contactUs => 'צור קשר';
  @override
  String get feedback => 'משוב';
  @override
  String get terms => 'תנאי השירות';
  @override
  String get privacyPolicy => 'מדיניות הפרטיות';
  @override
  String get darkMode => 'מצב כהה';
  @override
  String get lightMode => 'מצב בהיר';

  // Errors & Validations
  @override
  String get fieldRequired => 'שדה זה נדרש';
  @override
  String get invalidEmail => 'כתובת אימייל לא חוקית';
  @override
  String get passwordTooShort => 'הסיסמה חייבת להיות לפחות 6 תווים';
  @override
  String get passwordMismatch => 'הסיסמאות אינן תואמות';
  @override
  String get invalidPhoneNumber => 'מספר טלפון לא חוקי';
  @override
  String get userNotFound => 'המשתמש לא נמצא';
  @override
  String get invalidCredentials => 'אימייל או סיסמה לא נכונים';
  @override
  String get accountExists => 'החשבון כבר קיים';
  @override
  String get somethingWentWrong => 'משהו השתבש';

  // Payment & Booking
  @override
  String get payment => 'תשלום';
  @override
  String get price => 'מחיר';
  @override
  String get total => 'סך הכל';
  @override
  String get paymentMethod => 'שיטת תשלום';
  @override
  String get creditCard => 'כרטיס אשראי';
  @override
  String get debitCard => 'כרטיס חיוב';
  @override
  String get paypal => 'PayPal';
  @override
  String get apple => 'Apple Pay';
  @override
  String get google => 'Google Pay';
  @override
  String get bookNow => 'הזמן עכשיו';
  @override
  String get bookedSuccessfully => 'הוזמן בהצלחה';
  @override
  String get bookingCancelled => 'ההזמנה בוטלה';
  @override
  String get refund => 'החזר כספי';
  @override
  String get courts => 'מגרשים';
  @override
  String get receipt => 'קבלה';
  @override
  String get completePayment => 'השלם תשלום';

  // Player Levels
  @override
  String get beginner => 'מתחיל';
  @override
  String get intermediate => 'בינוני';
  @override
  String get advanced => 'מתקדם';
  @override
  String get professional => 'מקצועי';

  // Days of Week
  @override
  String get monday => 'יום שני';
  @override
  String get tuesday => 'יום שלישי';
  @override
  String get wednesday => 'יום רביעי';
  @override
  String get thursday => 'יום חמישי';
  @override
  String get friday => 'יום שישי';
  @override
  String get saturday => 'יום שבת';
  @override
  String get sunday => 'יום ראשון';

  // Months
  @override
  String get january => 'ינואר';
  @override
  String get february => 'פברואר';
  @override
  String get march => 'מרץ';
  @override
  String get april => 'אפריל';
  @override
  String get may => 'מאי';
  @override
  String get june => 'יוני';
  @override
  String get july => 'יולי';
  @override
  String get august => 'אוגוסט';
  @override
  String get september => 'ספטמבר';
  @override
  String get october => 'אוקטובר';
  @override
  String get november => 'נובמבר';
  @override
  String get december => 'דצמבר';

  // Additional UI Strings
  @override
  String get waitingForLocation => 'מחכה למיקום...';
  @override
  String get noClubsAvailable => 'אין מועדונים זמינים באזורך';
  @override
  String get errorBooking => 'שגיאה בהזמנת חריץ';
  @override
  String get bookingSuccess => 'הוזמן בהצלחה';
  @override
  String get thisSlotNotAvailable => 'חריץ זה אינו זמין';
  @override
  String get failedToUploadImage => 'כשל בהעלאת התמונה';
  @override
  String get errorUploadingImage => 'שגיאה בהעלאת התמונה';
  @override
  String get selectLanguage => 'בחר שפה';
  @override
  String get englishLanguage => 'English';
  @override
  String get hebrewLanguage => 'עברית';
  @override
  String get notAvailable => 'לא זמין';
  @override
  String get noAvailableSlots => 'המגרש לא פנוי';
  @override
  String get pickALocation => 'בחר מיקום';
  @override
  String get appDescription => 'מצא את ההתאמה המושלמת שלך והזמן מגרשים';
  @override
  String get continueWithPhone => 'המשך עם הטלפון';
  @override
  String get termsAndPrivacy =>
      'בהרשמה, אתה מסכים לתנאים שלנו ומדיניות הפרטיות';
  @override
  String get joinThousands => '🎾 הצטרף לאלפי שחקני פדל';

  // Additional Missing Strings
  @override
  String get welcomeToPadelBud => 'ברוכים הבאים ל-PadelBud';
  @override
  String get signInWithYourPhoneNumber => 'התחבר עם מספר הטלפון שלך כדי להתחיל';
  @override
  String get countryState => 'מדינה/מדינה';
  @override
  String get verificationCodeTitle => 'קוד אימות';
  @override
  String get enterSixDigitCode => 'הזן את קוד 6 הספרות שנשלח לטלפון שלך';
  @override
  String get pleaseEnterPhoneNumber => 'אנא הזן מספר טלפון';
  @override
  String get sendVerificationCode => 'שלח קוד אימות';
  @override
  String get weWillSendCode => 'נשלח לך קוד אימות דרך SMS';
  @override
  String get pleaseEnterValidCode => 'אנא הזן קוד תקף של 6 ספרות';
  @override
  String get hintPhoneNumber => '50 123 4567';
  @override
  String get selectPaymentMethod => 'בחר שיטת תשלום';
  @override
  String get refundAmount => 'סכום החזר כספי';
  @override
  String get myCubs => 'המועדונים שלי';
  @override
  String get noClubsCreated => 'עדיין לא נוצרו מועדונים';
  @override
  String get matchFound => 'מצאנו שותפים!';
  @override
  String get noMatchFound => 'לא נמצא משחק';
  @override
  String get findingPlayers => 'חיפוש שחקנים';
  @override
  String get searchingForPlayers => 'חיפוש שחקנים';
  @override
  String get matchingYouWithPlayers => 'אנו מתאימים אותך עם שחקנים באזורך...';
  @override
  String get cancelSearch => 'ביטול חיפוש';
  @override
  String get paymentSuccessful => 'התשלום בוצע בהצלחה!';
  @override
  String get paymentFailed => 'התשלום נכשל';
  @override
  String get confirmPayment => 'אישור תשלום';
  @override
  String get amount => 'סכום';

  // Club Creation & Management
  @override
  String get clubInformation => 'מידע על המועדון';
  @override
  String get addClubPhoto => 'הוסף תמונת מועדון';
  @override
  String get tapToChangePhoto => 'הקש כדי לשנות תמונה';
  @override
  String get tapToUploadPhoto => 'הקש להעלאת תמונה';
  @override
  String get operatingHours => 'שעות פעילות';
  @override
  String get createCourt => 'צור מגרש';
  @override
  String get markAsClosed => 'סמן כסגור';
  @override
  String get closed => 'סגור';
  @override
  String get notSet => 'לא הוגדר';
  @override
  String get startTime => 'פתיחה';
  @override
  String get copyToAllDays => 'העתק לכל הימים';
  @override
  String get failedToAddClub => 'כשל בהוספת מועדון';
  @override
  String get clubAddedSuccessfully => 'המועדון נוסף בהצלחה';
  @override
  String get endTime => 'סגירה';
  @override
  String get gameDuration => 'משך המשחק';
  @override
  String get pricePerGame => 'מחיר למשחק';
  @override
  String get enterPrice => 'הזן מחיר';
  @override
  String get enterClubName => 'הזן שם מועדון';
  @override
  String get enterNumberOfCourts => 'הזן מספר מגרשים';
  @override
  String get validNumber => 'הזן מספר תקף';
  @override
  String get clubAddedSuccess => 'המועדון עם {0} מגרש(ים) נוסף בהצלחה!';
  
  // Buddies/Find Match
  @override
  String get findBuddies => ' חיפוש שותפים';
  @override
  String get whenWantToPlay => 'מתי אתה רוצה לשחק?';
  @override
  String get selectDateAndTimeToFindPlayers => 'בחר תאריך וזמן כדי למצוא שחקנים';
  @override
  String get selectDate => 'בחר תאריך';
  @override
  String get selectTime => 'בחר זמן';
  @override
  String get findMatch => 'חיפוש משחק';
  @override
  String get noPlayersFound => 'לא נמצאו שחקנים';
  @override
  String get acceptMatch => 'קבל משחק';
  
  @override
  String get available => 'פנוי';
  @override
  String get booked => 'מוזמן';
  @override
  String get book => 'הזמן';

  // Price Management
  @override
  String get editPrice => 'עריכת מחיר';
  @override
  String get enterValidPrice => 'אנא הזן מחיר תקף';
  @override
  String get priceUpdated => 'המחיר עודכן בהצלחה';
  @override
  String get willUpdateAllSlots => 'פעולה זו תעדכן את המחיר לכל משבצות הזמן של המגרש הזה';
  @override
  String get update => 'עדכן';

  // Currency Management
  @override
  String get changeCurrency => 'שינוי מטבע';
  @override
  String get currencyUpdated => 'המטבע עודכן בהצלחה';
  @override
  String get selectCurrency => 'בחר מטבע';

  // Court Schedule Page
  @override
  String get clubDetails => 'פרטי המועדון';
  @override
  String get courtSchedule => 'לוח זמנים של המגרשים';
  @override
  String get editClubDetails => 'עריכת פרטי המועדון';
  @override
  String get setPricesForCourts => 'הגדר מחירים למגרשים שלך';
  @override
  String get currentPrice => 'מחיר נוכחי';
  @override
  String get noCourtsFound => 'לא נמצאו מגרשים';
  @override
  String get currency => 'מטבע';
  @override
  String get pricing => 'תמחור';
}
