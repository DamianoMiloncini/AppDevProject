import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Session.dart';

class Comments extends StatefulWidget {
  final Map<String, dynamic> data;
  const Comments({super.key, required this.data});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  //controllers
  TextEditingController _comment = TextEditingController();
  final CollectionReference _commentsCollection = FirebaseFirestore.instance
      .collection('comments');
  late UserProvider userProvider;

  //methods

  //add comment to firebase
  Future <void> addComments(String postID, String comment, String uid) {
    return _commentsCollection.add({
      'postID': postID,
      'uid': uid,
      'comment': comment,
      'timestamp': DateTime.now(),
    }).then((value) => print('comment added to firebase')).catchError((error) =>
        print('Failed to add the comment to firebase $error'));
  }

  //display comments
  Future <ListView> displayComments() async {
    Stream<QuerySnapshot> _commentsStream =
    FirebaseFirestore.instance.collection('comments').snapshots();

    StreamBuilder<QuerySnapshot>(
        stream: _commentsStream,
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
                title: Text(data['comment']),
              );
            }).toList(),
          );
        });
    return ListView(
      shrinkWrap: true,
      children: [
        Text('No comments yet'),
      ],
    );
  }

  //Map to store user IDs and corresponding usernames
  Map<String, String> _usernames = {};
  Map<String, String> _pfp = {};
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection('users');
  //Method to fetch username by user ID
  Future<void> _fetchUsername(String uid) async {
    if (!_usernames.containsKey(uid)) {
      try {
        DocumentSnapshot userDoc = await _userCollection.doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            _usernames[uid] = userDoc.get('username') ?? 'Unknown'; //if cannot be found, put unknown user
          });
        } else {
          setState(() {
            _usernames[uid] = 'Unknown';
          });
        }
      } catch (e) {
        print('Error fetching username: $e');
        setState(() {
          _usernames[uid] = 'Unknown';
        });
      }
    }
  }

  Future<void> _fetchPFP(String uid) async {
    if (!_pfp.containsKey(uid)) {
      try {
        DocumentSnapshot userDoc = await _userCollection.doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            _pfp[uid] = userDoc.get('pfp') ?? '1'; //if cannot be found, put unknown user
          });
        } else {
          setState(() {
            _pfp[uid] = '1';
          });
        }
      } catch (e) {
        print('Error fetching profile picture: $e');
        setState(() {
          _pfp[uid] = '1';
        });
      }
    }
  }
  Stream<QuerySnapshot> _commentsStream =
  FirebaseFirestore.instance.collection('comments').orderBy('timestamp',descending: false).snapshots();
  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Comments'),),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _commentsStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                //filter the results by the matching postID:
                List<DocumentSnapshot> matchingDocs = snapshot.data!.docs.where((doc) => doc['postID'] == widget.data['id']).toList();
                if (matchingDocs.isEmpty) {
                  return Text('Be the first one to comment !');
                }
                return ListView(
                  children: matchingDocs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    String uid = data['uid'];

                    //Fetch the username for each post
                    _fetchUsername(uid);
                    _fetchPFP(uid);
                    Timestamp timestamp = data['timestamp'];
                    DateTime date = timestamp.toDate();
                    return SingleChildScrollView(
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: Container(
                          width: 50,
                          height: 50,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/profile_pictures/${_pfp[uid]}.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _usernames[uid] ?? 'Loading...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                          Text(data['comment']),
                                      ],
                                    ),

                            ],
                          ),

                        trailing: Expanded(child: Text(
                          '${date.year}-${date.month}-${date.day}  ${date.hour}:${date.minute}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                          ),
                        ),)
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          //Add a comment container
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _comment,
                    decoration: InputDecoration(
                      hintText: 'Enter a comment',
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Add the new comment
                    addComments(widget.data['id'], _comment.text, userProvider.user!.uid);
                    _comment.text = '';
                  },
                  child: Text('Add Comment'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}