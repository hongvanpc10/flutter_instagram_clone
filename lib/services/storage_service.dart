import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadImage(
      String childName, Uint8List file, String name) async {
    final ref = _storage.ref().child(childName).child(name);
    final uploadTask = ref.putData(file);
    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }
}
