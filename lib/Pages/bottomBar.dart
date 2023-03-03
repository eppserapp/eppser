import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/chat.dart';
import 'package:eppser/Pages/home.dart';
import 'package:eppser/Pages/search.dart';
import 'package:eppser/Pages/profile.dart';
import 'package:eppser/providers/themeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../providers/userProvider.dart';

class bottomBar extends StatefulWidget {
  @override
  _bottomBarState createState() => _bottomBarState();
}

class _bottomBarState extends State<bottomBar> {
  int _selectedIndex = 0;
  var tkn = "";
  var provider;
  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
    addData();
    getToken();
  }

  addData() async {
    Provider.of<themeProvider>(context, listen: false).addItemsToLocalStorage();
    // ignore: no_leading_underscores_for_local_identifiers
    UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await _userProvider.refreshUser();
  }

  Future<void> getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      FirebaseFirestore.instance
          .collection('fcmToken')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'fcmToken': token,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<themeProvider>(context, listen: true).theme;
    return Scaffold(
        backgroundColor:
            provider == true || provider == null ? Colors.white : Colors.black,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: <Widget>[
            const homePage(),
            const chatPage(),
            const searchPage(),
            profilePage(uid: FirebaseAuth.instance.currentUser!.uid)
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              color: provider == true || provider == null
                  ? Colors.white
                  : Colors.black,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(.1),
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: GNav(
                  tabBorderRadius: 18,
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 8,
                  activeColor: provider == true || provider == null
                      ? Colors.white
                      : Colors.black,
                  iconSize: 28,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: provider == true || provider == null
                      ? Colors.black
                      : Colors.white,
                  color: provider == true || provider == null
                      ? Colors.black
                      : Colors.white,
                  tabs: const [
                    GButton(
                      icon: Iconsax.home,
                      text: 'Anasayfa',
                    ),
                    GButton(
                      icon: Iconsax.message,
                      text: 'Mesajlar',
                    ),
                    GButton(
                      icon: Iconsax.search_normal,
                      text: 'Ara',
                    ),
                    GButton(
                      icon: Iconsax.user,
                      text: 'Profil',
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _pageController.jumpToPage(index);
                    });
                  },
                ),
              ),
            ),
          ),
        ));
  }
}
