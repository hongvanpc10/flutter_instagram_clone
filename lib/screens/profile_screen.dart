import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/services/auth_service.dart';
import 'package:instagram/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _userData = {};
  int _postsCount = 0;
  int _followers = 0;
  int _following = 0;
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    setState(() {
      _isLoading = true;
    });
    var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    var postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    _postsCount = postSnap.docs.length;
    _userData = userSnap.data()!;
    _followers = userSnap.data()!['followers'].length;
    _following = userSnap.data()!['following'].length;
    _isFollowing = userSnap
        .data()!['followers']
        .contains(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(_userData['username']),
            ),
            body: ListView(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(_userData['photoURL']),
                          radius: 40,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatColumn(_postsCount, 'posts'),
                                  _buildStatColumn(_followers, 'followers'),
                                  _buildStatColumn(_following, 'following'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  FirebaseAuth.instance.currentUser!.uid ==
                                          widget.uid
                                      ? FollowButton(
                                          text: 'Sign out',
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          borderColor: Colors.grey,
                                          onPressed: () async {
                                            await AuthService().signOut();
                                            if (context.mounted) {
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginScreen()));
                                            }
                                          },
                                        )
                                      : _isFollowing
                                          ? FollowButton(
                                              text: 'Unfollow',
                                              backgroundColor: Colors.white,
                                              textColor: Colors.black,
                                              borderColor: Colors.grey,
                                              onPressed: () async {
                                                await AuthService().followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    _userData['uid']);
                                                setState(() {
                                                  _isFollowing = false;
                                                  _followers--;
                                                });
                                              },
                                            )
                                          : FollowButton(
                                              text: 'Follow',
                                              backgroundColor: Colors.blue,
                                              textColor: Colors.white,
                                              borderColor: Colors.blue,
                                              onPressed: () async {
                                                await AuthService().followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    _userData['uid']);
                                                setState(() {
                                                  _isFollowing = true;
                                                  _followers++;
                                                });
                                              },
                                            ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        _userData['username'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        _userData['bio'] ?? '',
                      ),
                    ),
                    const Divider(),
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('posts')
                          .where('uid', isEqualTo: widget.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 1.5,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            DocumentSnapshot snap = snapshot.data!.docs[index];

                            return SizedBox(
                              child: Image(
                                image: NetworkImage(snap['image']),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              )
            ]),
          );
  }

  Column _buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
