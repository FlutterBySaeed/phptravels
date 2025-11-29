import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PHP Travels'**
  String get appTitle;

  /// No description provided for @flights.
  ///
  /// In en, this message translates to:
  /// **'Flights'**
  String get flights;

  /// No description provided for @hotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// No description provided for @searchFlights.
  ///
  /// In en, this message translates to:
  /// **'Search Flights'**
  String get searchFlights;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @departureDate.
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureDate;

  /// No description provided for @returnDate.
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get returnDate;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @passengers.
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengers;

  /// No description provided for @adult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get adult;

  /// No description provided for @adults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get adults;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @infant.
  ///
  /// In en, this message translates to:
  /// **'Infant'**
  String get infant;

  /// No description provided for @infants.
  ///
  /// In en, this message translates to:
  /// **'Infants'**
  String get infants;

  /// No description provided for @cabinClass.
  ///
  /// In en, this message translates to:
  /// **'Cabin Class'**
  String get cabinClass;

  /// No description provided for @economy.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get economy;

  /// No description provided for @premiumEconomy.
  ///
  /// In en, this message translates to:
  /// **'Premium Economy'**
  String get premiumEconomy;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @firstClass.
  ///
  /// In en, this message translates to:
  /// **'First Class'**
  String get firstClass;

  /// No description provided for @oneWay.
  ///
  /// In en, this message translates to:
  /// **'One-way'**
  String get oneWay;

  /// No description provided for @roundTrip.
  ///
  /// In en, this message translates to:
  /// **'Round-trip'**
  String get roundTrip;

  /// No description provided for @multiCity.
  ///
  /// In en, this message translates to:
  /// **'Multi-city'**
  String get multiCity;

  /// No description provided for @paymentTypes.
  ///
  /// In en, this message translates to:
  /// **'Payment Types'**
  String get paymentTypes;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @paymentMethodsInfo.
  ///
  /// In en, this message translates to:
  /// **'By selecting one or more (max 10) payment types,\nprices on PHPTRAVELS will include applicable minimum\npayment fees. Please note that not all providers\nsupport all payment types.'**
  String get paymentMethodsInfo;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @preferredPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Preferred Payment Method'**
  String get preferredPaymentMethod;

  /// No description provided for @myTrips.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTrips;

  /// No description provided for @hotelBookings.
  ///
  /// In en, this message translates to:
  /// **'Hotel Bookings'**
  String get hotelBookings;

  /// No description provided for @flightBookings.
  ///
  /// In en, this message translates to:
  /// **'Flight Bookings'**
  String get flightBookings;

  /// No description provided for @addEditTraveller.
  ///
  /// In en, this message translates to:
  /// **'Add/Edit Traveller'**
  String get addEditTraveller;

  /// No description provided for @businessTravel.
  ///
  /// In en, this message translates to:
  /// **'Business Travel'**
  String get businessTravel;

  /// No description provided for @readyToStart.
  ///
  /// In en, this message translates to:
  /// **'Ready to start your next adventure? Login to book\nfaster with effortless form-filling.'**
  String get readyToStart;

  /// No description provided for @signUpLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign up / Log in'**
  String get signUpLogin;

  /// No description provided for @businessTravelDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign up for free on PHPTRAVELS and enjoy\nexclusive savings on your corporate travel\nplans!'**
  String get businessTravelDescription;

  /// No description provided for @searchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Search Language'**
  String get searchLanguage;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @stories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @searchDestination.
  ///
  /// In en, this message translates to:
  /// **'Search destination...'**
  String get searchDestination;

  /// No description provided for @searchPaymentType.
  ///
  /// In en, this message translates to:
  /// **'Search payment type'**
  String get searchPaymentType;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @hotelsSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Hotels Search'**
  String get hotelsSearchTitle;

  /// No description provided for @selectCheckInDate.
  ///
  /// In en, this message translates to:
  /// **'Select Check-in Date'**
  String get selectCheckInDate;

  /// No description provided for @selectCheckOutDate.
  ///
  /// In en, this message translates to:
  /// **'Select Check-out Date'**
  String get selectCheckOutDate;

  /// No description provided for @needPlaceTonight.
  ///
  /// In en, this message translates to:
  /// **'I need a place tonight!'**
  String get needPlaceTonight;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check out'**
  String get checkOut;

  /// No description provided for @guestsAndRooms.
  ///
  /// In en, this message translates to:
  /// **'Guests & Rooms'**
  String get guestsAndRooms;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @searchHotels.
  ///
  /// In en, this message translates to:
  /// **'Search Hotels'**
  String get searchHotels;

  /// No description provided for @addRoom.
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get addRoom;

  /// No description provided for @removeRoom.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeRoom;

  /// No description provided for @ageOfChildren.
  ///
  /// In en, this message translates to:
  /// **'Age of Children'**
  String get ageOfChildren;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @addAnotherFlight.
  ///
  /// In en, this message translates to:
  /// **'Add another flight'**
  String get addAnotherFlight;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @selectDates.
  ///
  /// In en, this message translates to:
  /// **'Select Dates'**
  String get selectDates;

  /// No description provided for @selectDepartureDate.
  ///
  /// In en, this message translates to:
  /// **'Select Departure Date'**
  String get selectDepartureDate;

  /// No description provided for @passengersAndCabin.
  ///
  /// In en, this message translates to:
  /// **'Passengers & Cabin\nClass'**
  String get passengersAndCabin;

  /// No description provided for @adultAgeHint.
  ///
  /// In en, this message translates to:
  /// **'(>12 years)'**
  String get adultAgeHint;

  /// No description provided for @childAgeHint.
  ///
  /// In en, this message translates to:
  /// **'(2-12 years)'**
  String get childAgeHint;

  /// No description provided for @infantAgeHint.
  ///
  /// In en, this message translates to:
  /// **'(<2 years)'**
  String get infantAgeHint;

  /// No description provided for @recentSearchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue your search'**
  String get recentSearchesTitle;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @followSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Follow system settings'**
  String get followSystemSettings;

  /// No description provided for @lightDescription.
  ///
  /// In en, this message translates to:
  /// **'Light background with dark text'**
  String get lightDescription;

  /// No description provided for @darkDescription.
  ///
  /// In en, this message translates to:
  /// **'Dark background with light text'**
  String get darkDescription;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
