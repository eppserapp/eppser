import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eppser/Pages/CreateEvent.dart';
import 'package:eppser/Pages/StoryPage.dart';
import 'package:eppser/Pages/addStory.dart';
import 'package:eppser/Widgets/storyCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  bool isLoading = false;
  int chunkIndex = 0;
  List following = [];
  String profImage = "";

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      following = userSnap.data()?['following'];
      profImage = userSnap.data()?['profImage'];
      following.add(FirebaseAuth.instance.currentUser!.uid);

      setState(() {});
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  int chunkSize = 10;
  List<List<dynamic>> get chunks {
    following.add(FirebaseAuth.instance.currentUser!.uid);
    List<dynamic> myList = following;
    return List.generate(
      (myList.length / chunkSize).ceil(),
      (i) => myList.sublist(
          i * chunkSize,
          (i + 1) * chunkSize < myList.length
              ? (i + 1) * chunkSize
              : myList.length),
    );
  }

  Stream<QuerySnapshot> getStoriesStream(List<dynamic> chunk) {
    if (chunk.isEmpty) {
      return Stream<QuerySnapshot>.empty();
    }
    return FirebaseFirestore.instance
        .collection('Story')
        .where('uid', whereIn: chunk)
        .orderBy('datePublished', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 180,
            pinned: true,
            centerTitle: false,
            title: const Text(
              "Timeline",
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    color: Colors.black,
                    image: DecorationImage(
                        image: AssetImage(
                          'assets/images/background.jpg',
                        ),
                        fit: BoxFit.cover)),
                child: Stack(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: getStoriesStream(chunks[chunkIndex]),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        } else {
                          //unique uid
                          var list = [];
                          snapshot.data?.docs.forEach((element) {
                            if (element.data() is Map) {
                              list.addAll([(element.data() as Map)['uid']]);
                            }
                          });

                          var data = list.toSet().toList();
                          bool data2 = data
                              .contains(FirebaseAuth.instance.currentUser!.uid);

                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: data.isEmpty ? 1 : data.length,
                            itemBuilder: (contex, index) {
                              if (index >= 10 && index % 10 == 0) {
                                chunkIndex++;
                              }
                              bool isSeen = true;
                              if (data.isNotEmpty) {
                                for (var i = 0; i < list.length + 1; i++) {
                                  var index = i == list.length ? i - 1 : i;
                                  var a = (snapshot.data!.docs[index].data()
                                          as Map<String, dynamic>)['isSeen']
                                      .contains(FirebaseAuth
                                          .instance.currentUser!.uid);
                                  if (!a) {
                                    isSeen = false;
                                    break;
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
                                                  ? StoryPage(
                                                      uid: FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                    )
                                                  : const addStoryPage()))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 80),
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
                                                        border: isSeen
                                                            ? Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 3)
                                                            : Border.all(
                                                                color: const Color
                                                                    .fromRGBO(0,
                                                                    86, 255, 1),
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
                                              width: 100,
                                              child: const Center(
                                                child: Text(
                                                  "Hikayen",
                                                  maxLines: 2,
                                                  softWrap: false,
                                                  style: TextStyle(
                                                      fontFamily: 'font2',
                                                      fontSize: 12,
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
                                          height: 100,
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
                                      data[index] !=
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
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Events')
                      .orderBy('dateCreated', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 4),
                          Icon(
                            Iconsax.calendar_1,
                            size: 100,
                          ),
                          const SizedBox(height: 10),
                          Center(
                              child: Text('Şuanlık bir etkinlik yok!',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))),
                        ],
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        return GestureDetector(
                          // onTap: () => Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => CommunityPage(
                          //         communityId: data['communityId']),
                          //   ),
                          // ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    child: Container(
                                      width: double.infinity,
                                      height: 200,
                                      child: data['imageUrl'] != null
                                          ? Image.network(
                                              data['imageUrl'],
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/images/moneybackground.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 8,
                                    top: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Iconsax.flag_2,
                                              size: 22,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              "Etkinlik",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Iconsax.calendar_1,
                                              size: 20,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              data['eventDate'] != null
                                                  ? DateFormat('dd.MM.yyyy')
                                                      .format((data['eventDate']
                                                              as Timestamp)
                                                          .toDate()
                                                          .toLocal())
                                                  : "0",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    left: 10,
                                    right: 10,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: data['photoUrl'] != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                    child: SizedBox(
                                                      height: 60,
                                                      width: 60,
                                                      child: CachedNetworkImage(
                                                        placeholderFadeInDuration:
                                                            const Duration(
                                                                microseconds:
                                                                    1),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                microseconds:
                                                                    1),
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    1),
                                                        imageUrl:
                                                            data['photoUrl'],
                                                        fit: BoxFit.cover,
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.error,
                                                                color: Colors
                                                                    .black),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    height: 60,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromRGBO(
                                                            0, 86, 255, 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24)),
                                                    child: const Icon(
                                                      Iconsax.people,
                                                      color: Colors.white,
                                                      size: 50,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  data['title'] ??
                                                      "Etkinlik Adı",
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  data['description'] ??
                                                      "Etkinlik Açıklaması",
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                    fontSize: 10,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  height: 3,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateEvent(),
              ));
        },
        child: const Icon(Iconsax.add,
            size: 30, color: Colors.deepOrange), // Change the icon as needed
      ),
    );
  }
}
