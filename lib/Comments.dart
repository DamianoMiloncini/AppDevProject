import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Comments extends StatefulWidget {
  final Map<String, dynamic> data;
  const Comments({super.key, required this.data});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  //controllers
  TextEditingController _comment = TextEditingController();
  final CollectionReference _commentsCollection = FirebaseFirestore.instance.collection('comments');
  //methods

  //add comment to firebase
  Future <void> addComments(String postID, String comment) {
    return _commentsCollection.add({
      'postID' : postID,
      'comment' : comment,
      'timestamp' : DateTime.now(),
    }).then((value) => print('comment added to firebase')).catchError((error) => print('Failed to add the comment to firebase $error'));
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
  Stream<QuerySnapshot> _commentsStream =
  FirebaseFirestore.instance.collection('comments').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                List<DocumentSnapshot> matchingDocs = snapshot.data!.docs.where((doc) => doc['postID'] == widget.data['title']).toList();
                if (matchingDocs.isEmpty) {
                  return Text('Be the first one to comment !');
                }
                return ListView(
                  children: matchingDocs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['comment']),
                    );
                  }).toList(),
                );
              },
            ),
          ),
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
                    addComments(widget.data['title'], _comment.text);
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