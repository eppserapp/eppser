import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/StoryPage.dart';
import 'package:flutter/material.dart';

class storyCard extends StatefulWidget {
  const storyCard(
      {required this.uid, super.key, required this.index, this.isSeen});
  final uid;
  final index;
  final isSeen;
  @override
  State<storyCard> createState() => _storyCardState();
}

class _storyCardState extends State<storyCard> {
  var userData = {};
  var data = {};
  String profImage = "";
  String name = "";
  String surname = "";
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    getData();
    controller = PageController(initialPage: widget.index);
  }

  getData() async {
    try {
      await FirebaseFirestore.instance
          .collection('Story')
          .where('uid', isEqualTo: widget.uid)
          .get()
          .then((value) => value.docs.forEach((element) {
                data.addAll(element.data());
              }));
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid[widget.index])
          .get();

      userData = userSnap.data()!;

      profImage = userData['profImage'];
      name = userData['name'];
      surname = userData['surname'];

      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PageView.builder(
                  controller: controller,
                  itemCount: widget.uid.length,
                  itemBuilder: ((context, index) {
                    return StoryPage(
                      dataLength: widget.uid.length,
                      index: widget.index,
                      controller: controller,
                      uid: widget.uid[index],
                    );
                  }))))),
      child: Padding(
        padding: const EdgeInsets.only(top: 80, left: 15),
        child: Column(
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(profImage), fit: BoxFit.cover),
                  border: Border.all(
                      color: widget.isSeen == "true"
                          ? Colors.white
                          : const Color.fromRGBO(0, 86, 255, 1),
                      width: 3),
                  borderRadius: BorderRadius.circular(85 * 0.4)),
            ),
            Container(
              padding: const EdgeInsets.only(top: 7),
              width: 120,
              child: Center(
                child: Text(
                  "$name" + " " + "$surname",
                  maxLines: 2,
                  softWrap: false,
                  style: const TextStyle(
                      fontFamily: 'font2',
                      fontSize: 15,
                      color: Colors.white,
                      overflow: TextOverflow.fade),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
