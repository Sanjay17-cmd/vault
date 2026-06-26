import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../../../app.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _tokenController = TextEditingController();
  bool _vaultEnabled = false;
  bool _isDarkMode = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tokenController.text = prefs.getString('remindly_token') ?? '';
      _vaultEnabled = prefs.getBool('vault_enabled') ?? false;
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    });
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('remindly_token', token);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GitHub Token Saved')),
    );
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    setState(() {
      _isDarkMode = value;
    });
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _toggleVault(bool value) async {
    if (value) {
      bool authenticated = false;
      try {
        authenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to enable Vault',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
      } catch (e) {
        // Handle error
      }
      
      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('vault_enabled', true);
        setState(() {
          _vaultEnabled = true;
        });
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('vault_enabled', false);
      setState(() {
        _vaultEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Appearance', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark mode theme'),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Security', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Enable Vault'),
            subtitle: const Text('Protect locked notes & documents with biometrics/PIN'),
            value: _vaultEnabled,
            onChanged: _toggleVault,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('RemindLY Sync (GitHub Gist)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'GitHub Personal Access Token',
                hintText: 'ghp_...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => _saveToken(_tokenController.text),
                ),
              ),
              obscureText: true,
            ),
          ),
        ],
      ),
    );
  }
}
