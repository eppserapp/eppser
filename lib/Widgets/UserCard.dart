import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/Chat.dart';
import 'package:eppser/Pages/Profile.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class userCard extends StatefulWidget {
  final snap;
  const userCard({super.key, this.snap});

  @override
  State<userCard> createState() => _userCardState();
}

class _userCardState extends State<userCard> {
  String profImage = "";
  String name = "";
  String surname = "";
  bool isLoading = false;
  var isFollowing;
  int followers = 0;
  int following = 0;
  bool tick = false;
  Map usersId = {};
  var userData;

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
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.snap)
          .get();
      userData = userSnap.data()!;
      profImage = userSnap['profImage'];
      name = userSnap['name'];
      surname = userSnap['surname'];
      followers = int.parse(
          NumberFormat.compact().format(userSnap.data()!['followers'].length));
      following = int.parse(
          NumberFormat.compact().format(userSnap.data()!['following'].length));
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      tick = userSnap['tick'];

      setState(() {});
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    usersId = {
      'senderId': FirebaseAuth.instance.currentUser!.uid,
      'recieverId': widget.snap
    };
    return isLoading
        ? const SizedBox()
        : Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: isLoading
                      ? const SizedBox()
                      : Image.network(
                          profImage,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile(
                                    uid: widget.snap,
                                  ))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                surname,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              tick
                                  ? const Padding(
                                      padding: EdgeInsets.only(top: 5, left: 2),
                                      child: Icon(
                                        Iconsax.verify5,
                                        color: Colors.black,
                                        size: 14,
                                      ),
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.black,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Chat(
                                          snap: usersId,
                                        )));
                          },
                          icon: const Icon(
                            Iconsax.message_2,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      )),
                ),
                const SizedBox(
                  width: 20,
                ),
                FirebaseAuth.instance.currentUser!.uid != widget.snap
                    ? isFollowing
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.black,
                                  child: IconButton(
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
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                )),
                          )
                        : Align(
                            alignment: Alignment.centerRight,
                            child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.black,
                                  child: IconButton(
                                    onPressed: () async {
                                      await FireStoreMethods().followUser(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        userData['uid'],
                                      );

                                      setState(() {
                                        isFollowing = true;
                                        followers++;
                                      });
                                    },
                                    icon: const Icon(
                                      Iconsax.tick_circle,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                )),
                          )
                    : const SizedBox()
              ],
            ),
          );
  }
}
