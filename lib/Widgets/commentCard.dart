import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:eppser/providers/themeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final snap;
  final postId;
  const CommentCard({Key? key, required this.snap, required this.postId})
      : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late DateFormat dateFormat;
  late DateFormat timeFormat;
  bool isLoading = false;
  String profImage = "";
  String name = "";
  String surname = "";
  var provider;

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.snap.data()['uid'])
          .get();

      profImage = userSnap['profImage'];
      name = userSnap['name'];
      surname = userSnap['surname'];

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
    initializeDateFormatting();
    dateFormat = DateFormat.yMMMMd('tr');
    timeFormat = DateFormat.Hms('tr');
    getData();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<themeProvider>(context, listen: true).theme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: isLoading
                ? const SizedBox()
                : Image.network(
                    '${profImage}',
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? const SizedBox()
                      : RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: '${name}' + " " + '${surname}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: provider == true
                                          ? Colors.black
                                          : Colors.white)),
                              TextSpan(
                                  text: ' ${widget.snap.data()['text']}',
                                  style: TextStyle(
                                      color: provider == true
                                          ? Colors.black
                                          : Colors.white)),
                            ],
                          ),
                        ),
                  Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        style: TextStyle(
                          color: provider == true ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        dateFormat.format(
                          widget.snap['datePublished'].toDate(),
                        ),
                      ))
                ],
              ),
            ),
          ),
          widget.snap['uid'] == FirebaseAuth.instance.currentUser!.uid
              ? Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Iconsax.trash,
                      color: provider == true ? Colors.black : Colors.white,
                    ),
                    onPressed: () {
                      FireStoreMethods().deleteComment(
                          widget.postId, widget.snap['commentId']);
                    },
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
