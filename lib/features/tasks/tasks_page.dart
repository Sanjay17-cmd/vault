import 'package:flutter/material.dart';

class TasksPage extends StatelessWidget
{
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: const Center(
        child: Text(
          'Tasks Page',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
