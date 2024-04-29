import 'dart:convert';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'ExerciseList.dart';


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
    Icon(
      Icons.chat,
      size: 150,
    ),

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
              label: 'Following'
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _postStream =
  FirebaseFirestore.instance.collection('posts').snapshots();
  Map<String, dynamic>? _selectedData; // Track selected data


  void _toggleContent(Map<String, dynamic>? data) {
    setState(() {
      _selectedData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedData == null
          ? _HomePage2(
          _postStream, _toggleContent) // Show original content if data is null
          : _DetailsPost(
          _selectedData!), // Show details post if data is not null
    );
  }

  Widget _HomePage2(Stream<QuerySnapshot> postStream,
      Function(Map<String, dynamic>?) toggleContent,) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hello,',
                style: TextStyle(fontSize: 35),
              ),
              //TODO: Fetch the actual username logged in !
              Text(
                'Micka',
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            'Your current progress of the day',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: postStream,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong :(');
              }
              //if the data is loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); //ofc i had to use it
              }
              //ListView of all the posts
              return Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((
                      DocumentSnapshot document) {
                    Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                    Timestamp timestamp = data['timestamp'];
                    DateTime date = timestamp.toDate();
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                // Toggle content and pass the selected data to DetailsPost
                                toggleContent(data);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: 300,
                                height: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Have the user avatar & username
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.network(
                                            'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHx8MA%3D%3D',
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        SizedBox(width: 15,),
                                        // TODO: fetch the actual username from firebase and add it here amigo
                                        Text('Username'),
                                        SizedBox(width: 15,),
                                        Text('${date.year}-${date.month}-${date
                                            .day}  ${date.hour}:${date
                                            .minute} ')
                                      ],
                                    ),
                                    SizedBox(height: 15,),
                                    //workout description
                                    Expanded(
                                      child: Text(
                                        data['description'],
                                      ), //in case the user enters a long ass description
                                    ),
                                    Divider(
                                      height: 2,
                                      thickness: 1,
                                    ),
                                    //row of icons
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () {},
                                            child: Icon(Icons.message),
                                          ),
                                          // should i add the number of comments and likes ?
                                          TextButton(
                                            onPressed: () {},
                                            child: Icon(Icons.favorite_border),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: Icon(
                                                Icons.bookmark_add_outlined),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: Icon(Icons.share),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  //TODO: Make this page better with a go back to main page pop
  Widget _DetailsPost(Map<String, dynamic> data) {
    Timestamp timestamp = data['timestamp'];
    DateTime date = timestamp.toDate();
    var exercises = data['exercises'];
    //var sets = exercises['sets'].toString();

    Widget printExercises() {
      return ListView.builder(
        //the amount of time i spent just for the solution to be shrinkWrap esti
        shrinkWrap: true,
        itemCount: exercises.length,
        itemBuilder: (BuildContext context, int index) {
          var exercise = exercises[index];
          var sets = exercise['sets'];
          return Column(
            children: [
              Text('Muscle Target: ${exercise['muscle']}'),
              Text('Exercice : ${exercise['name']}'),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: sets.length,
                  itemBuilder: (BuildContext context2, int index2) {
                    var set = sets[index2];
                    return Column(
                      children: [
                        Text('Set ${set['set']}'),
                        Text('Lbs: ${set['lbs']}'),
                        Text('Reps: ${set['reps']}'),
                      ],
                    );
                  }
              )
            ],
          );
        },
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['title'],
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32)),
          Text('${date.year}-${date.month}-${date.day}  ${date.hour}:${date.minute} '),
          SizedBox(height: 20,),
          Text(data['description']),
          printExercises(),
        ],
      ),
    );
  }
}

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
  Future<void> addPost() {
    //customize the name of the document so that its not a random ass string
    DocumentReference newPosts = posts.doc(_title.text);
    return newPosts.set({
      //add the photo link later
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
    return Scaffold(
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
              Text('New Post',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30),),
              SizedBox(height: 5,),
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
                  addPost();
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

// class DetailPosts extends StatefulWidget {
//   //find a way to have the same layout in every page without having to copy paste the app bar, nav bar, ect
//   final Map<String, dynamic> data;
//
//   const DetailPosts({super.key, required this.data});
//
//   @override
//   State<DetailPosts> createState() => _DetailPostsState();
// }
//
// class _DetailPostsState extends State<DetailPosts> {
//   int _selectedIndex = 0;
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//   //list of pages for the nav bar buttons
//   static const List<Widget> _pages = <Widget>[
//     HomePage(),
//     Post(),
//     Icon(
//       Icons.chat,
//       size: 150,
//     ),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         //not sure if the app bar should just display the name of the app at all times or it should change names according to the page name yk?
//         title: Text('Evolve',style: TextStyle(fontSize: 40,fontWeight: FontWeight.w600),),
//         toolbarHeight: 60.2,
//         toolbarOpacity: 0.8,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//               bottomRight: Radius.circular(5),
//               bottomLeft: Radius.circular(5)),
//         ),
//         elevation: 0.00,
//         //backgroundColor: Colors.blueGrey,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.blueGrey,
//         selectedItemColor: Colors.white,
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,//color for the icon when that current page is being displayed
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.post_add),
//             label: 'New Post',
//
//           ),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.people),
//               label: 'Following'
//           ),
//         ],
//       ),
//       body:
//       //i love putting stuff in containers, i cant help it
//       Container(
//         child: Column(
//           children: [
//             Text(widget.data['title']),
//           ],
//         ), //New
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             //TODO: You can change to your liking honestly
//             const UserAccountsDrawerHeader(
//               decoration: BoxDecoration(
//                   color: Colors.white38
//               ),
//               //for now, this is HardCoded but fetch from database later on !!
//               accountName: Text('Micka'),
//               accountEmail: Text('micka@gmail.com'),
//               currentAccountPicture: //should we allow the user to upload their picture? Should we give the user options of profile pictures to choose from ?,
//               CircleAvatar(
//                 backgroundColor: Colors.blueAccent,
//                 foregroundColor: Colors.lightGreen,
//                 child: Text('M',style: TextStyle(fontSize: 30),),
//               ),
//             ),
//             //account tile
//             ListTile(
//               //something is bothering me with the way this is styled but whateva
//               leading: const Icon(Icons.account_circle_outlined,size: 30,),
//               title: const Text('Account Settings'),
//               trailing: const Icon(Icons.arrow_forward),
//               onTap: () {
//                 //push to User settings page
//               },
//             ),
//             SizedBox(height: 10,),
//             Row(
//               children: [
//                 //light theme button
//                 ElevatedButton(onPressed: () {
//                   MyApp.of(context).changeTheme(ThemeMode.light);
//                   Navigator.pop(context); //to close the drawer after the user clicks the button
//                 } ,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       //little sun
//                       Icon(Icons.wb_sunny_outlined),
//                       SizedBox(width: 5,),
//                       Text('Light Mode')
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 5,),
//                 ElevatedButton(onPressed: () {
//                   MyApp.of(context).changeTheme(ThemeMode.dark);
//                   Navigator.pop(context); //to close the drawer after the user clicks the button
//                 },
//                   child: Row(
//                     children: [
//                       //little moon
//                       Icon(Icons.dark_mode_outlined),
//                       SizedBox(width: 5,),
//                       Text('Dark Mode')
//                     ],
//                   ),
//                 ),
//
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }



