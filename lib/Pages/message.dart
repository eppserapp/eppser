import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/profile.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:eppser/Widgets/MyMessageCard.dart';
import 'package:eppser/Widgets/sendMessageCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iconsax/iconsax.dart';

class messagePage extends StatefulWidget {
  final snap;
  const messagePage({super.key, this.snap});

  @override
  State<messagePage> createState() => _messagePageState();
}

class _messagePageState extends State<messagePage> {
  bool isLoading = false;
  final TextEditingController _text = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  var profImage;
  var name;
  var surname;
  var uid;

  @override
  void initState() {
    getData();
    isSeen();
    super.initState();
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
      uid = userSnap['uid'];

      setState(() {});
    } catch (e) {
      print(e.toString());
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  isSeen() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.snap['recieverId'] == FirebaseAuth.instance.currentUser!.uid
            ? widget.snap['senderId']
            : widget.snap['recieverId'])
        .collection('Chats')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Messages')
        .where('isSeen', isEqualTo: false)
        .where('senderId',
            isEqualTo: widget.snap['recieverId'] ==
                    FirebaseAuth.instance.currentUser!.uid
                ? widget.snap['senderId']
                : widget.snap['recieverId'])
        .get()
        .then((value) => value.docs.forEach((element) {
              element.reference.update({'isSeen': true});
            }));
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
        .get()
        .then((value) => value.docs.forEach((element) {
              element.reference.update({'isSeen': true});
            }));
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          )
        : SafeArea(
            child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover)),
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  toolbarHeight: 50,
                  centerTitle: false,
                  backgroundColor: Colors.black,
                  automaticallyImplyLeading: false,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 24,
                          )),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => profilePage(uid: uid)));
                        },
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(45 * 0.4)),
                          child: isLoading
                              ? const SizedBox()
                              : Image.network(
                                  profImage,
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.cover,
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
                                  builder: (context) => profilePage(
                                        uid: uid,
                                      ))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isLoading
                                  ? const SizedBox()
                                  : Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                              isLoading
                                  ? const SizedBox()
                                  : Text(
                                      surname,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
                body: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('Chats')
                      .doc(widget.snap['senderId'] !=
                              FirebaseAuth.instance.currentUser!.uid
                          ? widget.snap['senderId']
                          : widget.snap['recieverId'])
                      .collection('Messages')
                      .orderBy('date', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    try {
                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Icon(
                            Iconsax.message,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      }
                    } catch (e) {
                      print(e);
                    }

                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.positions.isNotEmpty) {
                        _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut);
                      }
                    });
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    return ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          isSeen();
                          return snapshot.data!.docs[index]
                                      .data()['recieverId'] ==
                                  FirebaseAuth.instance.currentUser!.uid
                              ? sendMessageCard(
                                  snap: snapshot.data!.docs[index].data(),
                                  date:
                                      snapshot.data!.docs[index].data()['date'],
                                  message:
                                      snapshot.data!.docs[index].data()['text'])
                              : MyMessageCard(
                                  snap: snapshot.data!.docs[index].data(),
                                  message:
                                      snapshot.data!.docs[index].data()['text'],
                                  date:
                                      snapshot.data!.docs[index].data()['date'],
                                  isSeen: snapshot.data!.docs[index]
                                      .data()['isSeen']);
                        });
                  },
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(18))),
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0, right: 8),
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                controller: _text,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  focusColor: Colors.white,
                                  hintText: 'Mesaj yaz',
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (_text.text.isNotEmpty) {
                                FireStoreMethods().sendMessage(
                                    _text.text.trim(),
                                    widget.snap['recieverId'] ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid
                                        ? widget.snap['senderId']
                                        : widget.snap['recieverId'],
                                    FirebaseAuth.instance.currentUser!.uid);
                                _text.clear();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 18),
                              child: const Icon(
                                Iconsax.send_15,
                                size: 30,
                                color: Color.fromRGBO(0, 86, 255, 1),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ));
  }
}
