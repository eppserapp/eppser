import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/addPost.dart';
import 'package:eppser/Pages/story.dart';
import 'package:eppser/Widgets/postCard.dart';
import 'package:eppser/Widgets/storyCard.dart';
import 'package:eppser/providers/themeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'addStory.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePage();
}

class _homePage extends State<homePage> {
  List following = [];
  late BannerAd myBanner;
  String profImage = "";
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

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  bool isLoading = false;

  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      following = userSnap.data()!['following'];
      profImage = userSnap.data()!['profImage'];

      setState(() {});
    } catch (e) {
      print(e);
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
    following.add(FirebaseAuth.instance.currentUser!.uid);
    return Scaffold(
      backgroundColor: provider == true ? Colors.white : Colors.black,
      extendBodyBehindAppBar: true,
      body: following.isNotEmpty
          ? CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.black,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () => showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.black,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25))),
                              builder: (BuildContext context) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.topCenter,
                                  children: [
                                    Positioned(
                                        top: 15,
                                        child: Container(
                                          width: 50,
                                          height: 5,
                                          decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                  39, 39, 39, 1.000),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                        )),
                                    SizedBox(
                                      height: 300,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            InkWell(
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const addPostPage())),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Iconsax.image,
                                                    color: Colors.white,
                                                    size: 50,
                                                  ),
                                                  SizedBox(height: 20),
                                                  Text(
                                                    "Gönderi",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const addStoryPage())),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Iconsax.story,
                                                    color: Colors.white,
                                                    size: 50,
                                                  ),
                                                  SizedBox(height: 20),
                                                  Text(
                                                    "Hikaye",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ]),
                                    ),
                                  ],
                                );
                              }),
                          icon: const Icon(
                            Iconsax.add_square,
                            color: Colors.white,
                            size: 32,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AnimatedTextKit(
                          totalRepeatCount: 3,
                          animatedTexts: [
                            WavyAnimatedText(
                              "eppser",
                              textStyle: const TextStyle(
                                  fontFamily: 'font1',
                                  fontSize: 40,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      if (provider == true)
                        IconButton(
                            onPressed: () {
                              Provider.of<themeProvider>(context, listen: false)
                                  .set(false);
                            },
                            icon: const Icon(
                              Iconsax.moon,
                              color: Colors.white,
                              size: 28,
                            ))
                      else
                        IconButton(
                            onPressed: () {
                              Provider.of<themeProvider>(context, listen: false)
                                  .set(true);
                            },
                            icon: const Icon(
                              Iconsax.sun_1,
                              color: Colors.white,
                              size: 28,
                            ))
                    ],
                  ),
                  pinned: true,
                  toolbarHeight: 50,
                  expandedHeight: 220,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                          color: Colors.black,
                          image: DecorationImage(
                              image: AssetImage(
                                'assets/images/background.png',
                              ),
                              fit: BoxFit.cover)),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Story')
                            .where('uid', whereIn: following)
                            .orderBy('datePublished', descending: true)
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          }
                          //unique uid
                          var list = [];
                          snapshot.data!.docs.forEach((element) {
                            list.add(element.data()['uid']);
                          });
                          var data = list.toSet().toList();
                          bool data2 = data
                              .contains(FirebaseAuth.instance.currentUser!.uid);

                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: data.isEmpty ? 1 : data.length,
                            itemBuilder: (contex, index) {
                              // ignore: prefer_typing_uninitialized_variables
                              // string used because bool doesn't work.
                              String isSeen = "true";
                              if (data.isNotEmpty) {
                                for (var i = 0; i < list.length + 1; i++) {
                                  var a = snapshot
                                      .data!.docs[i == list.length ? i - 1 : i]
                                      .data()['isSeen']
                                      .contains(FirebaseAuth
                                          .instance.currentUser!.uid);

                                  if (!a) {
                                    isSeen = "false";
                                  }
                                }
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (index == 0)
                                    GestureDetector(
                                      onTap: (() => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => data2
                                                  ? storyPage(
                                                      uid: FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                    )
                                                  : const addStoryPage()))),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 100),
                                        child: Column(
                                          children: [
                                            data2
                                                ? Container(
                                                    width: 85,
                                                    height: 85,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                profImage),
                                                            fit: BoxFit.cover),
                                                        border: Border.all(
                                                            color: const Color
                                                                    .fromRGBO(
                                                                0, 86, 255, 1),
                                                            width: 3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    85 * 0.4)),
                                                  )
                                                : Container(
                                                    width: 85,
                                                    height: 85,
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    85 * 0.4)),
                                                    child: const Icon(
                                                      Iconsax.add,
                                                      color: Colors.white,
                                                      size: 40,
                                                    ),
                                                  ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.only(top: 7),
                                              width: 120,
                                              child: const Center(
                                                child: Text(
                                                  "Hikayen",
                                                  maxLines: 2,
                                                  softWrap: false,
                                                  style: TextStyle(
                                                      fontFamily: 'font2',
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      overflow:
                                                          TextOverflow.fade),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (index == 0)
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 125,
                                        ),
                                        Container(
                                          width: 3,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ],
                                    ),
                                  if (data.isNotEmpty &&
                                      // ignore: unrelated_type_equality_checks
                                      snapshot.data!.docs[index]
                                              .data()['uid'] !=
                                          FirebaseAuth
                                              .instance.currentUser!.uid)
                                    storyCard(
                                      isSeen: isSeen,
                                      uid: data,
                                      index: index,
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                      : StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Posts')
                              .where('uid', whereIn: following)
                              .orderBy('datePublished', descending: true)
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(50),
                                child: Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.black,
                                  backgroundColor: Colors.white,
                                )),
                              );
                            }
                            return snapshot.data!.docs.isNotEmpty
                                ? ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (ctx, index) {
                                      return postCard(
                                        tag: index,
                                        snap: snapshot.data!.docs[index].data(),
                                      );
                                    },
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
            )
          : const Center(
              child: Icon(
                Iconsax.image,
                size: 80,
                color: Colors.black,
              ),
            ),
    );
  }
}
