import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../localization/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('settings')),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSection(
            title: l10n.get('theme'),
            children: [
              SwitchListTile(
                title: Text(l10n.get(settingsProvider.isDarkMode ? 'dark_mode' : 'light_mode')),
                secondary: Icon(
                  settingsProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: settingsProvider.isDarkMode ? Colors.amber : Colors.blue,
                ),
                value: settingsProvider.isDarkMode,
                onChanged: (bool value) {
                  settingsProvider.toggleTheme();
                },
              ),
            ],
          ),
          _buildSection(
            title: l10n.get('language'),
            children: [
              RadioListTile<Locale>(
                title: Row(
                  children: [
                    Text(l10n.get('turkish')),
                    SizedBox(width: 8),
                    Text(
                      '🇹🇷',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                value: const Locale('tr', ''),
                groupValue: settingsProvider.locale,
                onChanged: (Locale? value) {
                  if (value != null) settingsProvider.setLocale(value);
                },
              ),
              RadioListTile<Locale>(
                title: Row(
                  children: [
                    Text(l10n.get('english')),
                    SizedBox(width: 8),
                    Text(
                      '🇬🇧',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                value: const Locale('en', ''),
                groupValue: settingsProvider.locale,
                onChanged: (Locale? value) {
                  if (value != null) settingsProvider.setLocale(value);
                },
              ),
            ],
          ),
          // Ayarlar hakkında bilgi kartı
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          l10n.get('settings_info'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      l10n.get('settings_description'),
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        Divider(),
      ],
    );
  }
}