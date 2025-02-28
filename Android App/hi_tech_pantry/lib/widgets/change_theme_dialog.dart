import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../utils/theme_provider.dart';

class ChangeThemeDialog extends StatefulWidget {
  const ChangeThemeDialog({super.key});

  @override
  State<ChangeThemeDialog> createState() => _ChangeThemeDialogState();
}

class _ChangeThemeDialogState extends State<ChangeThemeDialog> {

  late String selectedTheme;

  @override
  void initState() {
    super.initState();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    switch (themeProvider.currentThemeMode) {
      case ThemeMode.light:
        selectedTheme = 'light';
        break;
      case ThemeMode.dark:
        selectedTheme = 'dark';
        break;
      case ThemeMode.system:
        selectedTheme = 'system';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade100,
      title: Text('Change Theme', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
      contentTextStyle: TextStyle(color: isDarkMode ? const Color.fromARGB(255, 110, 107, 107) : Colors.black),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: Colors.blue.shade700,
            value: 'system',
            groupValue: selectedTheme,
            onChanged: (value) {
              setState(() {
                selectedTheme = 'system';
              });
            },
            selected: selectedTheme == 'system',
            title: const Text('System Default'),
          ),
          RadioListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: Colors.blue.shade700,
            value: 'light',
            groupValue: selectedTheme,
            onChanged: (value) {
              setState(() {
                selectedTheme = 'light';
              });
            },
            selected: selectedTheme == 'light',
            title: const Text('Light'),
          ),
          RadioListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: Colors.blue.shade700,
            value: 'dark',
            groupValue: selectedTheme,
            onChanged: (value) {
              setState(() {
                selectedTheme = 'dark';
              });
            },
            selected: selectedTheme == 'dark',
            title: const Text('Dark'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text('Cancel', style: TextStyle(fontSize: 24, color: Colors.blue.shade700)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  minimumSize: Size(80, 40),
                ),
                onPressed: () {
                  themeProvider.changeTheme(selectedTheme);
                  context.pop();
                },
                child: const Text('Change'),
              ),
            ],
          )
        ],
      ),
    );
  }
}