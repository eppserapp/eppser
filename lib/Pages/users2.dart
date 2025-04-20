import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:eppser/Widgets/userCard3.dart';
import 'package:flutter/material.dart';

class usersPage2 extends StatefulWidget {
  final snap;
  final collection;
  const usersPage2({super.key, required this.snap, required this.collection});

  @override
  State<usersPage2> createState() => _usersPage2State();
}

class _usersPage2State extends State<usersPage2> {
  bool isLoading = false;
  var userData;
  List likes = [];
  List isSeen = [];
  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection(widget.collection)
          .doc(widget.snap)
          .get();
      userData = userSnap.data()!;
      likes = userData['likes'];
      isSeen = userData['isSeen'];

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
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: ListView.builder(
                itemCount:
                    widget.collection == "Posts" ? likes.length : isSeen.length,
                itemBuilder: ((context, index) => userCard3(
                    snap: widget.snap,
                    uid: widget.collection == "Posts"
                        ? likes[index]
                        : isSeen[index]))));
  }
}
