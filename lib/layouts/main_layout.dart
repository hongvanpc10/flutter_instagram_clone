import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  final List<Widget> children;

  const MainLayout({super.key, required this.children});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    _addData();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  Future<void> _addData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
  }

  void _handleNavigationTap(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: widget.children,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        activeColor: Colors.black,
        height: 64,
        onTap: _handleNavigationTap,
        currentIndex: _page,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}
