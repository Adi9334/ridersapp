import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridersapp/Screens/LoginScreen.dart';
import 'package:ridersapp/Screens/ResetPassword.dart';
import 'package:ridersapp/Screens/global.dart';
import 'package:ridersapp/main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userid');
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('${APIservice.address}/RiderUser/OneRiderUser/$id'),
    );
    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      if(mounted){
      setState(() {
        _usernameController.text = userData['username'] ?? 'username';
        _phoneNumberController.text = userData['phone_number'] ?? 'phonenumber';
        _emailController.text = userData['email'] ?? 'email';
      });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState?.validate() ?? false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userid');

      final response = await http.put(
        Uri.parse('${APIservice.address}/Rideruser/updateRiderUser/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'phone_number': _phoneNumberController.text,
          'email': _emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  Future<void> _updatePassword() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Resetpassword()),
    );
  }

  void logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Logout"),
                  onPressed: () async {
                    final sharedPref = await SharedPreferences.getInstance();
                    await sharedPref.clear();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('userid');
      final response = await http.get(
        Uri.parse('${APIservice.address}/RiderUser/OneRiderUser/$id'),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final insertData = {
          'username': userData['username'],
          'email': userData['email'],
          'password': userData['password'],
          'phone_number': userData['phone_number'],
          'created_by': 'user',
          'is_active': true,
        };

        final insertResponse = await http.post(
          Uri.parse('${APIservice.address}/DeleteRiderUser/adddeleterideruser'),
          body: jsonEncode(insertData),
          headers: {'Content-Type': 'application/json'},
        );

        if (insertResponse.statusCode == 200) {
          final deleteResponse = await http.delete(
              Uri.parse('${APIservice.address}/RiderUser/deleteRiderUser/$id'));
          if (deleteResponse.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User deleted successfully')),
            );
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete user')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to archive user data')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background color
      appBar: AppBar(
        title: Center(child: Text('Profile', 
        style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ), 
        ),),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blueAccent], // Blue gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Card-like container
                  borderRadius: BorderRadius.circular(15),
                  
                ),
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  children: [
                    // Username field
                    Container(
                      margin: EdgeInsets.only(bottom: 10, top: 10),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          filled: true,
                          labelStyle: TextStyle(color: Colors.brown), // Label text color
                                hintStyle: TextStyle(color: Colors.brown), // Hint text color
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue), // Unfocused border color
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0), // Focused border color
                                ),
                                fillColor: Colors.grey[200],
                        ),
                        style: TextStyle(color: Colors.brown),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          }
                          return null;
                        },
                      ),
                    ),
          
                    // Phone number field
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number',
                          filled: true,
                          labelStyle: TextStyle(color: Colors.brown), // Label text color
                                hintStyle: TextStyle(color: Colors.brown), // Hint text color
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue), // Unfocused border color
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0), // Focused border color
                                ),
                                fillColor: Colors.grey[200],
                        ),
                        style: TextStyle(color: Colors.brown),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          final phoneRegex = RegExp(r'^\d{10}$');
                          if (!phoneRegex.hasMatch(value)) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                    ),
          
                    // Email field
                    Container(
                      margin: EdgeInsets.only(bottom: 32),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          filled: true,
                          labelStyle: TextStyle(color: Colors.brown), // Label text color
                                hintStyle: TextStyle(color: Colors.brown), // Hint text color
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue), // Unfocused border color
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0), // Focused border color
                                ),
                                fillColor: Colors.grey[200],
                        ),
                        style: TextStyle(color: Colors.brown),
                        keyboardType: TextInputType.emailAddress,
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
                    ),
          
                    // Update Profile button
                    ElevatedButton(
                      onPressed: _updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Update Profile',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
          
                    // Change Password button
                    ElevatedButton(
                      onPressed: _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Change Password',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
          
                    // Logout button
                    ElevatedButton(
                      onPressed: logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
          
                    // Delete Account button
                    ElevatedButton(
                      onPressed: () async {
                        bool? confirmDelete = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Delete"),
                              content: Text(
                                  "Are you sure you want to delete this account?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(false); // Cancel deletion
                                  },
                                ),
                                TextButton(
                                  child: Text("Delete"),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true); // Confirm deletion
                                  },
                                ),
                              ],
                            );
                          },
                        );
          
                        if (confirmDelete == true) {
                          await _deleteAccount();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Delete Account',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
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
    );
  }
}

class UpdatePasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Update Password Screen'),
      ),
    );
  }
}
