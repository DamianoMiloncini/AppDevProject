import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'logIn.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 4175, // Duration in milliseconds
      splash: Column(
        children: [
          Center(
            child: Column(
              children: [
                //ColorFiltered(
                  //colorFilter: ColorFilter.mode(
                  //  Colors.white, // Change to the desired color
                  //  BlendMode.srcIn,
                  //),
                  //child:
                  Lottie.network(
                    "https://lottie.host/f8a35b2e-4a4d-4168-8bb0-0a6b543abd50/HjrOaH6wWk.json",
                    width: 300,
                  ),
                //),
                SizedBox(height: 35,),
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
              ],
            ),
          ),
        ],
      ),
      nextScreen: const HomePageWidget(),
      splashIconSize: 400,
      backgroundColor: Colors.white10,
    );
  }
}