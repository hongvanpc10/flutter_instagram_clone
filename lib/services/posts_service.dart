import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/post.dart';
import 'package:instagram/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class PostsService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> uploadPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String photoURL,
  }) async {
    final postID = const Uuid().v1();
    final image = await StorageService().uploadImage('posts', file, postID);
    Post post = Post(
      uid: uid,
      username: username,
      photoURL: photoURL,
      image: image,
      description: description,
      likes: [],
      postID: postID,
      publishedAt: DateTime.now(),
    );

    await _firestore.collection('posts').doc(post.postID).set(post.toJSON());
  }

  Future<void> likePost(String postID, String uid, List<String> likes) async {
    if (likes.contains(uid)) {
      await _firestore.collection('posts').doc(postID).update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      await _firestore.collection('posts').doc(postID).update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  Future<void> deletePost(String postID) async {
    await FirebaseFirestore.instance.collection('posts').doc(postID).delete();
  }
}
