import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';

class SignupScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  SignupScreen({required this.firebaseService});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  int preferredPortions = 2;
  String preferredStore = "Tesco";
  bool isLoading = false;

  void _signUpWithEmail() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => isLoading = true);
    var user = await widget.firebaseService.signUpWithEmail(
      emailController.text,
      passwordController.text,
      preferredPortions,
      preferredStore,
    );
    setState(() => isLoading = false);

    if (user != null) {
      print('Sign-up successful! Redirecting to recipes screen.');
      context.go('/recipes');
    } else {
      print('Sign-up failed.');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Signup failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 16),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 16),
            TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm Password')),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: preferredPortions,
              decoration: InputDecoration(labelText: 'Preferred Portions'),
              items: [1, 2, 3, 4, 5, 6]
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text('$e Portions')))
                  .toList(),
              onChanged: (value) => setState(() => preferredPortions = value!),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: preferredStore,
              decoration: InputDecoration(labelText: 'Preferred Store'),
              items: ['Tesco']
                  .map((store) =>
                      DropdownMenuItem(value: store, child: Text(store)))
                  .toList(),
              onChanged: (value) => setState(() => preferredStore = value!),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUpWithEmail,
              child: isLoading ? CircularProgressIndicator() : Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
