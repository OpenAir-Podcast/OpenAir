import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static String apiKey = _Env.apiKey;

  @EnviedField(varName: 'PODCAST_INDEX_API_KEY', obfuscate: true)
  static String podcastIndexApiKey = _Env.podcastIndexApiKey;

  @EnviedField(varName: 'PODCAST_INDEX_API_SECRET', obfuscate: true)
  static String podcastIndexApiSecret = _Env.podcastIndexApiSecret;

  @EnviedField(varName: 'PODCAST_USER_AGENT', obfuscate: true)
  static String podcastUserAgent = _Env.podcastUserAgent;

  @EnviedField(varName: 'OAUTH_CLIENT_ID', obfuscate: true)
  static String oauthClientId = _Env.oauthClientId;

  @EnviedField(varName: 'OAUTH_CLIENT_SECRET', obfuscate: true)
  static String oauthClientSecret = _Env.oauthClientSecret;

  @EnviedField(varName: 'FYYD_CLIENT_ID', obfuscate: true)
  static String fyydClientId = _Env.fyydClientId;

  @EnviedField(varName: 'FYYD_CLIENT_SECRET', obfuscate: true)
  static String fyydClientSecret = _Env.fyydClientSecret;

  @EnviedField(varName: 'FYYD_ACCESS_TOKEN', obfuscate: true)
  static String fyydAccessToken = _Env.fyydAccessToken;

  @EnviedField(varName: 'FYYD_USER_ACCESS_TOKEN', obfuscate: true)
  static String fyydUserAccessToken = _Env.fyydUserAccessToken;

  @EnviedField(varName: 'TADDY_API_KEY', obfuscate: true)
  static String taddyApiKey = _Env.taddyApiKey;

  @EnviedField(varName: 'TADDY_USER_ID', obfuscate: true)
  static String taddyUserId = _Env.taddyUserId;

  @EnviedField(varName: 'PAYPAL_URL', obfuscate: true)
  static String paypalUrl = _Env.paypalUrl;

  @EnviedField(varName: 'DONATE_WITH_KOFI_URL', obfuscate: true)
  static String donateWithKofiUrl = _Env.donateWithKofiUrl;

  @EnviedField(varName: 'DISCORD_URL', obfuscate: true)
  static String discordUrl = _Env.discordUrl;

  @EnviedField(varName: 'GITHUB_ISSUES_URL', obfuscate: true)
  static String githubIssuesUrl = _Env.githubIssuesUrl;

  @EnviedField(varName: 'GITHUB_DISCUSSION_URL', obfuscate: true)
  static String githubDiscussionUrl = _Env.githubDiscussionUrl;

  @EnviedField(varName: 'PRIVACY_POLICY', obfuscate: true)
  static String privacyPolicy = _Env.privacyPolicy;

  @EnviedField(varName: 'GITHUB_URL', obfuscate: true)
  static String githubUrl = _Env.githubUrl;

  @EnviedField(varName: 'TERMS_OF_SERVICE', obfuscate: true)
  static String termsOfService = _Env.termsOfService;

  @EnviedField(varName: 'FIREBASE_API_KEY', obfuscate: true)
  static String firebaseApiKey = _Env.firebaseApiKey;

  @EnviedField(varName: 'FIREBASE_APP_ID', obfuscate: true)
  static String firebaseAppId = _Env.firebaseAppId;

  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID', obfuscate: true)
  static String firebaseMessagingSenderId = _Env.firebaseMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_PROJECT_ID', obfuscate: true)
  static String firebaseProjectId = _Env.firebaseProjectId;

  @EnviedField(varName: 'FIREBASE_AUTH_DOMAIN', obfuscate: true)
  static String firebaseAuthDomain = _Env.firebaseAuthDomain;

  @EnviedField(varName: 'FIREBASE_STORAGE_BUCKET', obfuscate: true)
  static String firebaseStorageBucket = _Env.firebaseStorageBucket;

  @EnviedField(varName: 'FIREBASE_ANDROID_CLIENT_ID', obfuscate: true)
  static String firebaseAndroidClientId = _Env.firebaseAndroidClientId;

  @EnviedField(varName: 'FIREBASE_IOS_CLIENT_ID', obfuscate: true)
  static String firebaseIosClientId = _Env.firebaseIosClientId;

  @EnviedField(varName: 'FIREBASE_IOS_BUNDLE_ID', obfuscate: true)
  static String firebaseIosBundleId = _Env.firebaseIosBundleId;

  @EnviedField(varName: 'APP_UNIQUE_ID', obfuscate: true)
  static String appUniqueId = _Env.appUniqueId;

  @EnviedField(varName: 'APP_GUID', obfuscate: true)
  static String appGuid = _Env.appGuid;
}
