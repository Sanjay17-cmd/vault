import 'package:flutter/material.dart';

class NotesPage extends StatelessWidget
{
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: ()
            {
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: ()
            {
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Notes will appear here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
