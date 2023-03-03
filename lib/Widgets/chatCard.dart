import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/message.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:eppser/providers/themeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class chatCard extends StatefulWidget {
  final snap;
  const chatCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<chatCard> createState() => _chatCardState();
}

class _chatCardState extends State<chatCard> {
  bool isLoading = false;
  String profImage = "";
  String name = "";
  String surname = "";
  late DateFormat dateFormat;
  late DateFormat timeFormat;
  var newMessage;
  var provider;

  isSeen() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.snap['recieverId'] != FirebaseAuth.instance.currentUser!.uid
            ? widget.snap['senderId']
            : widget.snap['recieverId'])
        .collection('Chats')
        .doc(widget.snap['recieverId'] == FirebaseAuth.instance.currentUser!.uid
            ? widget.snap['senderId']
            : widget.snap['recieverId'])
        .collection('Messages')
        .where('isSeen', isEqualTo: false)
        .where('senderId',
            isEqualTo: widget.snap['recieverId'] ==
                    FirebaseAuth.instance.currentUser!.uid
                ? widget.snap['senderId']
                : widget.snap['recieverId'])
        .snapshots()
        .listen((event) {
      setState(() {
        newMessage = event.docs.length;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    dateFormat = DateFormat.yMMMMd('tr');
    timeFormat = DateFormat.Hm('tr');
    getData();
    isSeen();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap =
          widget.snap['senderId'] == FirebaseAuth.instance.currentUser!.uid
              ? await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.snap['recieverId'])
                  .get()
              : await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.snap['senderId'])
                  .get();

      profImage = userSnap['profImage'];
      name = userSnap['name'];
      surname = userSnap['surname'];

      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<themeProvider>(context, listen: true).theme;
    return GestureDetector(
      onLongPress: () {
        showDialog(
          useRootNavigator: false,
          context: context,
          builder: (context) {
            return Dialog(
              child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shrinkWrap: true,
                  children: [
                    'Sil',
                  ]
                      .map(
                        (e) => InkWell(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(e),
                            ),
                            onTap: () async {
                              await FireStoreMethods().deleteChat(
                                  widget.snap['recieverId'],
                                  widget.snap['senderId']);
                              // ignore: use_build_context_synchronously
                              showSnackBar(
                                context,
                                'Sohbet Silindi!',
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(50 * 0.4)),
              child: isLoading
                  ? const SizedBox()
                  : SizedBox(
                      height: 50,
                      width: 50,
                      child: CachedNetworkImage(
                        placeholderFadeInDuration:
                            const Duration(microseconds: 1),
                        fadeOutDuration: const Duration(microseconds: 1),
                        fadeInDuration: const Duration(milliseconds: 1),
                        imageUrl: profImage,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Icon(
                          Icons.error,
                          color: provider == true ? Colors.black : Colors.white,
                        ),
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
                          builder: (context) => messagePage(
                                snap: widget.snap,
                              ))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${name}" + " " + "${surname}",
                        style: TextStyle(
                            fontSize: 20,
                            color:
                                provider == true ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3, left: 3),
                        child: Text(
                          widget.snap['lastMessage'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                provider == true ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  dateFormat.format(widget.snap['timeSent'].toDate()) ==
                          dateFormat.format(DateTime.now())
                      ? timeFormat.format(widget.snap['timeSent'].toDate())
                      : dateFormat.format(widget.snap['timeSent'].toDate()),
                  style: TextStyle(
                      color: provider == true ? Colors.black : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                newMessage != null && newMessage != 0
                    ? Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(0, 86, 255, 1),
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                          child: Text(
                            newMessage.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ))
                    : const SizedBox()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
