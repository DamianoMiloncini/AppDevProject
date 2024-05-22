import 'package:evolve/InitialPage.dart';
import 'package:flutter/material.dart';
import 'Session.dart';
import 'dart:convert';
// import 'dart:html';
import 'dart:io';
import 'package:evolve/SplashScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'HomePage.dart';
import 'Post.dart';
import 'CreateRoutine.dart';
import 'WorkoutPage.dart';
import 'Account.dart';
import 'logIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'accountSettings.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  String _errorMessage = "";
  String _successMessage = "";
  TextEditingController _currentPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();

  Future<void> _changePassword() async {
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Reauthenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPassword.text,
        );

        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(_newPassword.text);

        setState(() {
          _errorMessage = "";
          _successMessage = "Password changed successfully";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _successMessage = "";
        _errorMessage = "Incorrect inputs";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Define your custom back button behavior here
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AccountSettings()), // Change to your desired screen
            );
          },
        ),
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please fill in the following fields.',
                style: TextStyle(
                  color: Colors.white24,
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Container(
                  child: Column(
                    children: [
                      TextFormField(
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        controller: _currentPassword,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white10,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        controller: _newPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white10,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                _errorMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Text(
                _successMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(20, 24, 27, 1),
                  padding: EdgeInsetsDirectional.fromSTEB(32, 15, 32, 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(
                      color: Colors.white10,
                      width: 1,
                    ),
                  ),
                ),
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

