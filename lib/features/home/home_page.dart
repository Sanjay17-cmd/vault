import 'package:flutter/material.dart';
import '../notes/notes_page.dart';
import '../documents/documents_page.dart';
import '../tasks/tasks_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget
{
  const HomePage({super.key});

  @override
  State<HomePage> createState()
  {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
{
  int _currentIndex = 0;

  final List<Widget> _pages =
  [
    const NotesPage(),
    const DocumentsPage(),
    const TasksPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index)
        {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
