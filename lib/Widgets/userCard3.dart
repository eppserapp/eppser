import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class userCard3 extends StatefulWidget {
  final snap;
  final uid;
  const userCard3({super.key, required this.snap, required this.uid});

  @override
  State<userCard3> createState() => _userCard3State();
}

class _userCard3State extends State<userCard3> {
  String profImage = "";
  String name = "";
  String surname = "";
  bool isLoading = false;
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
          .doc(widget.uid)
          .get();
      userData = userSnap.data()!;
      profImage = userSnap['profImage'];
      name = userSnap['name'];
      surname = userSnap['surname'];
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
                                    uid: widget.uid,
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
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          );
  }
}
