import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isVaultEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vault_enabled') ?? false;
  }

  static Future<bool> authenticate() async {
    try {
      final isEnabled = await isVaultEnabled();
      if (!isEnabled) return true; // If vault is not enabled, let them in

      return await _auth.authenticate(
        localizedReason: 'Authenticate to access Vault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      debugPrint('Auth error: $e');
      return false;
    }
  }
}