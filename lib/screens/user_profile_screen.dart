import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'menu_drawer.dart';

class UserProfileScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const UserProfileScreen({required this.firebaseService, Key? key})
      : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // profile fields.
  String email = '';
  int? preferredPortions;
  String? preferredStore;

  // Store options loaded from \Stores in firebase
  List<String> storeOptions = [];

  bool isLoading = true;

  // Options for the portions select field - int from 1 to 10
  final List<int> portionsOptions = List.generate(10, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // load user details and store list.
  Future<void> _loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Load user details.
      final data = await widget.firebaseService.getUserDetails(user.uid);
      if (data != null) {
        email = data['email'] ?? '';
        preferredPortions = data['preferredPortions'] != null
            ? data['preferredPortions'] as int
            : portionsOptions.first;
      }
      // load store options from the "Stores" collection.
      List<String> stores = await widget.firebaseService.getStores();
      setState(() {
        storeOptions = stores;
        preferredStore = (data != null && data['preferredStore'] != null)
            ? data['preferredStore']
            : stores.first;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // updates user profile using the FirebaseService method
  Future<void> _updateProfile() async {
    if ((_formKey.currentState?.validate() ?? false) &&
        preferredPortions != null &&
        preferredStore != null) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await widget.firebaseService.updateUserProfile(
          userId: user.uid,
          email: email, // email remains read-only.
          preferredPortions: preferredPortions!,
          preferredStore: preferredStore!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  // sends a password reset email to the users email address
  // functionality of firebase see:
  // https://firebase.google.com/docs/auth/web/manage-users
  Future<void> _resetPassword() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    // find out if the user authenticated with email/password
    // if they are then we can display a reset password button
    // else we can't because authentication is provided by google or
    // another provider
    final bool isEmailPasswordUser =
        user?.providerData.any((info) => info.providerId == 'password') ??
            false;

    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      drawer: MenuDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : user == null
              ? Center(child: Text('No user logged in'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Row with email field and Reset Password button on the right.
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: email,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                readOnly: true,
                              ),
                            ),
                            if (isEmailPasswordUser) SizedBox(width: 16),
                            if (isEmailPasswordUser)
                              ElevatedButton(
                                onPressed: _resetPassword,
                                child: Text('Reset Password'),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Preferred Portions dropdown.
                        DropdownButtonFormField<int>(
                          value: preferredPortions,
                          decoration: InputDecoration(
                            labelText: 'Preferred Portions',
                            border: OutlineInputBorder(),
                          ),
                          items: portionsOptions.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              preferredPortions = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select preferred portions';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        // Preferred Store dropdown loaded from the "Store" collection.
                        DropdownButtonFormField<String>(
                          value: preferredStore,
                          decoration: InputDecoration(
                            labelText: 'Preferred Store',
                            border: OutlineInputBorder(),
                          ),
                          items: storeOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              preferredStore = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a preferred store';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          child: Text('Update Profile'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
