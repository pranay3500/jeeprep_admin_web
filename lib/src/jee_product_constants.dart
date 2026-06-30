/// JEE product identifiers — must match `jeeprep_flutter` and Firestore CMS docs.
abstract final class JeeProductConstants {
  static const String firebaseProjectId = 'jee-prep-app-16bd5';

  static const String examDateDocId = 'jee_main';

  static const String contentLibraryTreeApiUrl =
      'https://www.testprepkart.com/self-study/api/tree/content/jee/jee-planning';

  static const String updatesBrandLabel = 'JEE Updates';

  static const String appDisplayName = 'TestprepKart JEE';
  static const String appShortName = 'JEE Prep';
  static const String adminDisplayName = 'JEE Prep Admin';
  static const String supportEmail = 'jeeapp@testprepkart.in';
  static const String adminWebUrl = 'https://jeeappadmin.satlas.org';
  static const String expectedScoreLabel = 'Expected JEE Score';
  static const String parentsGuideLabel = 'JEE parents guide';
  static const String emailSenderName = 'TestprepKart JEE';
}
