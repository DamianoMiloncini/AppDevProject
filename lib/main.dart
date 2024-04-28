import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: '', //dont have it
      appId: '1:889471056206:android:804e862797cf6b03ec461f', // This is your App ID
      messagingSenderId: '', //dont have it
      projectId: 'evolve-6a292', //Project ID
      storageBucket: '', // we dont have it
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Stream<QuerySnapshot> _userStream =
  FirebaseFirestore.instance.collection('users').snapshots();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String name = '';

  Future<void> addUser() {
    return users
        .add({
      'name': name,
    })
        .then((value) => print("user added"))
        .catchError((error) => print("failed to add the user "));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Firestore Demo'),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Enter user name',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: InputDecoration(
                      hintText: 'This could be your password',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      )),
                ),
                SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                    onPressed: () {
                      addUser();
                    },
                    child: Text('Adding user to the cloud')),
                SizedBox(
                  height: 10.0,
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: _userStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading');
                      }
                      return ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                          return ListTile(
                            title: Text(data['name']),
                          );
                        }).toList(),
                      );
                    }),
              ],
            ),
          ),
        ));
  }
}
