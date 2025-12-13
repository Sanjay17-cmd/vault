import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/notes/notes_page.dart';

class VaultApp extends StatelessWidget
{
  const VaultApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Vault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const NotesPage(),
    );
  }
}
