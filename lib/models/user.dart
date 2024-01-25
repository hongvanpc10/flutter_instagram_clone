import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String username;
  final String photoURL;
  final List<String> followers;
  final List<String> following;

  User(
      {required this.uid,
      required this.email,
      required this.username,
      required this.photoURL,
      required this.followers,
      required this.following});

  Map<String, Object> toJSON() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'photoURL': photoURL,
      'followers': followers,
      'following': following
    };
  }

  static User fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return User(
        uid: data['uid'],
        email: data['email'],
        username: data['username'],
        photoURL: data['photoURL'],
        followers: List<String>.from(data['followers']),
        following: List<String>.from(data['following']));
  }
}
