import 'package:flutter/material.dart';

class DocumentsPage extends StatelessWidget
{
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: const Center(
        child: Text(
          'Documents Page',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
