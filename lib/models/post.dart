import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String uid;
  final String username;
  final String photoURL;
  final String image;
  final String description;
  final List<String> likes;
  final String postID;
  final DateTime publishedAt;

  Post({
    required this.uid,
    required this.username,
    required this.photoURL,
    required this.image,
    required this.description,
    required this.likes,
    required this.postID,
    required this.publishedAt,
  });

  Map<String, Object> toJSON() {
    return {
      'uid': uid,
      'username': username,
      'photoURL': photoURL,
      'image': image,
      'description': description,
      'likes': likes,
      'postID': postID,
      'publishedAt': publishedAt,
    };
  }

  static Post fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Post(
      uid: data['uid'],
      username: data['username'],
      photoURL: data['photoURL'],
      image: data['image'],
      description: data['description'],
      likes: List<String>.from(data['likes']),
      postID: data['postID'],
      publishedAt: data['publishedAt'],
    );
  }
}
