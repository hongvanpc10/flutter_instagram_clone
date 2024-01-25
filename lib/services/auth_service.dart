import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/models/user.dart' as model;
import 'package:instagram/services/storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signup({
    required String username,
    required String email,
    required String password,
    required Uint8List file,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final photoURL = await StorageService()
        .uploadImage('profile_pictures', file, _auth.currentUser!.uid);

    final user = model.User(
      uid: credential.user!.uid,
      email: email,
      username: username,
      photoURL: photoURL,
      followers: [],
      following: [],
    );

    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toJSON());
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<model.User> getUserDetails() async {
    final snapshot =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    return model.User.fromSnapshot(snapshot);
  }

  Future<void> followUser(String uid, String followID) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    List<String> following = snapshot.data()!['following'];
    if (following.contains(followID)) {
      await _firestore.collection('users').doc(followID).update({
        'followers': FieldValue.arrayRemove([uid])
      });

      await _firestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayRemove([followID])
      });
    } else {
      await _firestore.collection('users').doc(followID).update({
        'followers': FieldValue.arrayUnion([uid])
      });

      await _firestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayUnion([followID])
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
