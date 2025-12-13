import 'package:flutter/material.dart';

class LockedNotesPage extends StatelessWidget
{
  const LockedNotesPage({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locked Notes'),
      ),
      body: const Center(
        child: Text(
          'Locked notebooks & notes appear here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
