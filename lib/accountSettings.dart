import 'package:evolve/InitialPage.dart';
import 'package:flutter/material.dart';
import 'Session.dart';
import 'package:evolve/SplashScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'ChangePassword.dart';


class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> signOutUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Define your custom back button behavior here
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => InitialPage()), // Change to your desired screen
            );
          },
        ),
      ),
      body: Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue
                            ),
                          ),
                          SizedBox(height: 5,),
                          Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            userProvider.user!.username,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '**********',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => ChangePassword()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsetsDirectional.fromSTEB(22, 5, 22, 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                                  side: BorderSide(
                                    color: Colors.white10,
                                    width: 1,
                                  )
                              ),
                            ),
                            child: Text('Change Password'),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Account',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: Text('Phone Number'),
                          ),
                          ListTile(
                            leading: Icon(Icons.email),
                            title: Text('Email'),
                          ),
                          ListTile(
                            onTap: () {
                              signOutUser(context);
                            },
                            leading: Icon(Icons.logout),
                            title: Text('Sign Out'),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Security',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.notifications),
                            title: Text('Notifications'),
                            trailing: Switch(
                              value: false, // Set initial value here
                              onChanged: (newValue) {
                                // Handle switch state change here
                              },
                            ),
                          ),

                        ],
                      )
                  ),
                )
              ]

            ),
      ),
    );
  }
}

