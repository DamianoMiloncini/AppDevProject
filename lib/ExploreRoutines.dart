import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'Session.dart';
import 'PostFromRoutine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExploreRoutines(),
    );
  }
}

class ExploreRoutines extends StatefulWidget {
  const ExploreRoutines({Key? key}) : super(key: key);

  @override
  State<ExploreRoutines> createState() => _ExploreRoutinesState();
}

class _ExploreRoutinesState extends State<ExploreRoutines> {
  String _heading = 'Explore Routines';
  List<ListCard> _routines = [];

  @override
  void initState() {
    super.initState();
    fetchAllRoutines();
  }

  Future<void> fetchYourRoutines(String uid) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('routines')
          .where('uid', isEqualTo: uid)
          .get();
      print("Number of documents fetched: ${querySnapshot.docs.length}");
      setState(() {
        _routines = querySnapshot.docs.map((doc) {
          print("Document data: ${doc.data()}");
          return ListCard(
            title: doc['title'] ?? 'No Title',
            description: doc['description'] ?? 'No Description',
            uid: doc['uid'] ?? 'No UID',
            id: doc.id, // Use Firestore document ID as the unique identifier
            onTap: (uid, id) {
              print("Tapped UID: $uid and ID: $id");
              // Handle the tap event with the UID and document ID
            },
          );
        }).toList();
        print("Number of routines: ${_routines.length}");
      });
    } catch (e) {
      print("Error fetching routines: $e");
    }
  }

  Future<void> fetchAllRoutines() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('routines').get();
      print("Number of documents fetched: ${querySnapshot.docs.length}");
      setState(() {
        _routines = querySnapshot.docs.map((doc) {
          print("Document data: ${doc.data()}");
          return ListCard(
            title: doc['title'] ?? 'No Title',
            description: doc['description'] ?? 'No Description',
            uid: doc['uid'] ?? 'No UID',
            id: doc['id'] ?? 'No ID',
            onTap: (uid, id) {
              print("Tapped UID: $uid and $id");
              // Handle the tap event with the UID
            },
          );
        }).toList();
        print("Number of routines: ${_routines.length}");
      });
    } catch (e) {
      print("Error fetching routines: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore Routines',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
        ),
      ),
      body: Center(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _heading = "Explore Routines";
                        fetchAllRoutines();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsetsDirectional.fromSTEB(15, 15, 15, 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 10,),
                        Text('Explore Routines'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _heading = "Your Routines";
                        fetchYourRoutines(userProvider.user!.uid);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsetsDirectional.fromSTEB(25, 15, 25, 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.group),
                        SizedBox(width: 10,),
                        Text('Your Routines'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  _heading,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: _routines.isEmpty
                    ? Center(child: Text('No routines found'))
                    : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.25 / 2,
                  ),
                  itemCount: _routines.length,
                  itemBuilder: (context, index) {
                    return _routines[index];
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListCard extends StatefulWidget {
  final String title;
  final String description;
  final String uid;
  final String id;
  final Function(String uid, String id) onTap;

  ListCard({
    required this.title,
    required this.description,
    required this.uid,
    required this.id,
    required this.onTap,
  });

  @override
  _ListCardState createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  String? username;

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  Future<void> getUsername() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: widget.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          username = querySnapshot.docs.first['username'];
        });
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap(widget.uid, widget.id); // Pass the UID and ID when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostFromRoutine(routineId: widget.id),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('By ${username ?? 'Loading...'}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),),
                  SizedBox(height: 8.0),
                  Text(widget.description),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
