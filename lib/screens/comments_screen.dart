import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/services/comments_service.dart';
import 'package:instagram/widgets/comment_card.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final snapshot;

  const CommentsScreen({super.key, required this.snapshot});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL),
              radius: 18,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Comment as ${user.username}',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                CommentsService().postComment(
                    postID: widget.snapshot['postID'],
                    text: _commentController.text,
                    uid: user.uid,
                    username: user.username,
                    photoURL: user.photoURL);
                setState(() {
                  _commentController.text = '';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: const Text(
                  'Post',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            )
          ]),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.snapshot['postID'])
              .collection('comments')
              .orderBy('publishedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (contex, index) {
                  return CommentCard(
                    snapshot: snapshot.data!.docs[index],
                  );
                });
          }),
    );
  }
}
