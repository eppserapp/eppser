import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Widgets/UserCard.dart';
import 'package:flutter/material.dart';

class StoryViewing extends StatefulWidget {
  final snap;
  const StoryViewing({
    super.key,
    required this.snap,
  });

  @override
  State<StoryViewing> createState() => _StoryViewingState();
}

class _StoryViewingState extends State<StoryViewing> {
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
          .collection("Story")
          .doc(widget.snap)
          .get();
      userData = userSnap.data()!;
      likes = userData['likes'];
      isSeen = userData['isSeen'];

      setState(() {});
    } catch (e) {}
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
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              title: const Text(
                "Hikayeyi Görenler",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: ListView.builder(
                itemCount: isSeen.length,
                itemBuilder: ((context, index) => userCard(
                      snap: isSeen[index],
                    ))));
  }
}
