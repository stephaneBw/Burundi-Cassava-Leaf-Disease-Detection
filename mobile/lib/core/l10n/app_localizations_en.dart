// Provides generated English localization strings.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GreenHealer';

  @override
  String get farmerGreetingTitle => 'Hello! I\'m GreenHealer.';

  @override
  String get farmerGreetingBody =>
      'I am your AI assistant developed for plants. Is there a problem with your plant? Take a photo of the leaf, let\'s check its health status.';

  @override
  String get farmerAnalyzingBody =>
      'Interesting... I\'m examining the details on the leaves. I\'m about to make my diagnosis, almost there.';

  @override
  String farmerResultSuccess(Object confidence, Object label) {
    return 'Analysis complete! There is a $confidence% chance this is a $label case. I have noted treatment methods and detailed information in the library for you, I recommend taking a look.';
  }

  @override
  String farmerResultHealthy(Object confidence) {
    return 'Great news! There is a $confidence% chance your plant looks healthy. I didn\'t find any signs of disease, you\'re doing a great job; keep up the good care!';
  }

  @override
  String get farmerErrorBody => 'Oops, something went wrong. Can you try again?';

  @override
  String get lblCamera => 'Camera';

  @override
  String get lblGallery => 'Gallery';

  @override
  String get lblSearch => 'Search...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get langEnglish => 'English';

  @override
  String get langTurkish => 'Turkish';

  @override
  String get historyEmpty => 'No scan history yet.';

  @override
  String get dialogClearTitle => 'Clear History';

  @override
  String get dialogClearMessage =>
      'Are you sure you want to delete all scan history? This action cannot be undone.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get filterTitle => 'Filter';

  @override
  String get filterReset => 'Reset';

  @override
  String get filterApply => 'Apply';

  @override
  String get filterDate => 'Date Range';

  @override
  String get filterStatus => 'Health Status';

  @override
  String get filterPlants => 'Plant Type';

  @override
  String get filterAllTime => 'All Time';

  @override
  String get filterLast15Min => 'Last 15 Min';

  @override
  String get filterLast1Hour => 'Last 1 Hour';

  @override
  String get filterLast24Hours => 'Last 24 Hours';

  @override
  String get filterLast7Days => 'Last 7 Days';

  @override
  String get filterLast30Days => 'Last 30 Days';

  @override
  String get filterAllStatus => 'All';

  @override
  String get filterHealthyOnly => 'Healthy Only';

  @override
  String get filterInfectedOnly => 'Infected Only';

  @override
  String get btnViewInLibrary => 'View in Library';

  @override
  String get btnQuestionHow => 'How do you diagnose?';

  @override
  String get btnQuestionPlants => 'Which plants?';

  @override
  String get ansQuestionHow =>
      'I examine the spots and changes on the leaf with an experienced eye. I identify the problem and share the care suggestions needed to revive your plant.';

  @override
  String get ansQuestionPlants =>
      'I specialize in the common diseases of 14 plants, such as tomatoes, apples, and grapes. You can see the full list in the Library.';

  @override
  String get dsAppleScab => 'Apple: Apple Scab';

  @override
  String get dsAppleBlackRot => 'Apple: Black Rot';

  @override
  String get dsAppleCedarRust => 'Apple: Cedar Apple Rust';

  @override
  String get dsAppleHealthy => 'Apple: Healthy';

  @override
  String get dsBlueberryHealthy => 'Blueberry: Healthy';

  @override
  String get dsCherryPowderyMildew => 'Cherry: Powdery Mildew';

  @override
  String get dsCherryHealthy => 'Cherry: Healthy';

  @override
  String get dsCornCercospora => 'Corn: Cercospora Leaf Spot';

  @override
  String get dsCornCommonRust => 'Corn: Common Rust';

  @override
  String get dsCornNorthernBlight => 'Corn: Northern Leaf Blight';

  @override
  String get dsCornHealthy => 'Corn: Healthy';

  @override
  String get dsGrapeBlackRot => 'Grape: Black Rot';

  @override
  String get dsGrapeEsca => 'Grape: Esca (Black Measles)';

  @override
  String get dsGrapeLeafBlight => 'Grape: Leaf Blight (Isariopsis)';

  @override
  String get dsGrapeHealthy => 'Grape: Healthy';

  @override
  String get dsOrangeHLB => 'Orange: Huanglongbing (Citrus Greening)';

  @override
  String get dsPeachBacterialSpot => 'Peach: Bacterial Spot';

  @override
  String get dsPeachHealthy => 'Peach: Healthy';

  @override
  String get dsPepperBacterialSpot => 'Pepper: Bacterial Spot';

  @override
  String get dsPepperHealthy => 'Pepper: Healthy';

  @override
  String get dsPotatoEarlyBlight => 'Potato: Early Blight';

  @override
  String get dsPotatoLateBlight => 'Potato: Late Blight';

  @override
  String get dsPotatoHealthy => 'Potato: Healthy';

  @override
  String get dsRaspberryHealthy => 'Raspberry: Healthy';

  @override
  String get dsSoybeanHealthy => 'Soybean: Healthy';

  @override
  String get dsSquashPowderyMildew => 'Squash: Powdery Mildew';

  @override
  String get dsStrawberryLeafScorch => 'Strawberry: Leaf Scorch';

  @override
  String get dsStrawberryHealthy => 'Strawberry: Healthy';

  @override
  String get dsTomatoBacterialSpot => 'Tomato: Bacterial Spot';

  @override
  String get dsTomatoEarlyBlight => 'Tomato: Early Blight';

  @override
  String get dsTomatoLateBlight => 'Tomato: Late Blight';

  @override
  String get dsTomatoLeafMold => 'Tomato: Leaf Mold';

  @override
  String get dsTomatoSeptoria => 'Tomato: Septoria Leaf Spot';

  @override
  String get dsTomatoSpiderMites => 'Tomato: Two-spotted Spider Mite';

  @override
  String get dsTomatoTargetSpot => 'Tomato: Target Spot';

  @override
  String get dsTomatoYellowCurl => 'Tomato: Yellow Leaf Curl Virus';

  @override
  String get dsTomatoMosaic => 'Tomato: Mosaic Virus';

  @override
  String get dsTomatoHealthy => 'Tomato: Healthy';

  @override
  String get dsUnknown => 'Unknown Condition';

  @override
  String get plantApple => 'Apple';

  @override
  String get plantBlueberry => 'Blueberry';

  @override
  String get plantCherry => 'Cherry';

  @override
  String get plantCorn => 'Corn';

  @override
  String get plantGrape => 'Grape';

  @override
  String get plantOrange => 'Orange';

  @override
  String get plantPeach => 'Peach';

  @override
  String get plantPepper => 'Pepper';

  @override
  String get plantPotato => 'Potato';

  @override
  String get plantRaspberry => 'Raspberry';

  @override
  String get plantSoybean => 'Soybean';

  @override
  String get plantSquash => 'Squash';

  @override
  String get plantStrawberry => 'Strawberry';

  @override
  String get plantTomato => 'Tomato';

  @override
  String get tabSymptoms => 'Symptoms';

  @override
  String get tabTreatment => 'Treatment';

  @override
  String get tabPrevention => 'Prevention';

  @override
  String get diseaseInfoPending => 'Disease information is loading...';
}
