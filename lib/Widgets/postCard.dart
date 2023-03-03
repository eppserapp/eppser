import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/comments.dart';
import 'package:eppser/Pages/profile.dart';
import 'package:eppser/Pages/users.dart';
import 'package:eppser/Pages/users2.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Widgets/fullScreenImage.dart';
import 'package:eppser/Widgets/userCard3.dart';
import 'package:eppser/models/user.dart' as model;
import 'package:eppser/providers/themeProvider.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '../Utils/Utils.dart';
import '../providers/userProvider.dart';

// ignore: camel_case_types
class postCard extends StatefulWidget {
  final snap;
  final tag;
  const postCard({Key? key, required this.snap, this.tag}) : super(key: key);

  @override
  State<postCard> createState() => _postCardState();
}

class _postCardState extends State<postCard> {
  late DateFormat dateFormat;
  late DateFormat timeFormat;
  int commentLen = 0;
  String profImage = "";
  String name = "";
  String surname = "";
  bool tick = false;
  bool isLoading = false;
  var provider;

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void control() {
    FirebaseFirestore.instance.collection('Posts').snapshots().listen((event) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    dateFormat = DateFormat.yMMMMd('tr');
    timeFormat = DateFormat.Hms('tr');
    fetchCommentLen();
    getData();
    control();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.snap['uid'])
          .get();

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
    var val = widget.tag.toString();
    provider = Provider.of<themeProvider>(context, listen: false).theme;
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40 * 0.4),
                  child: isLoading
                      ? const SizedBox()
                      : InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => profilePage(
                                        uid: widget.snap['uid'],
                                      ))),
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CachedNetworkImage(
                              placeholderFadeInDuration:
                                  const Duration(microseconds: 1),
                              fadeOutDuration: const Duration(microseconds: 1),
                              fadeInDuration: const Duration(milliseconds: 1),
                              imageUrl: profImage,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: isLoading
                            ? const SizedBox()
                            : InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => profilePage(
                                              uid: widget.snap['uid'],
                                            ))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${name}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: provider == true
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${surname}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: provider == true
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        tick
                                            ? const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 2, top: 3),
                                                child: Icon(
                                                  Iconsax.verify5,
                                                  size: 14,
                                                  color: Color.fromRGBO(
                                                      0, 86, 255, 1),
                                                ),
                                              )
                                            : const SizedBox()
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                  ],
                ),
              ),
              FirebaseAuth.instance.currentUser!.uid == widget.snap['uid']
                  ? Padding(
                      padding: const EdgeInsets.all(5),
                      child: IconButton(
                        icon: Icon(
                          Iconsax.more,
                          size: 30,
                          color: provider == true ? Colors.black : Colors.white,
                        ),
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
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
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(e),
                                              ),
                                              onTap: () async {
                                                await FirebaseStorage.instance
                                                    .refFromURL(
                                                        widget.snap['postUrl'])
                                                    .delete();
                                                deletePost(
                                                  widget.snap['postId']
                                                      .toString(),
                                                );

                                                // ignore: use_build_context_synchronously
                                                Navigator.of(context).pop();
                                              }),
                                        )
                                        .toList()),
                              );
                            },
                          );
                        },
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => fullScreen(
                        tag: widget.tag, image: widget.snap['postUrl']))),
            onDoubleTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => fullScreen(
                        tag: widget.tag, image: widget.snap['postUrl']))),
            child: Hero(
              tag: '$val',
              child: SizedBox(
                height: 500,
                width: double.infinity,
                child: FastCachedImage(
                  fadeInDuration: const Duration(milliseconds: 1),
                  url: widget.snap['postUrl'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: provider == true ? Colors.black : Colors.white,
                    ),
                  ),
                  errorBuilder: (context, url, error) => Icon(
                    Icons.error,
                    color: provider == true ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onLongPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => usersPage2(
                              snap: widget.snap['postId'],
                              collection: "Posts",
                            ))),
                child: IconButton(
                  icon: widget.snap['likes']
                          .contains(FirebaseAuth.instance.currentUser!.uid)
                      ? const Icon(
                          Iconsax.heart5,
                          size: 35,
                          color: Colors.red,
                        )
                      : Icon(
                          Iconsax.heart,
                          size: 35,
                          color: provider == true ? Colors.black : Colors.white,
                        ),
                  onPressed: () async {
                    await FireStoreMethods().likePost(
                        widget.snap['postId'],
                        FirebaseAuth.instance.currentUser!.uid,
                        widget.snap['likes']);
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Iconsax.message,
                  size: 35,
                  color: provider == true ? Colors.black : Colors.white,
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommentsPage(
                            postId: widget.snap['postId'].toString()))),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 22),
                child: Text(
                  "${NumberFormat.compact().format(widget.snap['likes'].length)} Beğenme",
                  style: TextStyle(
                    color: provider == true ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          widget.snap['description'] != ""
              ? InkWell(
                  onTap: () => showModalBottomSheet(
                      backgroundColor:
                          provider == true ? Colors.white : Colors.black,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25))),
                      context: context,
                      builder: (context) {
                        return Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned(
                                top: 15,
                                child: Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          39, 39, 39, 1.000),
                                      borderRadius: BorderRadius.circular(5)),
                                )),
                            SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  "${widget.snap['description']}",
                                  style: TextStyle(
                                      color: provider == true
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, top: 5),
                            child: Text("${widget.snap['description']}",
                                maxLines: 2,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: provider == true
                                      ? Colors.black
                                      : Colors.white,
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                child: Container(
                  padding: const EdgeInsets.only(left: 5, top: 3),
                  child: Text(
                    ' $commentLen Yorum',
                    style: TextStyle(
                      color: provider == true ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentsPage(
                      postId: widget.snap['postId'].toString(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    dateFormat.format(widget.snap['datePublished'].toDate()),
                    style: TextStyle(
                      color: provider == true ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
