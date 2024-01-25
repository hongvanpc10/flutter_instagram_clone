import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/services/posts_service.dart';
import 'package:instagram/utils/pick_image.dart';
import 'package:instagram/utils/show_snack_bar.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool _isLoading = false;

  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  _selectImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create a post'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Add a photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              )
            ],
          );
        });
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  Future<void> _onPost(
      {required String uid,
      required String username,
      required String photoURL}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await PostsService().uploadPost(
        description: _descriptionController.text,
        file: _file!,
        uid: uid,
        username: username,
        photoURL: photoURL,
      );
      if (context.mounted) {
        showSnackBar(context, 'Post uploaded successfully');
      }
      clearImage();
    } on FirebaseException catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.message!);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;

    return _file == null
        ? Center(
            child: IconButton(
              icon: const Icon(Icons.upload),
              onPressed: () {
                _selectImage(context);
              },
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () {}, icon: const Icon(Icons.arrow_back)),
              title: const Text('Post to'),
              actions: [
                TextButton(
                    onPressed: () {
                      _onPost(
                        uid: user.uid,
                        username: user.username,
                        photoURL: user.photoURL,
                      );
                    },
                    child: const Text(
                      'Post',
                    ))
              ],
            ),
            body: Column(children: [
              _isLoading
                  ? const LinearProgressIndicator()
                  : const Padding(
                      padding: EdgeInsets.only(top: 0),
                    ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.photoURL),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                          hintText: "Write a caption...",
                          border: InputBorder.none),
                      maxLines: 8,
                    ),
                  ),
                  SizedBox(
                    height: 45,
                    width: 45,
                    child: AspectRatio(
                      aspectRatio: 478 / 451,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                alignment: FractionalOffset.topCenter,
                                image: MemoryImage(_file!))),
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              )
            ]),
          );
  }
}
