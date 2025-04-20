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
  final snap;
  const GroupCard({super.key, this.snap});

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  var groupData;
  var groupMessage;
  String name = "";
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getData();
    dataHive();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var Snap = await FirebaseFirestore.instance
          .collection('Groups')
          .doc(widget.snap)
          .get();

      groupData = Snap.data();

      setState(() {});
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
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  children: [
                    SimpleDialogOption(
                      padding: const EdgeInsets.all(10),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Sessize al'),
                    )
                  ],
                ),
              );
            },
            child: ValueListenableBuilder<Box<dynamic>>(
              valueListenable: Hive.box('groupBox').listenable(),
              builder: (context, box, child) {
                // Eğer kutu boşsa, alternatif bir widget döndürün
                if (box.values.isEmpty) {
                  return Container(); // ...veya uygun bir placeholder widget
                }
                final lastElement = box.values.last;
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
                              borderRadius: BorderRadius.circular(30),
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
                                            borderRadius:
                                                BorderRadius.circular(30)),
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
                                      if (groupMessage.values
                                              .where((message) =>
                                                  !(message['isSeen'] as List)
                                                      .contains(FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid) &&
                                                  message['senderId'] !=
                                                      FirebaseAuth.instance
                                                          .currentUser?.uid)
                                              .length >
                                          0)
                                        Container(
                                            margin: const EdgeInsets.only(
                                              left: 3,
                                            ),
                                            height: 12,
                                            width: 12,
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Center(
                                              child: Text(
                                                groupMessage.values
                                                    .where((message) =>
                                                        !(message['isSeen']
                                                                as List)
                                                            .contains(
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid) &&
                                                        message['senderId'] !=
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid)
                                                    .length
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8),
                                              ),
                                            ))
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (groupMessage != null && groupMessage.values.isNotEmpty)
                      if (groupMessage.values.last['date'] != null)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: Text(
                              getTimeAgo(groupMessage.values.last['date']),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                  ],
                );
              },
            ),
          );
  }
}
