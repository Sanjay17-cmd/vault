import 'package:flutter/material.dart';
import 'data/dummy_notes.dart';
import 'widgets/note_card.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index)
          {
            return NoteCard(note: notes[index]);
          },
        ),
      ),
    );
  }
}
