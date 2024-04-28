// import 'dart:html';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

      ),
      home: InitialPage(),
    );
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
        backgroundColor: Colors.blueGrey,
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
          //padding: ,
          children: [
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
                ) )
          ],
        ),
      ),
    );
  }
}

//new post page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //-1: this is creating a stream of data that continously being updated whenever there is a change in the firebase (used to read what is in the firebase)
  final Stream<QuerySnapshot> _postStream = FirebaseFirestore.instance.collection('posts').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //will be Hello $user later on :)
            Row(
              children: [
                Text('Hello,',style: TextStyle(fontSize: 35),),
                Text('Micka',style: TextStyle(fontSize: 35,color: Colors.deepPurpleAccent,fontWeight: FontWeight.w500),),
              ],
            ),
            Text('Your current progress of the day',style: TextStyle(fontSize: 15,color: Colors.grey,),),

            //TODO: Display user's posts ! :)

            StreamBuilder<QuerySnapshot>(
                stream: _postStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong :(');
                  }
                  //if the data is loading
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); //ofc i had to use it
                  }
                  //ListView of all the posts
                  return Expanded(child: ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs
                        .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                      //GOOD TO KNOW: if one of your documents doesnt have the field that you are trying to read, you will get an error
                      //TODO: Style it like the mock up :)
                      return ListTile(
                        title: Text(data['title']),
                        subtitle: Text(data['description']),
                      );
                    }).toList(),
                  ),);
                }
            )
          ],
        ),
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
  File? image;
  //get the date & time for the post
  final date = DateTime.now();
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
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
    })
        .then((value) => print('posts added to firebase'))
        .catchError((error) => print('failed to add the posts to firebase')
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
              ElevatedButton(onPressed: (){
                  addPost();
                  _title.text = '';
                  _description.text = '';
              }, child: Text('Post Workout'))
            ],
          ),
        ),

      )

    );
  }
}
