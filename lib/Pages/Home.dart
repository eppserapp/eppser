import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/CommunityPage.dart';
import 'package:eppser/Pages/CreateCommunity.dart';
import 'package:eppser/Pages/NotificationsPage.dart';
import 'package:eppser/Providers/themeProvider.dart';
import 'package:eppser/Theme/Theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  const Text(
                    "eppser",
                    style: TextStyle(
                        fontFamily: 'font1', fontSize: 38, color: Colors.white),
                  ).animate().move(
                        duration: 800.ms,
                        begin: const Offset(-20, 0),
                        end: Offset.zero,
                        curve: Curves.easeOut,
                      ),
                  const Text(" "),
                  const Text('test version',
                          style: TextStyle(
                              fontFamily: 'font1',
                              fontSize: 15,
                              color: Colors.amber))
                      .animate()
                      .move(
                        duration: 800.ms,
                        begin: const Offset(-20, 0),
                        end: Offset.zero,
                        curve: Curves.easeOut,
                      ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<ThemeProvider>(builder: (context, provider, child) {
                  return IconButton(
                    onPressed: () async {
                      provider.toggleTheme();
                    },
                    icon: provider.themeData == lightMode
                        ? const Icon(
                            Iconsax.moon,
                            size: 28,
                            color: Colors.white,
                          )
                        : const Icon(
                            Iconsax.sun_1,
                            size: 28,
                            color: Colors.white,
                          ),
                  );
                }).animate().fadeIn().move(delay: 300.ms, duration: 600.ms),
                IconButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ));
                  },
                  icon: const Icon(
                    Iconsax.notification,
                    size: 28,
                    color: Colors.white,
                  ),
                ).animate().fadeIn().move(delay: 500.ms, duration: 600.ms),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            // Eklenen kısım: height sınırı için
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Theme.of(context).textTheme.bodyMedium?.color,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontSize: 20,
                    ),
                    tabs: const [
                      Tab(
                        text: "Keşfet",
                      ),
                      Tab(text: "Üyeliklerim"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // "Tümü" sekmesi: Tüm onaylı community'ler
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Community')
                              .where('approved', isEqualTo: true)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                  child: Text(
                                "Hiç Topluluk Yok",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                    fontSize: 16),
                              ));
                            }
                            final docs = snapshot.data!.docs;
                            return ListView.builder(
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data =
                                    docs[index].data() as Map<String, dynamic>;
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommunityPage(
                                          communityId: data['communityId']),
                                    ),
                                  ),
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
                                            right: 8,
                                            top: 5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      data['members'] != null
                                                          ? data['members']
                                                              .length
                                                              .toString()
                                                          : "0",
                                                      style: GoogleFonts.exo(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Icon(
                                                      Iconsax.profile_2user,
                                                      size: 22,
                                                      color: Colors.deepOrange,
                                                    )
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  20,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                              ),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child:
                                                        data['photoUrl'] != null
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24),
                                                                child: SizedBox(
                                                                  height: 60,
                                                                  width: 60,
                                                                  child:
                                                                      CachedNetworkImage(
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
                                                                    imageUrl: data[
                                                                        'photoUrl'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        const Icon(
                                                                            Icons
                                                                                .error,
                                                                            color:
                                                                                Colors.black),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                height: 60,
                                                                width: 60,
                                                                decoration: BoxDecoration(
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        0,
                                                                        86,
                                                                        255,
                                                                        1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            24)),
                                                                child:
                                                                    const Icon(
                                                                  Iconsax
                                                                      .people,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 50,
                                                                ),
                                                              ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          data['name'] ??
                                                              "Topluluk Adı",
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.color,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          "lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla nec purus feugiat, molestie ipsum et, varius dolor.",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Container(
                                          height: 3,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // "Takip" sekmesi: Geçerli kullanıcının (uid) üye olduğu onaylı community'ler
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Community')
                              .where('approved', isEqualTo: true)
                              .where('members',
                                  arrayContains:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                  child: Text(
                                "Takip ettiğin Topluluk Yok",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                    fontSize: 16),
                              ));
                            }
                            final docs = snapshot.data!.docs;
                            return ListView.builder(
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data =
                                    docs[index].data() as Map<String, dynamic>;
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommunityPage(
                                          communityId: data['communityId']),
                                    ),
                                  ),
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
                                            right: 8,
                                            top: 5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      data['members'] != null
                                                          ? data['members']
                                                              .length
                                                              .toString()
                                                          : "0",
                                                      style: GoogleFonts.exo(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Icon(
                                                      Iconsax.profile_2user,
                                                      size: 22,
                                                      color: Colors.deepOrange,
                                                    )
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  20,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                              ),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child:
                                                        data['photoUrl'] != null
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24),
                                                                child: SizedBox(
                                                                  height: 60,
                                                                  width: 60,
                                                                  child:
                                                                      CachedNetworkImage(
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
                                                                    imageUrl: data[
                                                                        'photoUrl'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        const Icon(
                                                                            Icons
                                                                                .error,
                                                                            color:
                                                                                Colors.black),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                height: 60,
                                                                width: 60,
                                                                decoration: BoxDecoration(
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        0,
                                                                        86,
                                                                        255,
                                                                        1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            24)),
                                                                child:
                                                                    const Icon(
                                                                  Iconsax
                                                                      .people,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 50,
                                                                ),
                                                              ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          data['name'] ??
                                                              "Topluluk Adı",
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.color,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          "lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla nec purus feugiat, molestie ipsum et, varius dolor.",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Container(
                                          height: 3,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                builder: (context) => const CreateCommunity(),
              ));
        },
        child: const Icon(Iconsax.add,
            size: 30, color: Colors.deepOrange), // Change the icon as needed
      ),
    );
  }
}
