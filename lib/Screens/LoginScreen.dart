import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ridersapp/Screens/PickupDelivery.dart';
import 'package:ridersapp/Screens/SignupScreen.dart';
import 'package:ridersapp/Screens/global.dart';
import 'package:ridersapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final response = await http.post(
        Uri.parse('${APIservice.address}/RiderUser/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userId = responseData['user']['id'].toString();
        if(userId == ''){
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userid', userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect password')),
        );
      } else if (response.statusCode == 404) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignupScreen(email: email)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Login',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blueAccent], // Blue gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            height: 500,
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white, // Solid color for the login container
              border: Border.all(color: Colors.blueAccent, width: 2), // Border color and width
              borderRadius: BorderRadius.circular(12.0), // Border radius
            ),
            padding: EdgeInsets.all(20),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600), // Constrain the max width
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Center vertically
                        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              labelStyle: TextStyle(color: Colors.brown), // Label text color
                              hintStyle: TextStyle(color: Colors.brown), // Hint text color
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Unfocused border color
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2.0), // Focused border color
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.brown), // Input text color
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),



                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              labelStyle: TextStyle(color: Colors.brown), // Label text color
                              hintStyle: TextStyle(color: Colors.brown), // Hint text color
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Unfocused border color
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2.0), // Focused border color
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.brown, // Brown color for the eye icon
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            style: TextStyle(color: Colors.brown), // Input text color
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 4) {
                                return 'Password must be at least 4 characters';
                              }
                              return null;
                            },
                          ),



                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Button color
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 0.0), // Match button width to text field
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 5,
                              minimumSize: Size(double.infinity, 48), // Match button width to text field
                            ),
                            child:Text('Login', 
                            style: GoogleFonts.nunito( // Removed the const keyword
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignupScreen()),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue, // Button color
                            ),
                            child: Text("Don't have an account? Sign up",
                              style: GoogleFonts.nunito( // Removed the const keyword
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
