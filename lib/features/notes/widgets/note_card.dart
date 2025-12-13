import 'package:flutter/material.dart';
import '../model/note_model.dart';

class NoteCard extends StatelessWidget
{
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context)
  {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (note.isLocked)
                  const Icon(
                    Icons.lock,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
