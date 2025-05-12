import 'package:cached_network_image/cached_network_image.dart';
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
  var profImage;
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
    return isLoading
        ? const SizedBox()
        : Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: profImage != null
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
                                    color: const Color.fromRGBO(0, 86, 255, 1),
                                    borderRadius:
                                        BorderRadius.circular(70 * 0.4)),
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
                              imageUrl: profImage,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error, color: Colors.black),
                            ),
                          ),
                        )
                      : Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 86, 255, 1),
                              borderRadius: BorderRadius.circular(70 * 0.4)),
                          child: const Icon(
                            Iconsax.user,
                            color: Colors.white,
                            size: 50,
                          ),
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
                              fontSize: 22,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                surname,
                                style: const TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                              tick
                                  ? const Padding(
                                      padding: EdgeInsets.only(top: 5, left: 2),
                                      child: Icon(
                                        Iconsax.verify5,
                                        size: 18,
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
                if (widget.snap != FirebaseAuth.instance.currentUser!.uid)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50 * 0.4)),
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
                                            snap: widget.snap,
                                          )));
                            },
                            icon: const Icon(
                              Iconsax.messages_2,
                              color: Colors.white,
                              size: 34,
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
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50 * 0.4)),
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
                                      size: 34,
                                    ),
                                  ),
                                )),
                          )
                        : Align(
                            alignment: Alignment.centerRight,
                            child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50 * 0.4)),
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
                                      size: 34,
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
