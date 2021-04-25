import 'package:flutter/material.dart';

class KgmsAccounts extends StatelessWidget {
  const KgmsAccounts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kgms Accounts'),
      ),
      body: Center(
        child: const Icon(
          Icons.beach_access,
          color: Colors.green,
          size: 30.0,
        ),
      ),
    );
  }
}
