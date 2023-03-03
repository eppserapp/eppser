import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/providers/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:eppser/models/user.dart';
import 'package:eppser/providers/userProvider.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/utils/utils.dart';
import 'package:eppser/Widgets/commentCard.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class CommentsPage extends StatefulWidget {
  final postId;

  const CommentsPage({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController commentEditingController =
      TextEditingController();
  var provider;

  void postComment(String uid) async {
    try {
      String res = await FireStoreMethods().postComment(
        widget.postId,
        commentEditingController.text,
        uid,
      );

      setState(() {
        commentEditingController.text = "";
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    provider = Provider.of<themeProvider>(context, listen: true).theme;
    return Scaffold(
      backgroundColor: provider == true ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Yorumlar',
        ),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .doc(widget.postId)
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => CommentCard(
              postId: widget.postId,
              snap: snapshot.data!.docs[index],
            ),
          );
        },
      ),
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          color: provider == true ? Colors.white : Colors.black,
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: NetworkImage(user.profImage),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    style: TextStyle(
                      color: provider == true ? Colors.black : Colors.white,
                    ),
                    cursorColor: provider == true ? Colors.black : Colors.white,
                    controller: commentEditingController,
                    decoration: InputDecoration(
                        hintText: 'Yorum Yap',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: provider == true ? Colors.black : Colors.white,
                        )),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  postComment(user.uid);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Icon(
                    Iconsax.send_15,
                    size: 30,
                    color: provider == true ? Colors.black : Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
