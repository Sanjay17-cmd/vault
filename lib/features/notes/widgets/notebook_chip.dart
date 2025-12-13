import 'package:flutter/material.dart';
import '../model/notebook_model.dart';

class NotebookChip extends StatelessWidget
{
  final Notebook notebook;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  const NotebookChip({
    super.key,
    required this.notebook,
    required this.onTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notebook.name),
              const SizedBox(width: 4),
              if (notebook.isLocked)
                const Icon(
                  Icons.lock,
                  size: 14,
                ),
              GestureDetector(
                onTap: onMenuTap,
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.more_vert,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
