import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Database/Groups.dart';
import 'package:eppser/Database/GroupsMessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class GroupCard extends StatefulWidget {
  final groupId;
  final communityId;
  const GroupCard({super.key, this.groupId, this.communityId});

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  var groupData;
  var groupMessage;
  StreamSubscription? subscription;
  String name = "";
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getData();
    dataHive();
    listenGroupMessages();
  }

  void listenGroupMessages() {
    subscription?.cancel();
    subscription = FirebaseFirestore.instance
        .collection('Community')
        .doc(widget.communityId)
        .collection('Groups')
        .doc(widget.groupId)
        .collection('Messages')
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      Map<String, dynamic> updatedMessages = {};
      int index = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data();
        // Firestore'dan gelen Timestamp'i DateTime'a çevir
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate();
        }
        updatedMessages[index.toString()] = data;
        index++;
      }
      GroupMessageBox.saveGroupMessage(widget.groupId, updatedMessages);
      setState(() {
        groupMessage = updatedMessages;
      });
    });
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      FirebaseFirestore.instance
          .collection('Community')
          .doc(widget.communityId)
          .collection('Groups')
          .doc(widget.groupId)
          .snapshots()
          .listen((snap) {
        groupData = snap.data();
        GroupBox.saveGroupData(widget.groupId, groupData);
        setState(() {});
      });
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  dataHive() {
    if (groupData != null) {
      groupMessage = GroupMessageBox.getGroupMessage(groupData['groupId']);
      name = groupData['name'];
    }
  }

  String getTimeAgo(DateTime dateTime) {
    DateTime localDateTime = dateTime.toLocal();
    DateTime now = DateTime.now().toLocal();

    if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day) {
      // Bugünse sadece saat olarak göster
      return DateFormat.Hm().format(localDateTime);
    } else if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day - 1) {
      // Dünse "Dün" olarak göster
      return "Dün";
    } else {
      // Diğer durumlar için tarih formatını kullan
      return DateFormat.yMMMMd('TR_tr').format(localDateTime);
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading || groupData == null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          color: Colors.black.withOpacity(0.04),
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.70,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(20)),
                            height: 20, // Burada uygun bir yükseklik belirleyin
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.40,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(20)),
                              height:
                                  20, // Burada uygun bir yükseklik belirleyin
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        : GestureDetector(
            onLongPress: () async {
              if ((groupData['admins'] as List)
                  .contains(FirebaseAuth.instance.currentUser!.uid)) {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Grubu Sil",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                    content: Text("Bu grubu silmek istediğine emin misin?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          "İptal",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          "Sil",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('Community')
                        .doc(groupData['communityId'])
                        .collection('Groups')
                        .doc(groupData['groupId'])
                        .delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Grup silindi')),
                    );
                  } catch (e) {
                    print("Silme hatası: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Silme işlemi başarısız')),
                    );
                  }
                }
              }
            },
            child: ValueListenableBuilder<Box<dynamic>>(
              valueListenable: Hive.box('groupBox').listenable(),
              builder: (context, box, child) {
                dataHive();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(70 * 0.4),
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: groupData['photoUrl'] != null
                                    ? CachedNetworkImage(
                                        filterQuality: FilterQuality.low,
                                        placeholderFadeInDuration:
                                            const Duration(microseconds: 1),
                                        fadeOutDuration:
                                            const Duration(microseconds: 1),
                                        fadeInDuration:
                                            const Duration(milliseconds: 1),
                                        imageUrl: groupData['photoUrl'],
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error,
                                                color: Colors.black),
                                      )
                                    : Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                0, 86, 255, 1),
                                            borderRadius: BorderRadius.circular(
                                                70 * 0.4)),
                                        child: const Icon(
                                          Iconsax.people,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.55),
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              if (groupMessage != null &&
                                  groupMessage.values.isNotEmpty)
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.60),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          groupMessage.values.last['text'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (groupMessage
                                                  .values.last['senderId'] ==
                                              FirebaseAuth
                                                  .instance.currentUser?.uid &&
                                          groupMessage.values.last['sending'])
                                        const Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Icon(
                                            Iconsax.clock,
                                            color: Colors.grey,
                                            size: 12,
                                          ),
                                        ),
                                      if (groupMessage
                                                  .values.last['senderId'] ==
                                              FirebaseAuth
                                                  .instance.currentUser?.uid &&
                                          !groupMessage.values.last['sending'])
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 3,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Iconsax.tick_circle,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                                size: 12,
                                              ),
                                              Icon(
                                                Iconsax.tick_circle,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                                size: 12,
                                              )
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (groupMessage != null && groupMessage.values.isNotEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              (() {
                                final dateValue =
                                    groupMessage.values.last['date'];
                                final dateTime = dateValue is Timestamp
                                    ? dateValue.toDate()
                                    : dateValue;
                                return getTimeAgo(dateTime);
                              }()),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (groupMessage.values
                                  .where((message) =>
                                      !(message['isSeen'] as List).contains(
                                          FirebaseAuth
                                              .instance.currentUser!.uid) &&
                                      message['senderId'] !=
                                          FirebaseAuth
                                              .instance.currentUser?.uid)
                                  .length >
                              0)
                            Container(
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(
                                    color: const Color.fromRGBO(0, 86, 255, 1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    groupMessage.values
                                        .where((message) =>
                                            !(message['isSeen'] as List)
                                                .contains(FirebaseAuth.instance
                                                    .currentUser!.uid) &&
                                            message['senderId'] !=
                                                FirebaseAuth
                                                    .instance.currentUser?.uid)
                                        .length
                                        .toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                )),
                        ],
                      )
                  ],
                );
              },
            ),
          );
  }
}
