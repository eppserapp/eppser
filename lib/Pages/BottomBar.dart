import 'package:eppser/Pages/Home.dart';
import 'package:eppser/Pages/LandingPage.dart';
import 'package:eppser/Pages/Profile.dart';
import 'package:eppser/Pages/Timeline.dart';
import 'package:eppser/Pages/VideoPage.dart';
import 'package:eppser/Pages/WalletPage.dart';
import 'package:eppser/Providers/themeProvider.dart';
import 'package:eppser/Theme/Theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class bottomBar extends StatefulWidget {
  @override
  _bottomBarState createState() => _bottomBarState();
}

class _bottomBarState extends State<bottomBar> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: <Widget>[
          const Home(),
          Timeline(),
          const VideoHome(),
          const WalletPage(),
          Profile(
            uid: FirebaseAuth.instance.currentUser!.uid,
          )
        ],
        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: GNav(
              tabBorderRadius: 18,
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.white,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 28,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor:
                  Provider.of<ThemeProvider>(context).themeData == lightMode
                      ? Colors.black
                      : const Color.fromARGB(255, 0, 30, 80),
              color: Provider.of<ThemeProvider>(context).themeData == lightMode
                  ? Colors.black
                  : Colors.white,
              tabs: const [
                GButton(
                  icon: Iconsax.home,
                  text: 'Ana Sayfa',
                ),
                GButton(
                  icon: Iconsax.chart_3,
                  text: 'Timeline',
                ),
                GButton(
                  icon: Iconsax.messages_2,
                  text: 'Video',
                ),
                GButton(
                  icon: Iconsax.empty_wallet,
                  text: 'Cüzdan',
                ),
                GButton(
                  icon: Iconsax.profile_circle,
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
    );
  }
}
