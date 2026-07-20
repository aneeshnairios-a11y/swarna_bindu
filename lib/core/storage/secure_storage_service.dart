import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage for anything sensitive: tokens, user id,
/// role. Backed by Keystore (Android) / Keychain (iOS).
/// NEVER put these values in SharedPreferences — see project rule in
/// GOLD_SCHEME_PROJECT_CONTEXT.md, Section 12.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kUserRole = 'user_role';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> get accessToken => _storage.read(key: _kAccessToken);

  Future<String?> get refreshToken => _storage.read(key: _kRefreshToken);

  /// Used by the refresh flow to rotate just the access token when the
  /// server doesn't issue a new refresh token on every call.
  Future<void> updateAccessToken(String accessToken) => _storage.write(key: _kAccessToken, value: accessToken);

  Future<void> saveUserId(String userId) => _storage.write(key: _kUserId, value: userId);

  Future<String?> get userId => _storage.read(key: _kUserId);

  Future<void> saveUserRole(String role) => _storage.write(key: _kUserRole, value: role);

  Future<String?> get userRole => _storage.read(key: _kUserRole);

  /// True once a refresh token exists — Splash uses this (not the access
  /// token, which expires in 15 min) to decide the first route.
  Future<bool> get hasSession async => (await refreshToken) != null;

  /// Called on manual logout AND on forced session expiry (refresh failed).
  Future<void> clearAll() => _storage.deleteAll();
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  return SecureStorageService(storage);
});
