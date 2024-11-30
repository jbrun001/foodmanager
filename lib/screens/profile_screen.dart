import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String id;

  ProfileScreen(
      {required this.id}); // Use `required` to make sure `id` is passed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: Text('Profile ID: $id'),
      ),
    );
  }
}
