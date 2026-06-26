import 'package:flutter/material.dart';

class VaultPage extends StatelessWidget
{
  const VaultPage({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
      ),
      body: const Center(
        child: Text(
          'Authentication required',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
