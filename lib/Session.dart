import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String pfp;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.pfp,
  });
}

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        _user = UserModel(
          uid: currentUser.uid,
          username: doc['username'],
          email: doc['email'],
          pfp: doc['pfp'],
        );
        notifyListeners();
      }
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }
}

