// Maps raw model labels to localized plant and disease presentation data.

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class DiseaseLabelMapper {
  // PlantVillage export labels are mapped to app localization keys at the boundary.
  static String? getJsonKey(String rawLabel) {
    const Map<String, String> map = {
      'Apple___Apple_scab': 'dsAppleScab',
      'Apple___Black_rot': 'dsAppleBlackRot',
      'Apple___Cedar_apple_rust': 'dsAppleCedarRust',
      'Apple___healthy': 'dsAppleHealthy',
      'Blueberry___healthy': 'dsBlueberryHealthy',
      'Cherry_(including_sour)___Powdery_mildew': 'dsCherryPowderyMildew',
      'Cherry_(including_sour)___healthy': 'dsCherryHealthy',
      'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot': 'dsCornCercospora',
      'Corn_(maize)___Common_rust_': 'dsCornCommonRust',
      'Corn_(maize)___Northern_Leaf_Blight': 'dsCornNorthernBlight',
      'Corn_(maize)___healthy': 'dsCornHealthy',
      'Grape___Black_rot': 'dsGrapeBlackRot',
      'Grape___Esca_(Black_Measles)': 'dsGrapeEsca',
      'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)': 'dsGrapeLeafBlight',
      'Grape___healthy': 'dsGrapeHealthy',
      'Orange___Haunglongbing_(Citrus_greening)': 'dsOrangeHLB',
      'Peach___Bacterial_spot': 'dsPeachBacterialSpot',
      'Peach___healthy': 'dsPeachHealthy',
      'Pepper,_bell___Bacterial_spot': 'dsPepperBacterialSpot',
      'Pepper,_bell___healthy': 'dsPepperHealthy',
      'Potato___Early_blight': 'dsPotatoEarlyBlight',
      'Potato___Late_blight': 'dsPotatoLateBlight',
      'Potato___healthy': 'dsPotatoHealthy',
      'Raspberry___healthy': 'dsRaspberryHealthy',
      'Soybean___healthy': 'dsSoybeanHealthy',
      'Squash___Powdery_mildew': 'dsSquashPowderyMildew',
      'Strawberry___Leaf_scorch': 'dsStrawberryLeafScorch',
      'Strawberry___healthy': 'dsStrawberryHealthy',
      'Tomato___Bacterial_spot': 'dsTomatoBacterialSpot',
      'Tomato___Early_blight': 'dsTomatoEarlyBlight',
      'Tomato___Late_blight': 'dsTomatoLateBlight',
      'Tomato___Leaf_Mold': 'dsTomatoLeafMold',
      'Tomato___Septoria_leaf_spot': 'dsTomatoSeptoria',
      'Tomato___Spider_mites Two-spotted_spider_mite': 'dsTomatoSpiderMites',
      'Tomato___Target_Spot': 'dsTomatoTargetSpot',
      'Tomato___Tomato_Yellow_Leaf_Curl_Virus': 'dsTomatoYellowCurl',
      'Tomato___Tomato_mosaic_virus': 'dsTomatoMosaic',
      'Tomato___healthy': 'dsTomatoHealthy',
    };

    return map[rawLabel.trim()];
  }

  static String getLocalizedLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    final jsonKey = getJsonKey(key) ?? key;

    switch (jsonKey) {
      case 'dsAppleScab':
        return l10n.dsAppleScab;
      case 'dsAppleBlackRot':
        return l10n.dsAppleBlackRot;
      case 'dsAppleCedarRust':
        return l10n.dsAppleCedarRust;
      case 'dsAppleHealthy':
        return l10n.dsAppleHealthy;
      case 'dsBlueberryHealthy':
        return l10n.dsBlueberryHealthy;
      case 'dsCherryPowderyMildew':
        return l10n.dsCherryPowderyMildew;
      case 'dsCherryHealthy':
        return l10n.dsCherryHealthy;
      case 'dsCornCercospora':
        return l10n.dsCornCercospora;
      case 'dsCornCommonRust':
        return l10n.dsCornCommonRust;
      case 'dsCornNorthernBlight':
        return l10n.dsCornNorthernBlight;
      case 'dsCornHealthy':
        return l10n.dsCornHealthy;
      case 'dsGrapeBlackRot':
        return l10n.dsGrapeBlackRot;
      case 'dsGrapeEsca':
        return l10n.dsGrapeEsca;
      case 'dsGrapeLeafBlight':
        return l10n.dsGrapeLeafBlight;
      case 'dsGrapeHealthy':
        return l10n.dsGrapeHealthy;
      case 'dsOrangeHLB':
        return l10n.dsOrangeHLB;
      case 'dsPeachBacterialSpot':
        return l10n.dsPeachBacterialSpot;
      case 'dsPeachHealthy':
        return l10n.dsPeachHealthy;
      case 'dsPepperBacterialSpot':
        return l10n.dsPepperBacterialSpot;
      case 'dsPepperHealthy':
        return l10n.dsPepperHealthy;
      case 'dsPotatoEarlyBlight':
        return l10n.dsPotatoEarlyBlight;
      case 'dsPotatoLateBlight':
        return l10n.dsPotatoLateBlight;
      case 'dsPotatoHealthy':
        return l10n.dsPotatoHealthy;
      case 'dsRaspberryHealthy':
        return l10n.dsRaspberryHealthy;
      case 'dsSoybeanHealthy':
        return l10n.dsSoybeanHealthy;
      case 'dsSquashPowderyMildew':
        return l10n.dsSquashPowderyMildew;
      case 'dsStrawberryLeafScorch':
        return l10n.dsStrawberryLeafScorch;
      case 'dsStrawberryHealthy':
        return l10n.dsStrawberryHealthy;
      case 'dsTomatoBacterialSpot':
        return l10n.dsTomatoBacterialSpot;
      case 'dsTomatoEarlyBlight':
        return l10n.dsTomatoEarlyBlight;
      case 'dsTomatoLateBlight':
        return l10n.dsTomatoLateBlight;
      case 'dsTomatoLeafMold':
        return l10n.dsTomatoLeafMold;
      case 'dsTomatoSeptoria':
        return l10n.dsTomatoSeptoria;
      case 'dsTomatoSpiderMites':
        return l10n.dsTomatoSpiderMites;
      case 'dsTomatoTargetSpot':
        return l10n.dsTomatoTargetSpot;
      case 'dsTomatoYellowCurl':
        return l10n.dsTomatoYellowCurl;
      case 'dsTomatoMosaic':
        return l10n.dsTomatoMosaic;
      case 'dsTomatoHealthy':
        return l10n.dsTomatoHealthy;
      default:
        return l10n.dsUnknown;
    }
  }
}
