import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/editProfile.dart';
import 'package:eppser/Pages/message.dart';
import 'package:eppser/Pages/story.dart';
import 'package:eppser/Pages/users.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Widgets/postCard.dart';
import 'package:eppser/providers/themeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Utils/Utils.dart';

class profilePage extends StatefulWidget {
  const profilePage({required this.uid, super.key});
  final String uid;
  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  bool tick = false;
  Map usersId = {};
  var data = {};
  var provider;

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
      await FirebaseFirestore.instance
          .collection('Story')
          .where('uid', isEqualTo: widget.uid)
          .get()
          .then((value) => value.docs.forEach((element) {
                data.addAll(element.data());
              }));

      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .get();

      userData = userSnap.data()!;
      followers = int.parse(
          NumberFormat.compact().format(userSnap.data()!['followers'].length));
      following = int.parse(
          NumberFormat.compact().format(userSnap.data()!['following'].length));
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      tick = userData['tick'];

      setState(() {});
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
    provider = Provider.of<themeProvider>(context, listen: true).theme;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    usersId = {
      'senderId': FirebaseAuth.instance.currentUser!.uid,
      'recieverId': widget.uid
    };
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: provider == true ? Colors.black : Colors.white,
            ),
          )
        : Scaffold(
            backgroundColor: provider == true ? Colors.white : Colors.black,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FirebaseAuth.instance.currentUser!.uid == widget.uid
                            ? IconButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const editProfilePage())),
                                icon: const Icon(Iconsax.edit),
                                color: Colors.white,
                                iconSize: 30,
                              )
                            : IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Iconsax.arrow_square_left),
                                color: Colors.white,
                                iconSize: 35,
                              ),
                        FirebaseAuth.instance.currentUser!.uid == widget.uid
                            ? IconButton(
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await FirebaseAuth.instance
                                      .signOut()
                                      .whenComplete(() {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                },
                                icon: const Icon(Iconsax.logout),
                                iconSize: 30,
                                color: Colors.white,
                              )
                            : isFollowing
                                ? IconButton(
                                    onPressed: () async {
                                      await FireStoreMethods().followUser(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        userData['uid'],
                                      );

                                      setState(() {
                                        isFollowing = false;
                                        followers--;
                                      });
                                    },
                                    icon: const Icon(
                                      Iconsax.close_square,
                                      size: 35,
                                    ))
                                : Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: IconButton(
                                      onPressed: () async {
                                        await FireStoreMethods().followUser(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          userData['uid'],
                                        );

                                        setState(() {
                                          isFollowing = true;
                                          followers++;
                                        });
                                      },
                                      icon: const Icon(Iconsax.tick_square),
                                      color: Colors.white,
                                      iconSize: 30,
                                    ),
                                  )
                      ]),
                  backgroundColor: Colors.black,
                  pinned: true,
                  toolbarHeight: 50,
                  expandedHeight: MediaQuery.of(context).size.height,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(userData['profImage']),
                              fit: BoxFit.cover)),
                      child: Padding(
                        padding:
                            FirebaseAuth.instance.currentUser!.uid != widget.uid
                                ? const EdgeInsets.only(bottom: 30)
                                : const EdgeInsets.only(bottom: 110),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 60,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          tick
                                              ? const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5,
                                                      top: 15,
                                                      bottom: 3),
                                                  child: Icon(
                                                    Iconsax.verify5,
                                                    color: Color.fromRGBO(
                                                        0, 86, 255, 1),
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
                              padding: const EdgeInsets.only(
                                  left: 10, bottom: 0, top: 0),
                              child: AnimatedTextKit(
                                totalRepeatCount: 1,
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    "@${userData['username']}",
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'font2',
                                        fontSize: 30,
                                        color: Color.fromRGBO(0, 86, 255, 1)),
                                  ),
                                ],
                              ),
                            ),
                            userData['bio'] != ""
                                ? Container(
                                    alignment: Alignment.centerLeft,
                                    padding:
                                        const EdgeInsets.only(left: 10, top: 5),
                                    child: AnimatedTextKit(
                                      totalRepeatCount: 1,
                                      onTap: () => showModalBottomSheet(
                                          backgroundColor: provider == true
                                              ? Colors.white
                                              : Colors.black,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(25))),
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
                                                            color: const Color
                                                                    .fromRGBO(
                                                                39,
                                                                39,
                                                                39,
                                                                1.000),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                      )),
                                                  SizedBox(
                                                    height: 300,
                                                    child: Center(
                                                      child: Text(
                                                        userData['bio'],
                                                        style: TextStyle(
                                                            color: provider ==
                                                                    true
                                                                ? Colors.black
                                                                : Colors.white,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => usersPage(
                                                  snap: widget.uid,
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 5, top: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        buildStatColumn(followers, "Takipçi"),
                                        buildStatColumn(following, "Takip"),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    userData['uid'] !=
                                            FirebaseAuth
                                                .instance.currentUser!.uid
                                        ? Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ClipRRect(
                                                borderRadius: const BorderRadius
                                                        .all(
                                                    Radius.circular(50 * 0.4)),
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.black,
                                                  child: IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      messagePage(
                                                                        snap:
                                                                            usersId,
                                                                      )));
                                                    },
                                                    icon: const Icon(
                                                      Iconsax.message,
                                                      color: Colors.white,
                                                      size: 25,
                                                    ),
                                                  ),
                                                )),
                                          )
                                        : const SizedBox(),
                                    data['postUrl'] == null
                                        ? const SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ClipRRect(
                                                borderRadius: const BorderRadius
                                                        .all(
                                                    Radius.circular(50 * 0.4)),
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.black,
                                                  child: IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      storyPage(
                                                                        uid: widget
                                                                            .uid,
                                                                      )));
                                                    },
                                                    icon: const Icon(
                                                      Iconsax.story,
                                                      color: Colors.white,
                                                      size: 25,
                                                    ),
                                                  ),
                                                )),
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Fotoğraflar',
                        style: TextStyle(
                            color:
                                provider == true ? Colors.black : Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Posts')
                        .where('uid', isEqualTo: userData['uid'])
                        .orderBy('datePublished', descending: true)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        );
                      }

                      return snapshot.data != null
                          ? snapshot.data!.docs.isNotEmpty
                              ? ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (ctx, index) => postCard(
                                    tag: index,
                                    snap: snapshot.data!.docs[index].data(),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 100),
                                  child: Center(
                                    child: Icon(
                                      Iconsax.image,
                                      size: 80,
                                      color: provider == true
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                )
                          : Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: Center(
                                child: Icon(
                                  Iconsax.image,
                                  size: 80,
                                  color: provider == true
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 70),
                )
              ],
            ));
  }
}

Row buildStatColumn(int num, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        num.toString(),
        style: const TextStyle(
          fontFamily: 'font2',
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      Container(
        padding: const EdgeInsets.only(left: 5, right: 20),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'font2',
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}
