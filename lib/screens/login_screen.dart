import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  LoginScreen({required this.firebaseService});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void _loginWithEmail() async {
    setState(() => isLoading = true);
    print("Attempting to log in with email: ${emailController.text}");

    var user = await widget.firebaseService.signInWithEmail(
      emailController.text,
      passwordController.text,
    );
    setState(() => isLoading = false);

    if (user != null) {
      print("Login successful! Redirecting to recipes screen.");
      context.go('/recipes');
    } else {
      print("Login failed.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials. Try again.')),
      );
    }
  }

  void _loginWithGoogle() async {
    setState(() => isLoading = true);
    print("Attempting Google Sign-In");

    var user = await widget.firebaseService.signInWithGoogle();
    setState(() => isLoading = false);

    if (user != null) {
      print("Google Login successful! Redirecting to recipes screen.");
      context.go('/recipes');
    } else {
      print("Google Login failed.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login failed. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Icon(
                Icons.kitchen_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Food Manager',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Email TextField
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 16),

            // Password TextField
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: _loginWithEmail,
              child: isLoading ? CircularProgressIndicator() : Text('Login'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 10),

            // Google Login Button
            ElevatedButton.icon(
              onPressed: _loginWithGoogle,
              icon: Icon(Icons.login),
              label: Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 10),

            // Sign Up Option
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    print("Navigating to Sign-Up screen.");
                    context.go('/signup'); // Navigate to Sign-Up
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
