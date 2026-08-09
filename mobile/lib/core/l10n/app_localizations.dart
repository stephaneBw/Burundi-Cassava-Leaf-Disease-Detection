// Provides generated localization lookup and delegate wiring.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('tr')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GreenHealer'**
  String get appTitle;

  /// No description provided for @farmerGreetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m GreenHealer.'**
  String get farmerGreetingTitle;

  /// No description provided for @farmerGreetingBody.
  ///
  /// In en, this message translates to:
  /// **'I am your AI assistant developed for plants. Is there a problem with your plant? Take a photo of the leaf, let\'s check its health status.'**
  String get farmerGreetingBody;

  /// No description provided for @farmerAnalyzingBody.
  ///
  /// In en, this message translates to:
  /// **'Interesting... I\'m examining the details on the leaves. I\'m about to make my diagnosis, almost there.'**
  String get farmerAnalyzingBody;

  /// No description provided for @farmerResultSuccess.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete! There is a {confidence}% chance this is a {label} case. I have noted treatment methods and detailed information in the library for you, I recommend taking a look.'**
  String farmerResultSuccess(Object confidence, Object label);

  /// No description provided for @farmerResultHealthy.
  ///
  /// In en, this message translates to:
  /// **'Great news! There is a {confidence}% chance your plant looks healthy. I didn\'t find any signs of disease, you\'re doing a great job; keep up the good care!'**
  String farmerResultHealthy(Object confidence);

  /// No description provided for @farmerErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong. Can you try again?'**
  String get farmerErrorBody;

  /// No description provided for @lblCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get lblCamera;

  /// No description provided for @lblGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get lblGallery;

  /// No description provided for @lblSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get lblSearch;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeDark;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get langTurkish;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scan history yet.'**
  String get historyEmpty;

  /// No description provided for @dialogClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get dialogClearTitle;

  /// No description provided for @dialogClearMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all scan history? This action cannot be undone.'**
  String get dialogClearMessage;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// No description provided for @filterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filterApply;

  /// No description provided for @filterDate.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get filterDate;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get filterStatus;

  /// No description provided for @filterPlants.
  ///
  /// In en, this message translates to:
  /// **'Plant Type'**
  String get filterPlants;

  /// No description provided for @filterAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get filterAllTime;

  /// No description provided for @filterLast15Min.
  ///
  /// In en, this message translates to:
  /// **'Last 15 Min'**
  String get filterLast15Min;

  /// No description provided for @filterLast1Hour.
  ///
  /// In en, this message translates to:
  /// **'Last 1 Hour'**
  String get filterLast1Hour;

  /// No description provided for @filterLast24Hours.
  ///
  /// In en, this message translates to:
  /// **'Last 24 Hours'**
  String get filterLast24Hours;

  /// No description provided for @filterLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get filterLast7Days;

  /// No description provided for @filterLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get filterLast30Days;

  /// No description provided for @filterAllStatus.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAllStatus;

  /// No description provided for @filterHealthyOnly.
  ///
  /// In en, this message translates to:
  /// **'Healthy Only'**
  String get filterHealthyOnly;

  /// No description provided for @filterInfectedOnly.
  ///
  /// In en, this message translates to:
  /// **'Infected Only'**
  String get filterInfectedOnly;

  /// No description provided for @btnViewInLibrary.
  ///
  /// In en, this message translates to:
  /// **'View in Library'**
  String get btnViewInLibrary;

  /// No description provided for @btnQuestionHow.
  ///
  /// In en, this message translates to:
  /// **'How do you diagnose?'**
  String get btnQuestionHow;

  /// No description provided for @btnQuestionPlants.
  ///
  /// In en, this message translates to:
  /// **'Which plants?'**
  String get btnQuestionPlants;

  /// No description provided for @ansQuestionHow.
  ///
  /// In en, this message translates to:
  /// **'I examine the spots and changes on the leaf with an experienced eye. I identify the problem and share the care suggestions needed to revive your plant.'**
  String get ansQuestionHow;

  /// No description provided for @ansQuestionPlants.
  ///
  /// In en, this message translates to:
  /// **'I specialize in the common diseases of 14 plants, such as tomatoes, apples, and grapes. You can see the full list in the Library.'**
  String get ansQuestionPlants;

  /// No description provided for @dsAppleScab.
  ///
  /// In en, this message translates to:
  /// **'Apple: Apple Scab'**
  String get dsAppleScab;

  /// No description provided for @dsAppleBlackRot.
  ///
  /// In en, this message translates to:
  /// **'Apple: Black Rot'**
  String get dsAppleBlackRot;

  /// No description provided for @dsAppleCedarRust.
  ///
  /// In en, this message translates to:
  /// **'Apple: Cedar Apple Rust'**
  String get dsAppleCedarRust;

  /// No description provided for @dsAppleHealthy.
  ///
  /// In en, this message translates to:
  /// **'Apple: Healthy'**
  String get dsAppleHealthy;

  /// No description provided for @dsBlueberryHealthy.
  ///
  /// In en, this message translates to:
  /// **'Blueberry: Healthy'**
  String get dsBlueberryHealthy;

  /// No description provided for @dsCherryPowderyMildew.
  ///
  /// In en, this message translates to:
  /// **'Cherry: Powdery Mildew'**
  String get dsCherryPowderyMildew;

  /// No description provided for @dsCherryHealthy.
  ///
  /// In en, this message translates to:
  /// **'Cherry: Healthy'**
  String get dsCherryHealthy;

  /// No description provided for @dsCornCercospora.
  ///
  /// In en, this message translates to:
  /// **'Corn: Cercospora Leaf Spot'**
  String get dsCornCercospora;

  /// No description provided for @dsCornCommonRust.
  ///
  /// In en, this message translates to:
  /// **'Corn: Common Rust'**
  String get dsCornCommonRust;

  /// No description provided for @dsCornNorthernBlight.
  ///
  /// In en, this message translates to:
  /// **'Corn: Northern Leaf Blight'**
  String get dsCornNorthernBlight;

  /// No description provided for @dsCornHealthy.
  ///
  /// In en, this message translates to:
  /// **'Corn: Healthy'**
  String get dsCornHealthy;

  /// No description provided for @dsGrapeBlackRot.
  ///
  /// In en, this message translates to:
  /// **'Grape: Black Rot'**
  String get dsGrapeBlackRot;

  /// No description provided for @dsGrapeEsca.
  ///
  /// In en, this message translates to:
  /// **'Grape: Esca (Black Measles)'**
  String get dsGrapeEsca;

  /// No description provided for @dsGrapeLeafBlight.
  ///
  /// In en, this message translates to:
  /// **'Grape: Leaf Blight (Isariopsis)'**
  String get dsGrapeLeafBlight;

  /// No description provided for @dsGrapeHealthy.
  ///
  /// In en, this message translates to:
  /// **'Grape: Healthy'**
  String get dsGrapeHealthy;

  /// No description provided for @dsOrangeHLB.
  ///
  /// In en, this message translates to:
  /// **'Orange: Huanglongbing (Citrus Greening)'**
  String get dsOrangeHLB;

  /// No description provided for @dsPeachBacterialSpot.
  ///
  /// In en, this message translates to:
  /// **'Peach: Bacterial Spot'**
  String get dsPeachBacterialSpot;

  /// No description provided for @dsPeachHealthy.
  ///
  /// In en, this message translates to:
  /// **'Peach: Healthy'**
  String get dsPeachHealthy;

  /// No description provided for @dsPepperBacterialSpot.
  ///
  /// In en, this message translates to:
  /// **'Pepper: Bacterial Spot'**
  String get dsPepperBacterialSpot;

  /// No description provided for @dsPepperHealthy.
  ///
  /// In en, this message translates to:
  /// **'Pepper: Healthy'**
  String get dsPepperHealthy;

  /// No description provided for @dsPotatoEarlyBlight.
  ///
  /// In en, this message translates to:
  /// **'Potato: Early Blight'**
  String get dsPotatoEarlyBlight;

  /// No description provided for @dsPotatoLateBlight.
  ///
  /// In en, this message translates to:
  /// **'Potato: Late Blight'**
  String get dsPotatoLateBlight;

  /// No description provided for @dsPotatoHealthy.
  ///
  /// In en, this message translates to:
  /// **'Potato: Healthy'**
  String get dsPotatoHealthy;

  /// No description provided for @dsRaspberryHealthy.
  ///
  /// In en, this message translates to:
  /// **'Raspberry: Healthy'**
  String get dsRaspberryHealthy;

  /// No description provided for @dsSoybeanHealthy.
  ///
  /// In en, this message translates to:
  /// **'Soybean: Healthy'**
  String get dsSoybeanHealthy;

  /// No description provided for @dsSquashPowderyMildew.
  ///
  /// In en, this message translates to:
  /// **'Squash: Powdery Mildew'**
  String get dsSquashPowderyMildew;

  /// No description provided for @dsStrawberryLeafScorch.
  ///
  /// In en, this message translates to:
  /// **'Strawberry: Leaf Scorch'**
  String get dsStrawberryLeafScorch;

  /// No description provided for @dsStrawberryHealthy.
  ///
  /// In en, this message translates to:
  /// **'Strawberry: Healthy'**
  String get dsStrawberryHealthy;

  /// No description provided for @dsTomatoBacterialSpot.
  ///
  /// In en, this message translates to:
  /// **'Tomato: Bacterial Spot'**
  String get dsTomatoBacterialSpot;

  /// No description provided for @dsTomatoEarlyBlight.
  ///
  /// In en, this message translates to:
  /// **'Tomato: Early Blight'**
  String get dsTomatoEarlyBlight;

  /// No description provided for @dsTomatoLateBlight.
  ///
  /// In en, this message translates to:
  /// **'Tomato: Late Blight'**
  String get dsTomatoLateBlight;

  /// No description provided for @dsTomatoLeafMold.
  ///
  /// In en, this message translates to:
  /// **'Tomato: Leaf Mold'**
  String get dsTomatoLeafMold;

  /// No description provided for @dsTomatoSeptoria.
  ///
  /// In en, this message translates to:
  /// **'Tomato: Septoria Leaf Spot'**
  String get dsTomatoSeptoria;

  /// No description provided for @dsTomatoSpiderMites.
  ///
  /// In en, this message translates to:
  /// **'Tomato: Two-spotted Spider Mite'**
  String get dsTomatoSpiderMites;

  /// No description provided for @dsTomatoTargetSpot.
  ///
  /// In en, this message translates to:
  /// **'Tomato: Target Spot'**
  String get dsTomatoTargetSpot;

  /// No description provided for @dsTomatoYellowCurl.
  ///
  /// In en, this message translates to:
  /// **'Tomato: Yellow Leaf Curl Virus'**
  String get dsTomatoYellowCurl;

  /// No description provided for @dsTomatoMosaic.
  ///
  /// In en, this message translates to:
  /// **'Tomato: Mosaic Virus'**
  String get dsTomatoMosaic;

  /// No description provided for @dsTomatoHealthy.
  ///
  /// In en, this message translates to:
  /// **'Tomato: Healthy'**
  String get dsTomatoHealthy;

  /// No description provided for @dsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Condition'**
  String get dsUnknown;

  /// No description provided for @plantApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get plantApple;

  /// No description provided for @plantBlueberry.
  ///
  /// In en, this message translates to:
  /// **'Blueberry'**
  String get plantBlueberry;

  /// No description provided for @plantCherry.
  ///
  /// In en, this message translates to:
  /// **'Cherry'**
  String get plantCherry;

  /// No description provided for @plantCorn.
  ///
  /// In en, this message translates to:
  /// **'Corn'**
  String get plantCorn;

  /// No description provided for @plantGrape.
  ///
  /// In en, this message translates to:
  /// **'Grape'**
  String get plantGrape;

  /// No description provided for @plantOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get plantOrange;

  /// No description provided for @plantPeach.
  ///
  /// In en, this message translates to:
  /// **'Peach'**
  String get plantPeach;

  /// No description provided for @plantPepper.
  ///
  /// In en, this message translates to:
  /// **'Pepper'**
  String get plantPepper;

  /// No description provided for @plantPotato.
  ///
  /// In en, this message translates to:
  /// **'Potato'**
  String get plantPotato;

  /// No description provided for @plantRaspberry.
  ///
  /// In en, this message translates to:
  /// **'Raspberry'**
  String get plantRaspberry;

  /// No description provided for @plantSoybean.
  ///
  /// In en, this message translates to:
  /// **'Soybean'**
  String get plantSoybean;

  /// No description provided for @plantSquash.
  ///
  /// In en, this message translates to:
  /// **'Squash'**
  String get plantSquash;

  /// No description provided for @plantStrawberry.
  ///
  /// In en, this message translates to:
  /// **'Strawberry'**
  String get plantStrawberry;

  /// No description provided for @plantTomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get plantTomato;

  /// No description provided for @tabSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get tabSymptoms;

  /// No description provided for @tabTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get tabTreatment;

  /// No description provided for @tabPrevention.
  ///
  /// In en, this message translates to:
  /// **'Prevention'**
  String get tabPrevention;

  /// No description provided for @diseaseInfoPending.
  ///
  /// In en, this message translates to:
  /// **'Disease information is loading...'**
  String get diseaseInfoPending;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
