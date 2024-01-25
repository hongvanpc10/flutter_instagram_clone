import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/services/posts_service.dart';
import 'package:instagram/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snapshot;

  const PostCard({super.key, required this.snapshot});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLikeAnimating = false;
  int _commentsCount = 0;

  @override
  void initState() {
    super.initState();
    _getCommentsCount();
  }

  Future<void> _getCommentsCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snapshot['postID'])
        .collection('comments')
        .get();
    setState(() {
      _commentsCount = snapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return user == null
        ? Container()
        : Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4)
                    .copyWith(right: 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage:
                          NetworkImage(widget.snapshot['photoURL']),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.snapshot['username'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            ]),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shrinkWrap: true,
                                    children: ['Delete']
                                        .map((e) => InkWell(
                                              onTap: () {
                                                PostsService().deletePost(
                                                    widget.snapshot['postID']);
                                                Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(e),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                );
                              });
                        },
                        icon: const Icon(
                          Icons.more_vert,
                        ))
                  ],
                ),
              ),
              GestureDetector(
                onDoubleTap: () {
                  PostsService().likePost(
                    widget.snapshot['postID'],
                    user.uid,
                    List<String>.from(widget.snapshot['likes']),
                  );
                  setState(() {
                    _isLikeAnimating = true;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: double.infinity,
                      child: Image.network(
                        widget.snapshot['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isLikeAnimating ? 1 : 0,
                      child: LikeAnimation(
                        isAnimating: _isLikeAnimating,
                        duration: const Duration(milliseconds: 400),
                        onEnd: () {
                          log('Animation ended');
                          setState(() {
                            _isLikeAnimating = false;
                          });
                        },
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 120,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  LikeAnimation(
                    isAnimating: widget.snapshot['likes'].contains(user.uid),
                    child: IconButton(
                      onPressed: () {
                        PostsService().likePost(
                          widget.snapshot['postID'],
                          user.uid,
                          List<String>.from(widget.snapshot['likes']),
                        );
                      },
                      icon: widget.snapshot['likes'].contains(user.uid)
                          ? const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : const Icon(Icons.favorite_border),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CommentsScreen(
                          snapshot: widget.snapshot,
                        ),
                      ));
                    },
                    icon: const Icon(
                      Icons.comment_outlined,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.bookmark_border),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                      child: Text(
                        '${widget.snapshot['likes'].length} likes',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      child: RichText(
                        text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: widget.snapshot['username'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: ' ${widget.snapshot['description']}',
                              )
                            ]),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'View all ${_commentsCount} comments',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        DateFormat.yMMMd()
                            .format(widget.snapshot['publishedAt'].toDate()),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  ],
                ),
              )
            ]),
          );
  }
}
