import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/users.dart';
import 'package:eppser/Widgets/chatCard.dart';
import 'package:eppser/providers/themeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class chatPage extends StatefulWidget {
  const chatPage({super.key});

  @override
  State<chatPage> createState() => _chatPageState();
}

class _chatPageState extends State<chatPage> {
  late BannerAd myBanner;
  var provider;
  @override
  void didChangeDependencies() {
    myBanner = BannerAd(
      size: AdSize.banner,
      request: const AdRequest(),
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: const BannerAdListener(),
    )..load();

    super.didChangeDependencies();
  }

  void control() {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Chats')
        .snapshots()
        .listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    control();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<themeProvider>(context, listen: true).theme;
    return Scaffold(
      backgroundColor: provider == true ? Colors.white : Colors.black,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "Mesajlar",
              style: TextStyle(
                  fontFamily: 'font1', fontSize: 30, color: Colors.white),
            ),
          )),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Chats')
            .orderBy('timeSent', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          try {
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Icon(
                  Iconsax.message,
                  size: 80,
                  color: provider == true ? Colors.black : Colors.white,
                ),
              );
            }
          } catch (e) {
            print(e);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: provider == true ? Colors.black : Colors.white,
              backgroundColor: provider == true ? Colors.white : Colors.black,
            ));
          }
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return chatCard(
                  snap: snapshot.data!.docs[index].data(),
                );
              });
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(55 * 0.4)),
            child: Container(
              width: 55,
              height: 55,
              color: provider == true ? Colors.black : Colors.white,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => usersPage(
                                snap: FirebaseAuth.instance.currentUser!.uid,
                              )));
                },
                icon: Icon(
                  Iconsax.message,
                  color: provider == true ? Colors.white : Colors.black,
                  size: 25,
                ),
              ),
            )),
      ),
    );
  }
}
