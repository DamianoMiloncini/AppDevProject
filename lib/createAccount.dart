import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'InitialPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CreateAccount());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CreateAccount()
    );
  }
}

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String _errorMessage = "";
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();




  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');


  Future<void> registerUser(String email, String username, String password) async {
    try {
      // Create a user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // Check if the username is already taken
      DocumentSnapshot documentSnapshot = await users.doc(user?.uid).get();
      if (documentSnapshot.exists) {
        setState(() {
          _errorMessage = "Username already in use";
        });
        await user?.delete();
        throw FirebaseAuthException(

          code: 'username-already-in-use',
          message: 'The username is already in use by another account.',
        );


      }

      // Save user details to Firestore
      await users.doc(user?.uid).set({
        'uid': user?.uid,
        'username': username,
        'email': email,
        // Never store passwords in Firestore
      });

      print('User registered and details added to Firestore');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => InitialPage()),
      );
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
      if (e.code == 'email-already-in-use') {
        // Handle error when the email is already in use
      } else if (e.code == 'weak-password') {
        // Handle error for weak password
      } else if (e.code == 'username-already-in-use') {
        // Handle error for username already in use
      }
    } catch (e) {
      print('Failed to add user: $e');
    }
  }

  Future<void> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        print('User signed in: ${user.uid}');
        // Navigate to the home page or do something else
      }
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
      // Handle sign-in errors here
    }
  }

  Future<void> signOutUser() async {
    await _auth.signOut();
    print('User signed out');
  }



  Future<void> addUser() async{
    DocumentSnapshot documentSnapshot = await users.doc(username.text).get();
    if (documentSnapshot.exists) {
      setState(() {
        _errorMessage = "Username already in use";
      });
    }

    //customize the name of the document so that its not a random ass string
    DocumentReference newPosts = users.doc(username.text);
    return newPosts.set({
      //add the photo link later
      'username': username.text,
      'password': password.text,
    })
        .then((value) => print('posts added to firebase'))
        .catchError((error) => print('failed to add the posts to firebase $error')
    );
  }






  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Center(
                child: Container(
                    color: Color.fromRGBO(20, 24, 27, 1),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 100, 0, 45),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sports_gymnastics_outlined,
                                color: Colors.white,
                                size: 35,
                              ),
                              SizedBox(width: 10,),
                              Text(
                                'Evolve',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Outfit',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10,),
                        Text(
                          'Create an account',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Outfit',
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Lets get started by filling out the form below.',
                          style: TextStyle(
                            color: Colors.white24,
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextFormField(
                            style: TextStyle(
                                color: Colors.white
                            ),
                            controller: email,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white10,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            )
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                            style: TextStyle(
                                color: Colors.white
                            ),
                            controller: username,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white10,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            )
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            controller: password,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white10,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            )
                        ),
                        SizedBox(height: 10,),
                        Text(
                          _errorMessage,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            registerUser(email.text, username.text, password.text);
                          },
                          child: Text('Create Account'),
                        ),

                      ],
                    )
                )

            )
        )
    );
  }
}

