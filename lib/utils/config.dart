/// Build variants
class Config {
  /// App version (shown in InfoPage)
  static const String version = '3.0.1';

  /// True: hide donation link in InfoPage (due to Play Store policies)
  static const bool hideDonationInfo = false;

  /// True: hide worker in 1.tmx (postgame)
  static const bool hideDonationWorker = false;

  /// URLs
  static const String websiteUrl = 'https://deepdaikon.xyz';
  static const String donateUrl = 'https://deepdaikon.xyz/donate';
  static const String translateUrl =
      'https://translate.deepdaikon.xyz/engage/xeonjia/';
  static const String mailTo =
      'mailto:deepdaikon' '@' 'tuta.io?subject=Xeonjia Game';
  static const String bugTrackerUrl =
      'https://gitlab.com/deepdaikon/Xeonjia/issues';
  static const String sourceCodeUrl = 'https://gitlab.com/deepdaikon/Xeonjia';
  static const String licenseUrl =
      'https://gitlab.com/deepdaikon/Xeonjia/blob/master/LICENSE';
}
