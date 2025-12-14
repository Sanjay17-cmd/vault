import 'package:flutter/material.dart';
import '../model/notebook_model.dart';

class NotebookChip extends StatelessWidget
{
  final Notebook notebook;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  const NotebookChip({
    super.key,
    required this.notebook,
    required this.isActive,
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
          label: Text(
            notebook.name,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor:
          isActive ? Colors.blue : Colors.grey.shade200,
        ),
      ),
    );
  }
}
