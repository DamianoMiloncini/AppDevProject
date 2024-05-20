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

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}
class _PostState extends State<Post> {
  int visualSetNumber = 1;
  var message = '';
  File? image;
  //get the date & time for the post
  final date = DateTime.now();
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
  // This is the list where the selected exercises will be stored
  //could modify the method to allow the user to either take a photo or choose a photo from their gallery
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null){
        return;
      }
      else {
        final imageTemp = File(image.path);
        setState(() {
          this.image = imageTemp;
        });
      }
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    }
  }

  List<Map<String, dynamic>> selectedExercises = [];
  //add post to Firebase
  //used to perform operations
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  Future<void> addPost(uid) {
    //customize the name of the document so that its not a random ass string
    DocumentReference newPosts = posts.doc(_title.text);
    return newPosts.set({
      //add the photo link later
      'uid': uid,
      'title': _title.text,
      'description': _description.text,
      'timestamp': date,
      'exercises': selectedExercises,
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
          title: Text('New Post',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30),),
        ),
        body:
        SingleChildScrollView( //to avoid having a overflow when the user try to write something
          child: Container(
            padding: EdgeInsets.all(30),
            //alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              //color: Colors.brown, //TODO: check for making the container outstand like the mock up
            ),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, //to make sure that it is not all centered (it bothered me frl)
              children: [
                //Text('New Post',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30),),
                //SizedBox(height: 5,),
                Text('Please make sure to provide what is required.',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15,color: Colors.grey),),
                SizedBox(height: 15,),
                //make a HUGE elevated button to allow the user to add a photo
                ElevatedButton(onPressed: () {
                  pickImage();
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), //beautiful
                    ),
                  ),
                  child: Container(
                    height: 200,
                    width: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,color: Colors.black45,size: 90,),
                        Text('Add Photo',style: TextStyle(color: Colors.black45,fontSize: 20),),
                        Text('Upload an image of your workout here..',style: TextStyle(color: Colors.black45,fontSize: 15),),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                //try to have the time run and only save the time when the user publishes the post
                Text('Date & Time : $date',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                TextField(
                  controller: _title,
                  decoration: InputDecoration(
                    labelText: 'Workout Title',
                  ),
                ),
                SizedBox(height: 10,),
                TextField(
                  controller: _description,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                SizedBox(height: 15,),
                SizedBox(height: 15,),
                Text('Selected Exercises', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                // This is where all the user's selected exercises will show!!
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = selectedExercises[index];
                    int setNumber = exercise['sets'].length + 1;
                    var weight = '';
                    var reps = '';
                    return ListTile(
                      title: Text(
                        '${exercise['name']} (${exercise['muscle']})',
                        style: TextStyle(
                            fontWeight: FontWeight.w500
                        ),
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
                            itemCount: selectedExercises[index]['sets'].length + 1,
                            itemBuilder: (context, setIndex) {
                              if (setIndex == selectedExercises[index]['sets'].length) {
                                // This is so that the add set button is always at the bottom of each exercise
                                return ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedExercises[index]['sets'].add({'set': setNumber.toString(), 'lbs': '', 'reps': ''});
                                        message = selectedExercises.toString();
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, color: Colors.white,),
                                        Text(
                                          'Add Set',
                                          style: TextStyle(
                                              color: Colors.white
                                          ),
                                        ),
                                      ],
                                    )
                                );
                              } else {
                                final set = selectedExercises[index]['sets'][setIndex];
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text('${set['set']}'),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Adjust padding here
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
                                        margin: EdgeInsets.only(left: 50.0), // Adjust padding here
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
                //Text(message), // In case i need to display whats being inserted into the map
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                    ),
                    onPressed: () async{
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExerciseSelection()),
                      );
                      if (result != null) {
                        setState(() {
                          // Add selected exercise to the list
                          selectedExercises.add({
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
                        Icon(Icons.add, color: Colors.white,),
                        Text('Add Exercise', style: TextStyle(color: Colors.white, fontFamily: 'Plus Jakarta Sans'),),
                      ],
                    )
                ),
                SizedBox(height: 15,),
                ElevatedButton(onPressed: (){
                  addPost(userProvider.user!.uid);
                  _title.text = '';
                  _description.text = '';
                  setState(() {
                    selectedExercises.clear();
                  });
                }, child: Text('Post Workout'))
              ],
            ),
          ),

        )
    );

  }
}