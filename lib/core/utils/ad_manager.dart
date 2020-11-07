import 'dart:io';

class AdManager {

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7948387784162370~5920179007";
    } else if (Platform.isIOS) {
      throw new UnsupportedError("Unsupported platform");
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2738717590914658/3401126173";
    } else if (Platform.isIOS) {
      throw new UnsupportedError("Unsupported platform");
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2738717590914658/7763699551";
    } else if (Platform.isIOS) {
      throw new UnsupportedError("Unsupported platform");
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "";
    } else if (Platform.isIOS) {
      throw new UnsupportedError("Unsupported platform");
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}