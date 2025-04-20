import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Database/Users.dart';
import 'package:eppser/Pages/LandingPage.dart';
import 'package:eppser/Pages/ProfileSettings.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.uid,
  });
  final String uid;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var userData = {};
  bool isFollowing = false;
  bool isLoading = false;
  bool tick = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var snap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .get();
      if (snap.exists) {
        setState(() {
          userData = snap.data()!;
          tick = userData['tick'] ?? false;
        });
      }
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Ayarlar',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left_2,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8),
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                )
              : InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileSettings(),
                      )),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      userData['profImage'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        color:
                                            const Color.fromRGBO(0, 86, 255, 1),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: const Icon(
                                      Iconsax.user,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                  filterQuality: FilterQuality.low,
                                  placeholderFadeInDuration:
                                      const Duration(microseconds: 1),
                                  fadeOutDuration:
                                      const Duration(microseconds: 1),
                                  fadeInDuration:
                                      const Duration(milliseconds: 1),
                                  imageUrl: userData['profImage'],
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error,
                                          color: Colors.black),
                                ),
                              ),
                            )
                          : Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                  color: const Color.fromRGBO(0, 86, 255, 1),
                                  borderRadius: BorderRadius.circular(30)),
                              child: const Icon(
                                Iconsax.user,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                userData['name'] + " " + userData['surname'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  fontSize: 24,
                                ),
                              ),
                              tick
                                  ? const Padding(
                                      padding: EdgeInsets.only(
                                        left: 3,
                                        top: 5,
                                      ),
                                      child: Icon(
                                        Iconsax.verify5,
                                        color: Color.fromRGBO(0, 86, 255, 1),
                                        size: 20,
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 120),
                            child: Text(
                              userData['bio'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            title: const Text('Gizlilik'),
            onTap: () {},
            leading: const Icon(Iconsax.security_user),
          ),
          ListTile(
            title: const Text('Premium'),
            onTap: () {},
            leading: const Icon(Iconsax.crown_1),
          ),
          ListTile(
            title: const Text('Sohbetler'),
            onTap: () {},
            leading: const Icon(Iconsax.messages_2),
          ),
          ListTile(
            title: const Text('Bildirimler'),
            onTap: () {},
            leading: const Icon(Iconsax.notification),
          ),
          ListTile(
            title: const Text('Depolama Ve Veriler'),
            onTap: () {},
            leading: const Icon(Iconsax.graph),
          ),
          ListTile(
            title: const Text('Uygulama Dili'),
            onTap: () {},
            leading: const Icon(Iconsax.language_circle),
          ),
          ListTile(
            title: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              // final prefs = await SharedPreferences.getInstance();
              // await prefs.remove('token').whenComplete(() {
              //   Navigator.of(context).pushAndRemoveUntil(
              //       MaterialPageRoute(
              //           builder: (context) => const LandingScreen()),
              //       (Route<dynamic> route) => false);
              // });
              await FirebaseAuth.instance.signOut().whenComplete(
                () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => LandingScreen(),
                    ),
                    (route) => false,
                  );
                },
              );
            },
            leading: const Icon(
              Iconsax.user,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
