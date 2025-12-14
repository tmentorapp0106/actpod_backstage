import 'package:web/web.dart';

class CookieUtils {
  static String? getCookie(String name) {
    final cookies = document.cookie.split('; ');
    for (final c in cookies) {
      final idx = c.indexOf('=');
      if (idx == -1) continue;
      final k = c.substring(0, idx);
      if (k == name) return Uri.decodeComponent(c.substring(idx + 1));
    }
    return null;
  }

  /// Set a cookie
  static void setCookie(
    String name,
    String value, {
    Duration? maxAge,
    DateTime? expires, // either maxAge or expires
    String path = '/',
    String? domain, // e.g. ".yourdomain.com" (must match current host rules)
    String sameSite = 'Lax', // 'Lax' | 'Strict' | 'None'
    bool secure = false,     // must be true when sameSite=None
  }) {
    final encoded = Uri.encodeComponent(value);
    final parts = <String>[
      '$name=$encoded',
      if (expires != null) 'Expires=${expires.toUtc().toIso8601String()}',
      if (maxAge != null) 'Max-Age=${maxAge.inSeconds}',
      'Path=$path',
      if (domain != null) 'Domain=$domain',
      'SameSite=$sameSite',
      if (secure) 'Secure',
    ];
    document.cookie = parts.join('; ');
  }

  /// Delete a cookie
  static void deleteCookie(String name, {String path = '/', String? domain}) {
    document.cookie = [
      '$name=',
      'Max-Age=0',
      'Path=$path',
      if (domain != null) 'Domain=$domain',
    ].join('; ');
  }
}