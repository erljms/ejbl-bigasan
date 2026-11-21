/// Supabase runtime configuration supplied via `--dart-define`.
///
/// Never commit real URLs/keys or use the `sb_secret_` / `service_role` key
/// in client code. Only the public `sb_publishable_` / `anon` key belongs here.
class SupabaseConfig {
  static const String _rawUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _rawAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Normalized project URL (strips accidental whitespace or trailing slashes).
  static String get url =>
      _rawUrl.trim().replaceFirst(RegExp(r'/+$'), '');

  static String get anonKey => _rawAnonKey.trim();

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
