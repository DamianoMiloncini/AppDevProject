import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'createAccount.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'InitialPage.dart';
import 'package:provider/provider.dart';
import 'Session.dart'; // Import the user provider

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePageWidget()
    );
  }
}


class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            height: 462,
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: Image.asset(
                  'assets/gymphoto.jpg',
                ).image,
              ),
              shape: BoxShape.rectangle,
            ),
          ),
          Container(
            width: double.infinity,
            height: 321,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 35, 0, 0),
                  child: Text(
                    'Welcome to',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.white,
                      fontSize: 25,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_gymnastics,
                      color: Colors.white,
                      size: 35,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                      child: Text(
                        'Evolve',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.white,
                          fontSize: 36,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Opacity(
                  opacity: 0.5,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 15),
                    child: Text(
                      'Join the most immerse gym environment',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white54,
                        fontSize: 14,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(25, 5, 25, 0),
                  child: ElevatedButton(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apple_sharp, color: Colors.black,),
                          SizedBox(width: 5),
                          Center(
                            child: Text('Continue with Apple', style: TextStyle(color: Colors.black),),
                          )
                        ],
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(25, 5, 25, 0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignInPage())
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mail, color: Colors.white,),
                          SizedBox(width: 5),
                          Text('Continue with email', style: TextStyle(color: Colors.white),),
                        ],
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Dont have an account yet?',
                        style:
                        TextStyle(
                          color: Colors.white24,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          letterSpacing: 0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreateAccount())
                            );
                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: Colors.deepOrangeAccent,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String _errorMessage = "";
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();

  Future<void> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Fetch user data after successful sign-in
        await Provider.of<UserProvider>(context, listen: false).fetchUserData();
        print('User signed in: ${user.uid}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => InitialPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = "Invalid email and/or password";
      });
      print('Failed with error code: ${e.code}');
      print(e.message);
      // Handle sign-in errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
                color: Color.fromRGBO(20, 24, 27, 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 50),
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
                      'Log In',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Outfit',
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                )
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              obscureText: true,
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
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                )
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
                          color: Colors.red
                      ),
                    ),
                    SizedBox(height: 15,),
                    ElevatedButton(
                      onPressed: () {
                        signInUser(email.text, password.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(20, 24, 27, 1),
                        padding: EdgeInsetsDirectional.fromSTEB(32, 15, 32, 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                            side: BorderSide(
                              color: Colors.white10,
                              width: 1,
                            )
                        ),
                      ),
                      child: Text('Log In'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePageWidget())
                        );
                      },
                      child: Text('Dont have an account', style: TextStyle(color: Colors.white24, fontSize: 12),),
                    ),

                  ],
                )
            )

        )
    );
  }
}

