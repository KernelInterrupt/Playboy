import 'package:flutter/material.dart';
import 'package:playboy/backend/storage.dart';
import 'package:playboy/backend/utils/l10n_utils.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              '显示语言'.l10n,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          RadioListTile(
            title: const Text('简体中文'),
            value: 'zh_hans',
            groupValue: AppStorage().settings.language,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  AppStorage().settings.language = value;
                });
                AppStorage().saveSettings();
                AppStorage().updateStatus();
              }
            },
          ),
          RadioListTile(
            title: const Text('English (US)'),
            value: 'en_us',
            groupValue: AppStorage().settings.language,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  AppStorage().settings.language = value;
                });
                AppStorage().saveSettings();
                AppStorage().updateStatus();
              }
            },
          ),
        ],
      ),
    );
  }
}
