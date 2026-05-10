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

  @EnviedField(varName: 'NEON_DATABASE_URL', obfuscate: true)
  static String neonDatabaseUrl = _Env.neonDatabaseUrl;

  @EnviedField(varName: 'GOOGLE_API_KEY', obfuscate: true)
  static String googleApiKey = _Env.googleApiKey;

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

  @EnviedField(varName: 'SUPABASE_PROJECT_URL', obfuscate: true)
  static String supabaseProjectUrl = _Env.supabaseProjectUrl;

  @EnviedField(varName: 'SUPABASE_API_KEY', obfuscate: true)
  static String supabaseApiKey = _Env.supabaseApiKey;

  @EnviedField(varName: 'SUPABASE_DATABASE_PASSWORD', obfuscate: true)
  static String supabaseDatabasePassword = _Env.supabaseDatabasePassword;

  @EnviedField(varName: 'SUPABASE_GOOGLE_CLIENT_ID', obfuscate: true)
  static String supabaseGoogleClientId = _Env.supabaseGoogleClientId;

  @EnviedField(varName: 'SUPABASE_GOOGLE_CLIENT_SECRET', obfuscate: true)
  static String supabaseGoogleClientSecret = _Env.supabaseGoogleClientSecret;

  @EnviedField(varName: 'SUPABASE_GOOGLE_CALLBACK', obfuscate: true)
  static String supabaseGoogleCallback = _Env.supabaseGoogleCallback;

  @EnviedField(varName: 'SUPABASE_GITHUB_CLIENT_ID', obfuscate: true)
  static String supabaseGithubClientId = _Env.supabaseGithubClientId;

  @EnviedField(varName: 'SUPABASE_GITHUB_CLIENT_SECRET', obfuscate: true)
  static String supabaseGithubClientSecret = _Env.supabaseGithubClientSecret;

  @EnviedField(varName: 'SUPABASE_GITHUB_CALLBACK', obfuscate: true)
  static String supabaseGithubCallback = _Env.supabaseGithubCallback;

  @EnviedField(varName: 'CALLBACK_METHOD', obfuscate: true)
  static String callbackMethod = _Env.callbackMethod;

  @EnviedField(varName: 'APP_UNIQUE_ID', obfuscate: true)
  static String appUniqueId = _Env.appUniqueId;

  @EnviedField(varName: 'APP_GUID', obfuscate: true)
  static String appGuid = _Env.appGuid;
}
