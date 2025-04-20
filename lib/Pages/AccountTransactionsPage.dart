import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountTransactionsPage extends StatefulWidget {
  const AccountTransactionsPage({super.key});

  @override
  State<AccountTransactionsPage> createState() =>
      _AccountTransactionsPageState();
}

class _AccountTransactionsPageState extends State<AccountTransactionsPage> {
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(userId)) {
      final data = prefs.getString(userId);
      if (data != null) {
        return Map<String, dynamic>.from(
            jsonDecode(data) as Map<String, dynamic>);
      }
    }
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      if (userData != null) {
        await prefs.setString(userId, jsonEncode(userData));
        return userData;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Hareketleri'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('TransactionHistory')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: SizedBox(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.archive,
                          color: Colors.grey,
                          size: 100,
                        ),
                        Text(
                          'Hesap Geçmişi Boş!',
                          style: TextStyle(color: Colors.grey, fontSize: 20),
                        )
                      ],
                    ),
                  ));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: SizedBox(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.archive,
                          color: Colors.grey,
                          size: 100,
                        ),
                        Text(
                          'Hesap Geçmişi Boş!',
                          style: TextStyle(color: Colors.grey, fontSize: 20),
                        )
                      ],
                    ),
                  ));
                }

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                        future: getUserInfo(
                            snapshot.data?.docs[index].data()['userId']),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const Center(
                                child: SizedBox(
                              height: 300,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.archive,
                                    color: Colors.grey,
                                    size: 100,
                                  ),
                                  Text(
                                    'Hesap Geçmişi Boş!',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 20),
                                  )
                                ],
                              ),
                            ));
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 10,
                              top: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: userSnapshot.data?['profImage'] ==
                                              null
                                          ? Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  color: const Color.fromRGBO(
                                                      0, 86, 255, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          70 * 0.4)),
                                              child: const Icon(
                                                Iconsax.user,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      70 * 0.4),
                                              child: SizedBox(
                                                height: 70,
                                                width: 70,
                                                child: CachedNetworkImage(
                                                  placeholderFadeInDuration:
                                                      const Duration(
                                                          microseconds: 1),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          microseconds: 1),
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 1),
                                                  imageUrl: userSnapshot
                                                      .data?['profImage'],
                                                  fit: BoxFit.cover,
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error,
                                                          color: Colors.black),
                                                ),
                                              ),
                                            ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    200,
                                              ),
                                              child: Text(
                                                userSnapshot.data?['name'] +
                                                    " " +
                                                    userSnapshot
                                                        .data?['surname'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    200,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    snapshot.data?.docs[index]
                                                                    .data()[
                                                                'isGold'] ==
                                                            false
                                                        ? 'Para Transferi'
                                                        : 'Altın Transferi',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: NumberFormat(
                                                        "#,###.##", "en_US")
                                                    .format(snapshot
                                                        .data?.docs[index]
                                                        .data()['amount'])
                                                    .toString(),
                                                style: TextStyle(
                                                  color: snapshot.data
                                                                  ?.docs[index]
                                                                  .data()[
                                                              'userId'] ==
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (snapshot.data?.docs[index]
                                                      .data()['isGold'] ==
                                                  false)
                                                TextSpan(
                                                  text: ' ₺',
                                                  style: TextStyle(
                                                    color: snapshot.data
                                                                    ?.docs[index]
                                                                    .data()[
                                                                'userId'] ==
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              if (snapshot.data?.docs[index]
                                                      .data()['isGold'] ==
                                                  true)
                                                TextSpan(
                                                  text: ' gr',
                                                  style: TextStyle(
                                                    color: snapshot.data
                                                                    ?.docs[index]
                                                                    .data()[
                                                                'userId'] ==
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Text(
                                        DateFormat.yMd('tr_TR').format(
                                          (snapshot.data?.docs[index]
                                                      .data()['timestamp']
                                                  as Timestamp)
                                              .toDate(),
                                        ),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ).animate().move(
                                duration: 500.ms,
                                begin: const Offset(-20, 0),
                                end: Offset.zero,
                                curve: Curves.easeOut,
                              );
                        });
                  },
                );
              }),
        ),
      ),
    );
  }
}
