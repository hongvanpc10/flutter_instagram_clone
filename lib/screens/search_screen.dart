import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram/screens/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isShowUsers = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search a user',
          ),
          onFieldSubmitted: (value) {
            setState(() {
              _isShowUsers = true;
            });
          },
        ),
      ),
      body: _isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('username',
                      isGreaterThanOrEqualTo: _searchController.text)
                  .get(),
              builder: ((context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) => InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                      uid: snapshot.data!.docs[index]['uid'],
                                    )));
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                snapshot.data!.docs[index]['photoURL'],
                              ),
                            ),
                            title: Text(snapshot.data!.docs[index]['username']),
                          ),
                        ));
              }))
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: ((context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('publishedAt', descending: true)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return MasonryGridView.count(
                      crossAxisCount: 3,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) => Image.network(
                        snapshot.data!.docs[index]['image'],
                        fit: BoxFit.cover,
                      ),
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    );
                  },
                );
              })),
    );
  }
}
