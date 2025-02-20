import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'menu_drawer.dart';

class UserProfileScreen extends StatelessWidget {
  final FirebaseService firebaseService;

  UserProfileScreen({required this.firebaseService});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      drawer: MenuDrawer(),
      body: Center(
        child: user != null
            ? Text('User ID: ${user.uid}')
            : Text('No user logged in'),
      ),
    );
  }
}
