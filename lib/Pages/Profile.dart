import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Database/Users.dart';
import 'package:eppser/Settings/Settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import '../Utils/Utils.dart';

class Profile extends StatefulWidget {
  const Profile({required this.uid, super.key});
  final String uid;
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var userData = {};
  bool isLoading = false;
  bool tick = false;
  var data = {};

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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light));
    return isLoading
        ? Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
          )
        : Scaffold(
            body: Stack(
              children: [
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: userData['profImage'] != null
                      ? ClipRRect(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
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
                            filterQuality: FilterQuality.low,
                            placeholderFadeInDuration:
                                const Duration(microseconds: 1),
                            fadeOutDuration: const Duration(microseconds: 1),
                            fadeInDuration: const Duration(milliseconds: 1),
                            imageUrl: userData['profImage'],
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error, color: Colors.black),
                          ),
                        )
                      : Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/background.jpg'),
                              fit: BoxFit.cover,
                            ),
                            color: Colors.black,
                          ),
                        ),
                ),
                Padding(
                  padding: userData['uid'] != widget.uid
                      ? const EdgeInsets.only(bottom: 30)
                      : const EdgeInsets.only(bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedTextKit(
                                  totalRepeatCount: 1,
                                  animatedTexts: [
                                    TyperAnimatedText(
                                      userData['name'],
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'font2',
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 60,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    AnimatedTextKit(
                                      totalRepeatCount: 1,
                                      animatedTexts: [
                                        TyperAnimatedText(
                                          userData['surname'],
                                          textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'font2',
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 60,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    tick
                                        ? const Padding(
                                            padding: EdgeInsets.only(
                                                left: 5, top: 15, bottom: 3),
                                            child: Icon(
                                              Iconsax.verify5,
                                              color:
                                                  Color.fromRGBO(0, 86, 255, 1),
                                              size: 32,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            const EdgeInsets.only(left: 10, bottom: 0, top: 0),
                        child: AnimatedTextKit(
                          totalRepeatCount: 1,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              "@${userData['username']}",
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Color.fromRGBO(0, 86, 255, 1)),
                            ),
                          ],
                        ),
                      ),
                      userData['bio'] != ""
                          ? Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: AnimatedTextKit(
                                totalRepeatCount: 1,
                                onTap: () => showModalBottomSheet(
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(25))),
                                    context: context,
                                    builder: (context) => Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.topCenter,
                                          children: [
                                            Positioned(
                                                top: 15,
                                                child: Container(
                                                  width: 50,
                                                  height: 5,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromRGBO(
                                                              39,
                                                              39,
                                                              39,
                                                              1.000),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                )),
                                            SizedBox(
                                              height: 300,
                                              child: Center(
                                                child: Text(
                                                  userData['bio'],
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                animatedTexts: [
                                  TyperAnimatedText(
                                    userData['bio'],
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 20,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                if (userData['uid'] != widget.uid)
                  Positioned(
                    top: 30,
                    left: 10,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(18)),
                          child: const Icon(
                            Iconsax.arrow_left_2,
                            size: 34,
                          )),
                    ),
                  ),
                if (userData['uid'] == widget.uid)
                  Positioned(
                    top: 30,
                    right: 10,
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(
                              uid: widget.uid,
                            ),
                          )),
                      child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(18)),
                          child: const Icon(
                            Iconsax.setting_2,
                            size: 34,
                          )),
                    ),
                  ),
                if (userData['uid'] != widget.uid)
                  Positioned(
                    top: 30,
                    right: 10,
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(
                              uid: widget.uid,
                            ),
                          )),
                      child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(18)),
                          child: const Icon(
                            Iconsax.more,
                            size: 34,
                          )),
                    ),
                  )
              ],
            ),
          );
  }
}
