import 'dart:convert';
// import 'dart:html';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'HomePage.dart';
import 'Post.dart';
import 'Account.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
//need a stful widget for the app theme
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

}

class _MyAppState extends State<MyApp> {
  //variable to set a state field for the theme
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            color: Colors.blueGrey,
            centerTitle: true,
            titleTextStyle: TextStyle(color: Colors.white)
        ),
        drawerTheme: DrawerThemeData(backgroundColor: Colors.blueGrey,),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.blueGrey)
      ),
      home: InitialPage(),
      darkTheme: ThemeData.dark(), //set what dark theme is
      themeMode: _themeMode, //use the variable so that I can change its state
    );
  }
  //call this method in the buttons to change the theme from light to dark and vice versa
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}


class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  //list of pages for the nav bar buttons
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    Post(),
    Account(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //not sure if the app bar should just display the name of the app at all times or it should change names according to the page name yk?
        title: Text('Evolve',style: TextStyle(fontSize: 40,fontWeight: FontWeight.w600),),
        toolbarHeight: 60.2,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(5),
              bottomLeft: Radius.circular(5)),
        ),
        elevation: 0.00,
        //backgroundColor: Colors.blueGrey,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,//color for the icon when that current page is being displayed
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.post_add),
              label: 'New Post',

          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Account'
          ),
        ],
      ),
      body:
      //i love putting stuff in containers, i cant help it
      Container(
        child: _pages.elementAt(_selectedIndex), //New
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            //TODO: You can change to your liking honestly
            const UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                    color: Colors.white38
                ),
                //for now, this is HardCoded but fetch from database later on !!
                accountName: Text('Micka'),
                accountEmail: Text('micka@gmail.com'),
                currentAccountPicture: //should we allow the user to upload their picture? Should we give the user options of profile pictures to choose from ?,
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.lightGreen,
                  child: Text('M',style: TextStyle(fontSize: 30),),
                ),
            ),
            //account tile
            ListTile(
              //something is bothering me with the way this is styled but whateva
              leading: const Icon(Icons.account_circle_outlined,size: 30,),
              title: const Text('Account Settings'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                //push to User settings page
              },
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                //light theme button
                ElevatedButton(onPressed: () {
                  MyApp.of(context).changeTheme(ThemeMode.light);
                  Navigator.pop(context); //to close the drawer after the user clicks the button
                } ,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //little sun
                    Icon(Icons.wb_sunny_outlined),
                    SizedBox(width: 5,),
                    Text('Light Mode')
                  ],
                ),
                ),
                SizedBox(width: 5,),
                ElevatedButton(onPressed: () {
                  MyApp.of(context).changeTheme(ThemeMode.dark);
                  Navigator.pop(context); //to close the drawer after the user clicks the button
                },
                  child: Row(
                  children: [
                    //little moon
                    Icon(Icons.dark_mode_outlined),
                    SizedBox(width: 5,),
                    Text('Dark Mode')
                  ],
                ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

//new post page









