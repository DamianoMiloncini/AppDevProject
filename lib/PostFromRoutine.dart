import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'ExerciseList.dart';
import 'package:provider/provider.dart';
import 'Session.dart';

class PostFromRoutine extends StatefulWidget {
  final String routineId;

  const PostFromRoutine({super.key, required this.routineId});

  @override
  State<PostFromRoutine> createState() => _PostFromRoutineState();
}

class _PostFromRoutineState extends State<PostFromRoutine> {
  int visualSetNumber = 1;
  var message = '';
  File? image;
  String uid = '';
  String title = '';
  String description = '';
  List<Map<String, dynamic>> exercises = [];

  @override
  void initState() {
    super.initState();
    fetchRoutineDetails();
  }

  Future<void> fetchRoutineDetails() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('routines')
          .doc(widget.routineId)
          .get();
      if (docSnapshot.exists) {
        setState(() {
          uid = docSnapshot['uid'];
          title = docSnapshot['title'];
          description = docSnapshot['description'];
          exercises = List<Map<String, dynamic>>.from(docSnapshot['exercises']);
        });
      }
    } catch (e) {
      print("Error fetching routine details: $e");
    }
  }

  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      } else {
        final imageTemp = File(image.path);
        setState(() {
          this.image = imageTemp;
        });
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();

  final date = DateTime.now();
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  Future<void> addPost(String UID) {
    //customize the name of the document so that its not a random ass string
    DocumentReference post = posts.doc();
    return post.set({
      'id': post.id,
      'uid': UID,
      'title': _title.text,
      'description': _description.text,
      'timestamp': date,
      'exercises': exercises,
      'likes': 0,
    })
        .then((value) => print('posts added to firebase'))
        .catchError((error) => print('failed to add the posts to firebase $error')
    );
  }



  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Post',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  pickImage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Beautiful
                  ),
                ),
                child: Container(
                  height: 200,
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: Colors.black45, size: 90),
                      Text('Add Photo', style: TextStyle(color: Colors.black45, fontSize: 20)),
                      Text('Upload an image of your workout here..', style: TextStyle(color: Colors.black45, fontSize: 15)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text('Date & Time : ${DateTime.now()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: title,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _description,
                decoration: InputDecoration(
                  labelText: description,
                ),
              ),
              SizedBox(height: 15),
              SizedBox(height: 15),
              Text('Selected Exercises', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  int setNumber = exercise['sets'].length + 1;
                  return ListTile(
                    title: Text(
                      '${exercise['name']} (${exercise['muscle']})',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Set'),
                            Text('LBS'),
                            Text('Reps'),
                          ],
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(), // Disable scrolling for nested ListView
                          itemCount: exercise['sets'].length + 1,
                          itemBuilder: (context, setIndex) {
                            if (setIndex == exercise['sets'].length) {
                              return ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    exercise['sets'].add({'set': setNumber.toString(), 'lbs': '', 'reps': ''});
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: Colors.white),
                                    Text('Add Set', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              );
                            } else {
                              final set = exercise['sets'][setIndex];
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(flex: 4, child: Text('${set['set']}')),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                      child: TextFormField(
                                        onChanged: (value) {
                                          setState(() {
                                            set['lbs'] = value; // Update weight of the current set
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          border: InputBorder.none,
                                        ),
                                        initialValue: set['lbs'],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 50.0),
                                      child: TextFormField(
                                        onChanged: (value) {
                                          setState(() {
                                            set['reps'] = value; // Update reps of the current set
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          border: InputBorder.none,
                                        ),
                                        initialValue: set['reps'],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExerciseSelection()),
                  );
                  if (result != null) {
                    setState(() {
                      exercises.add({
                        'name': result['name'],
                        'muscle': result['muscle'],
                        'sets': [], // Initialize sets list with an empty list
                      });
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    Text('Add Exercise', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  addPost(userProvider.user!.uid);
                  setState(() {
                    title = '';
                    description = '';
                    exercises.clear();
                  });
                },
                child: Text('Post Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
