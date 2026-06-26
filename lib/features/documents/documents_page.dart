import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<Map<String, String>> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final docsJson = prefs.getStringList('documents') ?? [];
    setState(() {
      _documents = docsJson.map((d) => Map<String, String>.from(jsonDecode(d))).toList();
    });
  }

  Future<void> _saveDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final docsJson = _documents.map((d) => jsonEncode(d)).toList();
    await prefs.setStringList('documents', docsJson);
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      setState(() {
        _documents.add({
          'name': file.name,
          'path': file.path!,
          'extension': file.extension ?? 'unknown',
        });
      });
      _saveDocuments();
    }
  }

  void _openFile(String path) {
    OpenFile.open(path);
  }

  void _deleteDocument(int index) {
    setState(() {
      _documents.removeAt(index);
    });
    _saveDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: _documents.isEmpty
          ? const Center(child: Text('No documents added.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final doc = _documents[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                    title: Text(doc['name'] ?? 'Unknown'),
                    subtitle: Text(doc['extension']?.toUpperCase() ?? ''),
                    onTap: () => _openFile(doc['path']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDocument(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        child: const Icon(Icons.add),
      ),
    );
  }
}
