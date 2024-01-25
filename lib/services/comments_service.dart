import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CommentsService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> postComment({
    required String postID,
    required String text,
    required String uid,
    required String username,
    required String photoURL,
  }) async {
    final commentID = const Uuid().v1();
    await _firestore
        .collection('posts')
        .doc(postID)
        .collection('comments')
        .doc(commentID)
        .set({
      'commentID': commentID,
      'text': text,
      'uid': uid,
      'username': username,
      'photoURL': photoURL,
      'publishedAt': DateTime.now(),
    });
  }
}
