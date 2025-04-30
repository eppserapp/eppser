import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/Profile.dart';
import 'package:eppser/Pages/users2.dart';
import 'package:eppser/Providers/dataIndexProvider.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Story/controller/story_controller.dart';
import 'package:eppser/Story/utils.dart';
import 'package:eppser/Story/widgets/story_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class StoryPage extends StatefulWidget {
  const StoryPage(
      {super.key,
      required this.uid,
      this.controller,
      this.index,
      this.dataLength});
  final uid;
  final PageController? controller;
  final index;
  final dataLength;
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final storyItems = <StoryItem>[];
  bool isLoading = false;
  var data = {};
  var data2;
  String profImage = "";
  String name = "";
  String surname = "";
  bool tick = false;
  var provider;
  final storyController = StoryController();

  void handleCompleted() {
    final currentIndex = widget.index;
    final isLastPage = widget.dataLength - 1 == currentIndex;
    if (isLastPage) {
      Navigator.of(context).pop();
    } else {
      widget.controller!.animateToPage(widget.index + 1,
          duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    }
  }

  void goBack() {
    final currentIndex = widget.index;
    final isFirstPage = widget.dataLength - widget.index == currentIndex;

    if (isFirstPage) {
      widget.controller!.animateToPage(widget.index - 1,
          duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('Story')
          .where('uid', isEqualTo: widget.uid)
          .orderBy('datePublished', descending: false)
          .get()
          .then((value) => value.docs.forEach((element) {
                data.addAll(element.data());
                if (!data['video']) {
                  data['description'] == ""
                      ? storyItems.add(StoryItem.pageImage(
                          url: data['postUrl'][0],
                          controller: storyController,
                          duration: const Duration(seconds: 5)))
                      : storyItems.add(StoryItem.pageImage(
                          url: data['postUrl'][0],
                          controller: storyController,
                          caption: data['description'],
                          duration: const Duration(seconds: 5)));
                }
                if (data['video']) {
                  data['description'] == ""
                      ? storyItems.add(StoryItem.pageVideo(data['postUrl'],
                          controller: storyController,
                          duration: Duration(milliseconds: data['duration'])))
                      : storyItems.add(StoryItem.pageVideo(data['postUrl'],
                          controller: storyController,
                          caption: data['description'],
                          duration: Duration(milliseconds: data['duration'])));
                }
              }));
      var ds = await FirebaseFirestore.instance
          .collection('Story')
          .where('uid', isEqualTo: widget.uid)
          .orderBy('datePublished', descending: false)
          .get();
      data2 = ds.docs.toList();

      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .get();

      profImage = userSnap['profImage'];
      name = userSnap['name'];
      surname = userSnap['surname'];
      tick = userSnap['tick'];

      setState(() {});
    } catch (e) {
      print(e);
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
  void dispose() {
    storyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<dataIndexProvider>(context, listen: true).data;
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          )
        : Stack(
            children: <Widget>[
              Material(
                type: MaterialType.transparency,
                child: FirebaseAuth.instance.currentUser!.uid == widget.uid
                    ? StoryView(
                        storyItems: storyItems,
                        data: data2,
                        onComplete: () => Navigator.pop(context),
                        onVerticalSwipeComplete: (direction) {
                          if (direction == Direction.down) {
                            Navigator.pop(context);
                          }
                        },
                        progressPosition: ProgressPosition.top,
                        repeat: false,
                        controller: storyController,
                      )
                    : StoryView(
                        storyItems: storyItems,
                        goBack: goBack,
                        data: data2,
                        onStoryShow: (value) async {},
                        onComplete: handleCompleted,
                        onVerticalSwipeComplete: (direction) {
                          if (direction == Direction.down) {
                            Navigator.pop(context);
                          }
                        },
                        progressPosition: ProgressPosition.top,
                        repeat: false,
                        controller: storyController,
                      ),
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Profile(
                                uid: data['uid'],
                              ))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 38),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          isLoading
                              ? const SizedBox()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30 * 0.4),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(profImage))),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text(
                                        "${name}" + " " + "${surname}",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    tick
                                        ? const Padding(
                                            padding: EdgeInsets.only(top: 3),
                                            child: Icon(
                                              Iconsax.verify5,
                                              size: 15,
                                              color:
                                                  Color.fromRGBO(0, 86, 255, 1),
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                        ]),
                  ),
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: FirebaseAuth.instance.currentUser!.uid == widget.uid
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: IconButton(
                                onPressed: () {
                                  showDialog(
                                    useRootNavigator: false,
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Colors.black,
                                        child: ListView(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shrinkWrap: true,
                                            children: [
                                              'Sil',
                                            ]
                                                .map(
                                                  (e) => InkWell(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 12,
                                                                horizontal: 16),
                                                        child: Text(e),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                        await FireStoreMethods()
                                                            .deleteStory(
                                                                data2[provider]
                                                                        .data()[
                                                                    'postId']);
                                                        await FirebaseStorage
                                                            .instance
                                                            .refFromURL(
                                                                data2[provider]
                                                                        .data()[
                                                                    'postUrl'])
                                                            .delete();
                                                      }),
                                                )
                                                .toList()),
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Iconsax.trash,
                                  size: 20,
                                  color: Colors.white,
                                )),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                                onPressed: () {
                                  storyController.pause();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => usersPage2(
                                                collection: "Story",
                                                snap: data2[provider]
                                                    .data()['postId'],
                                              )));
                                },
                                icon: const Icon(
                                  Iconsax.eye,
                                  size: 20,
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      )
                    : const SizedBox(),
              )
            ],
          );
  }
}
