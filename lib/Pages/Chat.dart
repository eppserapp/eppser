import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:eppser/Database/Message.dart';
import 'package:eppser/Database/Users.dart';
import 'package:eppser/Pages/Profile.dart';
import 'package:eppser/Providers/themeProvider.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Theme/Theme.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:eppser/Widgets/focused_menu/focused_menu.dart';
import 'package:eppser/Widgets/focused_menu/modals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' as foundation;

class Chat extends StatefulWidget {
  const Chat({
    super.key,
    this.snap,
  });
  final snap;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  var userData;
  var message = {};
  late final List<StreamSubscription> _subscriptions = [];
  bool? isConnected;
  bool _hasExecuted = false;
  bool isLoading = false;
  bool emojiShowing = false;
  FocusNode focusNode = FocusNode();
  bool seen = false;
  late BannerAd _bannerAd;

  _onBackspacePressed() {
    _textEditingController
      ..text = _textEditingController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _textEditingController.text.length));
  }

  void _toggleEmojiKeyboard() {
    setState(() {
      emojiShowing = !emojiShowing;
      if (emojiShowing) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-7628048353165760/7149368254',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    );

    _bannerAd.load();
    focusNode.addListener(() {
      if (focusNode.hasFocus && emojiShowing) {
        // Klavye açıkken ve emoji gösteriliyorsa emoji'leri gizle
        setState(() {
          emojiShowing = false;
        });
      }
    });
    fetchAndSaveMessages();
    fetchAndSaveUserData();
    if (UserBox.getUserData(widget.snap) == null ||
        MessageBox.getMessage(widget.snap) == null) {
      getData();
    } else {
      userData = UserBox.getUserData(widget.snap);
      message = MessageBox.getMessage(widget.snap);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasExecuted && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        _hasExecuted = true;
      }
    });
    isSeen();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _scrollController.dispose();
    _textEditingController.dispose();
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.snap)
          .get();

      userData = userSnap.data();

      setState(() {});
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  void fetchAndSaveUserData() {
    final userChatsSubscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Chats')
        .snapshots()
        .listen((chatsSnapshot) {
      for (var chatDoc in chatsSnapshot.docs) {
        final chatPartnerId = chatDoc.id;
        // Listen to changes for each chat partner's document.
        final partnerSubscription = FirebaseFirestore.instance
            .collection('Users')
            .doc(chatPartnerId)
            .snapshots()
            .listen((partnerDoc) {
          if (partnerDoc.exists) {
            UserBox.saveUserData(chatPartnerId, partnerDoc.data());
          }
        });
        _subscriptions.add(partnerSubscription);
      }
    });
    _subscriptions.add(userChatsSubscription);
  }

  void fetchAndSaveMessages() {
    final messagesChatsSubscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Chats')
        .snapshots()
        .listen((chatsSnapshot) {
      for (var chatDoc in chatsSnapshot.docs) {
        final chatPartnerId = chatDoc.id;
        final messagesSubscription = FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Chats')
            .doc(chatPartnerId)
            .collection('Messages')
            .orderBy('date', descending: false)
            .snapshots()
            .listen((messagesSnapshot) async {
          List existingMessages =
              List.from(MessageBox.getMessage(chatPartnerId)?.values ?? []);

          for (var msgDoc in messagesSnapshot.docs) {
            final messageData = msgDoc.data();
            var senderId = messageData['senderId'];

            int indexToRemove = existingMessages.indexWhere((existingMessage) =>
                existingMessage['messageId'] == msgDoc.id &&
                existingMessage['sending'] == true);
            if (indexToRemove != -1) {
              existingMessages.removeAt(indexToRemove);
            } else if (existingMessages.any((existingMessage) =>
                existingMessage['messageId'] == msgDoc.id)) {
              continue;
            }

            existingMessages.add({
              'messageId': msgDoc.id,
              'senderId': senderId,
              'receiverId': messageData['receiverId'],
              'text': messageData['text'],
              'file_urls': messageData['file_urls'],
              'date': (messageData['date'] as Timestamp).toDate(),
              'isSeen': messageData['isSeen'],
              'sending': false
            });
          }

          var newMessagesMap = {
            for (var i = 0; i < existingMessages.length; i++)
              i: existingMessages[i],
          };

          await MessageBox.saveMessageData(chatPartnerId, newMessagesMap);
        });
        _subscriptions.add(messagesSubscription);
      }
    });
    _subscriptions.add(messagesChatsSubscription);
  }

  String getTimeAgo(DateTime dateTime) {
    DateTime localDateTime = dateTime.toLocal();
    DateTime now = DateTime.now().toLocal();

    if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day) {
      return "Bugün";
    } else if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day - 1) {
      return "Dün";
    } else {
      return DateFormat.yMMMMd("Tr_tr").format(localDateTime);
    }
  }

  isSeen() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.snap)
        .collection('Chats')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Messages')
        .where('isSeen', isEqualTo: false)
        .where('senderId', isEqualTo: widget.snap)
        .get()
        .then((value) => value.docs.forEach((element) {
              element.reference.update({'isSeen': true});
            }));
  }

  myisSeen() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Chats')
        .doc(widget.snap)
        .collection('Messages')
        .where('isSeen', isEqualTo: false)
        .where('senderId', isEqualTo: widget.snap)
        .get()
        .then((value) => value.docs.forEach((element) {
              element.reference.update({'isSeen': true});
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(0, 86, 255, 1),
                ),
              )
            : Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                    toolbarHeight: 70,
                    scrolledUnderElevation: 0,
                    backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor,
                    automaticallyImplyLeading: false,
                    titleSpacing: -10,
                    title: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: IconButton(
                                  icon: Icon(
                                    Iconsax.arrow_left_2,
                                    color: Theme.of(context).iconTheme.color,
                                    size: 32,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 10),
                                child: userData['profImage'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: CachedNetworkImage(
                                            filterQuality: FilterQuality.low,
                                            placeholderFadeInDuration:
                                                const Duration(microseconds: 1),
                                            fadeOutDuration:
                                                const Duration(microseconds: 1),
                                            fadeInDuration:
                                                const Duration(milliseconds: 1),
                                            imageUrl: userData['profImage'],
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error,
                                                        color: Colors.black),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                0, 86, 255, 1),
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: const Icon(
                                          Iconsax.user,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Profile(uid: userData['uid']),
                              )),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                  userData['name'] + " " + userData['surname'],
                                  maxLines: 1,
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              // const Text(
                              //   'Çevrimiçi',
                              //   style: TextStyle(
                              //       color: Colors.green, fontSize: 12),
                              // )
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      InkWell(
                        child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Iconsax.call,
                              color: Theme.of(context).iconTheme.color,
                              size: 24,
                            )),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Iconsax.video,
                            color: Theme.of(context).iconTheme.color,
                            size: 26,
                          )),
                      FocusedMenuHolder(
                        child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Iconsax.more,
                              color: Theme.of(context).iconTheme.color,
                              size: 28,
                            )),
                        menuWidth: MediaQuery.of(context).size.width * 0.55,
                        blurSize: 0.0,
                        menuItemExtent: 45,
                        menuBoxDecoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        duration: Duration(milliseconds: 100),
                        animateMenuItems: true,
                        blurBackgroundColor: Colors.white.withOpacity(0.0),
                        bottomOffsetHeight: 100,
                        openWithTap: true,
                        menuItems: <FocusedMenuItem>[
                          FocusedMenuItem(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              title: Text("Bul"),
                              trailingIcon: Icon(
                                Iconsax.search_normal_1,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onPressed: () {}),
                          FocusedMenuItem(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              title: Text("Duvar Kağıdını Değiştir"),
                              trailingIcon: Icon(
                                Iconsax.gallery,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onPressed: () {}),
                          FocusedMenuItem(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              title: Text("Sohbeti Temizle"),
                              trailingIcon: Icon(
                                Iconsax.eraser_1,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onPressed: () {}),
                          FocusedMenuItem(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              title: Text(
                                "Sohbeti Sil",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              trailingIcon: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      title: Text(
                                        "Sohbeti Sil",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color),
                                      ),
                                      contentTextStyle: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color),
                                      content: const Text(
                                          "Bu sohbeti silmek istediğinize emin misiniz?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Hayır",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            () async {
                                              try {
                                                String currentUserId =
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid;
                                                String chatPartnerId =
                                                    userData['uid'];
                                                // Delete all messages in the conversation
                                                final messagesSnapshot =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('Users')
                                                        .doc(currentUserId)
                                                        .collection('Chats')
                                                        .doc(chatPartnerId)
                                                        .collection('Messages')
                                                        .get();
                                                final batch = FirebaseFirestore
                                                    .instance
                                                    .batch();
                                                for (var doc
                                                    in messagesSnapshot.docs) {
                                                  batch.delete(doc.reference);
                                                }
                                                await batch.commit();

                                                // Delete the chat document (conversation metadata)
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(currentUserId)
                                                    .collection('Chats')
                                                    .doc(chatPartnerId)
                                                    .delete();

                                                // Delete the chat from the local MessageBox.
                                                await MessageBox.deleteMessage(
                                                    chatPartnerId);

                                                showSnackBar(
                                                    context, 'Sohbet Silindi!');
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              } catch (e) {
                                                print(e.toString());
                                                Navigator.pop(context);
                                              }
                                            }();
                                          },
                                          child: const Text("Evet",
                                              style: TextStyle(
                                                  color: Colors.redAccent)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
                        ],
                        onPressed: () {},
                      ),
                    ],
                    bottom: isConnected == false
                        ? PreferredSize(
                            preferredSize: const Size(double.infinity, 30),
                            child: Container(
                              width: double.infinity,
                              height: 30,
                              color: Colors.red,
                              child: const Center(
                                child: Text(
                                  'İnternet bağlantısı yok',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : const PreferredSize(
                            preferredSize: Size(0, 0),
                            child: SizedBox(),
                          )),
                body: ValueListenableBuilder(
                  valueListenable: Hive.box('messageBox').listenable(),
                  builder: (context, value, child) {
                    if (MessageBox.getMessage(widget.snap) != null) {
                      message = MessageBox.getMessage(userData['uid']);
                    }

                    if (_scrollController.hasClients) {
                      if (_scrollController.position.maxScrollExtent == 0) {
                        if (message.values
                            .any((element) => element['isSeen'] == false)) {
                          isSeen();
                          myisSeen();
                        }
                      }
                      _scrollController.position.addListener(() {
                        if (_scrollController.position.pixels >=
                            _scrollController.position.maxScrollExtent - 200) {
                          if (mounted) {
                            if (message.values
                                .any((element) => element['isSeen'] == false)) {
                              isSeen();
                              myisSeen();
                            }
                          }
                        }
                      });
                    }

                    bool i = false;
                    message.forEach((key, value) {
                      if (value['isSeen'] == false &&
                          value['senderId'] !=
                              FirebaseAuth.instance.currentUser?.uid &&
                          !i) {
                        seen = true;
                        i = true;
                      }
                    });

                    if (mounted) {
                      if (_scrollController.hasClients) {
                        if (_scrollController.position.maxScrollExtent == 0) {
                          if (message.values
                              .any((element) => element['isSeen'] == false)) {
                            Future.delayed(const Duration(seconds: 5), () {
                              setState(() {
                                seen = false;
                              });
                            });
                          }
                        }
                        _scrollController.position.addListener(() {
                          if (_scrollController.position.pixels >=
                              _scrollController.position.maxScrollExtent -
                                  200) {
                            if (message.values
                                .any((element) => element['isSeen'] == false)) {
                              Future.delayed(const Duration(seconds: 5), () {
                                setState(() {
                                  seen = false;
                                });
                              });
                            }
                          }
                        });
                      }
                    }

                    if (mounted && _scrollController.hasClients) {
                      if (_scrollController.position.pixels >=
                          _scrollController.position.maxScrollExtent - 200) {
                        Future.delayed(const Duration(milliseconds: 50), () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            curve: Curves.easeInOut,
                            duration: Duration(milliseconds: 200),
                          );
                        });
                      }
                    }

                    return Stack(
                      children: [
                        ListView.builder(
                          itemCount: message.length,
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                if (index == 0 ||
                                    ((message[index]['date'] is Timestamp
                                            ? DateFormat.yMMMMd('tr_TR').format(
                                                (message[index]['date'] as Timestamp)
                                                    .toDate())
                                            : DateFormat.yMMMMd('tr_TR').format(
                                                message[index]['date'])) !=
                                        (message[(index - 1)]['date'] is Timestamp
                                            ? DateFormat.yMMMMd('tr_TR').format(
                                                (message[(index - 1)]['date']
                                                        as Timestamp)
                                                    .toDate())
                                            : DateFormat.yMMMMd('tr_TR').format(
                                                message[(index - 1)]['date']))))
                                  Center(
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(minWidth: 80),
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      height: 25,
                                      child: Text(
                                        message[index]['date'] is Timestamp
                                            ? getTimeAgo(
                                                message[index]['date'].toDate())
                                            : getTimeAgo(
                                                message[index]['date']),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                if (index - 1 > 0)
                                  if (message[(index - 1)]['senderId'] !=
                                      message[index]['senderId'])
                                    const SizedBox(
                                      height: 10,
                                    ),
                                if (message[index] != null)
                                  if (message[index]['senderId'] ==
                                      FirebaseAuth.instance.currentUser!.uid)
                                    FocusedMenuHolder(
                                      menuWidth:
                                          MediaQuery.of(context).size.width *
                                              0.50,
                                      blurSize: 3.0,
                                      menuItemExtent: 45,
                                      menuBoxDecoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0))),
                                      duration: Duration(milliseconds: 100),
                                      animateMenuItems: true,
                                      blurBackgroundColor:
                                          Colors.white.withOpacity(0.1),
                                      openWithTap: false,
                                      menuItems: <FocusedMenuItem>[
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text("Düzenle"),
                                            trailingIcon: Icon(Iconsax.brush_4),
                                            onPressed: () {}),
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text("Yönlendir"),
                                            trailingIcon:
                                                Icon(Iconsax.forward_square),
                                            onPressed: () {}),
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text("Kopyala"),
                                            trailingIcon: Icon(Iconsax.copy),
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: message[index]
                                                      ['text']));
                                              showSnackBar(
                                                  context, 'Mesaj kopyalandı!');
                                            }),
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text("Seç"),
                                            trailingIcon:
                                                Icon(Iconsax.tick_circle),
                                            onPressed: () {}),
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text("Bilgi"),
                                            trailingIcon:
                                                Icon(Iconsax.info_circle),
                                            onPressed: () {}),
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text(
                                              "Sil",
                                              style: TextStyle(
                                                  color: Colors.redAccent),
                                            ),
                                            trailingIcon: Icon(
                                              Iconsax.trash,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () {
                                              () async {
                                                try {
                                                  // Mesaj ID'sini al
                                                  String messageId =
                                                      message[index]
                                                          ['messageId'];

                                                  // Firebase'den mesajı sil
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Users')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                      .collection('Chats')
                                                      .doc(widget.snap)
                                                      .collection('Messages')
                                                      .doc(messageId)
                                                      .delete();

                                                  // Check if the Messages collection is empty
                                                  final messagesCollection =
                                                      FirebaseFirestore.instance
                                                          .collection('Users')
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .collection('Chats')
                                                          .doc(widget.snap)
                                                          .collection(
                                                              'Messages');
                                                  final remainingMessages =
                                                      await messagesCollection
                                                          .get();

                                                  if (remainingMessages
                                                      .docs.isEmpty) {
                                                    // Delete the entire chat document if no messages remain
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('Users')
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid)
                                                        .collection('Chats')
                                                        .doc(widget.snap)
                                                        .delete();
                                                  }

                                                  // Local messageBox'tan mesajı sil
                                                  final messagesMap =
                                                      MessageBox.getMessage(
                                                          widget.snap);
                                                  if (messagesMap != null) {
                                                    messagesMap.removeWhere(
                                                        (key, value) =>
                                                            value[
                                                                'messageId'] ==
                                                            messageId);
                                                    if (messagesMap.isEmpty) {
                                                      await MessageBox
                                                          .deleteMessage(
                                                              widget.snap);

                                                      await UserBox.deleteUser(
                                                          widget.snap);
                                                    } else {
                                                      await MessageBox
                                                          .saveMessageData(
                                                              widget.snap,
                                                              messagesMap);
                                                    }
                                                  }

                                                  showSnackBar(context,
                                                      'Mesaj silindi.');
                                                } catch (e) {
                                                  showSnackBar(context,
                                                      'Mesaj silinirken hata oluştu.');
                                                }
                                              }();
                                            }),
                                      ],
                                      onPressed: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2, right: 10),
                                        child: ChatBubble(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          shadowColor: Colors.transparent,
                                          clipper: ChatBubbleClipper5(
                                              type: BubbleType.sendBubble),
                                          backGroundColor: Colors.black,
                                          alignment: Alignment.topRight,
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  message[index]['text'],
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      DateFormat.Hm('tr_TR')
                                                          .format((message[
                                                                          index]
                                                                      ['date']
                                                                  is Timestamp
                                                              ? message[index]
                                                                      ['date']
                                                                  .toDate()
                                                              : message[index]
                                                                  ['date'])),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    message[index]['isSeen'] &&
                                                            message[index][
                                                                    'sending'] ==
                                                                false
                                                        ? const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 3),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Iconsax
                                                                      .tick_circle,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          0,
                                                                          86,
                                                                          255,
                                                                          1),
                                                                  size: 10,
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              3,
                                                                          left:
                                                                              1),
                                                                  child: Icon(
                                                                    Iconsax
                                                                        .tick_circle,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            0,
                                                                            86,
                                                                            255,
                                                                            1),
                                                                    size: 10,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        : message[index][
                                                                    'sending'] ==
                                                                true
                                                            ? const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            5),
                                                                child: Icon(
                                                                  Iconsax.clock,
                                                                  color: Colors
                                                                      .grey,
                                                                  size: 12,
                                                                ),
                                                              )
                                                            : const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            3),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Iconsax
                                                                          .tick_circle,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 10,
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          right:
                                                                              3,
                                                                          left:
                                                                              1),
                                                                      child:
                                                                          Icon(
                                                                        Iconsax
                                                                            .tick_circle,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            10,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                if (message[index] != null)
                                  if (message[index]['receiverId'] ==
                                      FirebaseAuth.instance.currentUser!.uid)
                                    FocusedMenuHolder(
                                      menuWidth:
                                          MediaQuery.of(context).size.width *
                                              0.50,
                                      blurSize: 3.0,
                                      menuItemExtent: 45,
                                      menuBoxDecoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0))),
                                      duration: Duration(milliseconds: 100),
                                      animateMenuItems: true,
                                      blurBackgroundColor:
                                          Colors.white.withOpacity(0.1),
                                      openWithTap: false,
                                      menuItems: <FocusedMenuItem>[
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text("Düzenle"),
                                            trailingIcon: Icon(Iconsax.brush_4),
                                            onPressed: () {}),
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text("Yönlendir"),
                                            trailingIcon:
                                                Icon(Iconsax.forward_square),
                                            onPressed: () {}),
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text("Kopyala"),
                                            trailingIcon: Icon(Iconsax.copy),
                                            onPressed: () {}),
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text("Seç"),
                                            trailingIcon:
                                                Icon(Iconsax.tick_circle),
                                            onPressed: () {}),
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text("Bilgi"),
                                            trailingIcon:
                                                Icon(Iconsax.info_circle),
                                            onPressed: () {}),
                                        FocusedMenuItem(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text(
                                              "Sil",
                                              style: TextStyle(
                                                  color: Colors.redAccent),
                                            ),
                                            trailingIcon: Icon(
                                              Iconsax.trash,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () {
                                              () async {
                                                try {
                                                  // Mesaj ID'sini al
                                                  String messageId =
                                                      message[index]
                                                          ['messageId'];

                                                  // Firebase'den mesajı sil
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Users')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                      .collection('Chats')
                                                      .doc(widget.snap)
                                                      .collection('Messages')
                                                      .doc(messageId)
                                                      .delete();

                                                  // Local messageBox'tan mesajı sil
                                                  final messagesMap =
                                                      MessageBox.getMessage(
                                                          widget.snap);
                                                  if (messagesMap != null) {
                                                    messagesMap.removeWhere(
                                                        (key, value) =>
                                                            value[
                                                                'messageId'] ==
                                                            messageId);
                                                    await MessageBox
                                                        .saveMessageData(
                                                            widget.snap,
                                                            messagesMap);
                                                  }

                                                  showSnackBar(context,
                                                      'Mesaj silindi.');
                                                } catch (e) {
                                                  showSnackBar(context,
                                                      'Mesaj silinirken hata oluştu.');
                                                }
                                              }();
                                            }),
                                      ],
                                      onPressed: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2, left: 10),
                                        child: ChatBubble(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          clipper: ChatBubbleClipper5(
                                              type: BubbleType.receiverBubble),
                                          backGroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          child: Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  message[index]['text'],
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16),
                                                ),
                                                Text(
                                                  DateFormat.Hm('tr_TR').format(
                                                      message[index]['date']),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                bottomNavigationBar: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(18))),
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 300.0,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _toggleEmojiKeyboard();
                                  },
                                  icon: const Icon(
                                    Iconsax.emoji_happy,
                                    size: 32,
                                  )),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 8),
                                  child: TextField(
                                    focusNode: focusNode,
                                    style: TextStyle(
                                      color: Provider.of<ThemeProvider>(context)
                                                  .themeData ==
                                              lightMode
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    controller: _textEditingController,
                                    maxLines: null,
                                    contextMenuBuilder: (BuildContext context,
                                        EditableTextState editableTextState) {
                                      return AdaptiveTextSelectionToolbar(
                                        anchors: editableTextState
                                            .contextMenuAnchors,
                                        children: [
                                          TextSelectionToolbarTextButton(
                                            padding: const EdgeInsets.all(8.0),
                                            onPressed: () {
                                              editableTextState.copySelection(
                                                  SelectionChangedCause
                                                      .toolbar);
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Kopyala"),
                                          ),
                                          TextSelectionToolbarTextButton(
                                            padding: const EdgeInsets.all(8.0),
                                            onPressed: () {
                                              editableTextState.cutSelection(
                                                  SelectionChangedCause
                                                      .toolbar);
                                            },
                                            child: const Text("Kes"),
                                          ),
                                          TextSelectionToolbarTextButton(
                                            padding: const EdgeInsets.all(8.0),
                                            onPressed: () {
                                              editableTextState.pasteText(
                                                  SelectionChangedCause
                                                      .toolbar);
                                            },
                                            child: const Text("Yapıştır"),
                                          ),
                                          TextSelectionToolbarTextButton(
                                            padding: const EdgeInsets.all(8.0),
                                            onPressed: () {
                                              editableTextState.selectAll(
                                                  SelectionChangedCause
                                                      .toolbar);
                                            },
                                            child: const Text("Tümünü Seç"),
                                          ),
                                        ],
                                      );
                                    },
                                    decoration: InputDecoration(
                                      focusColor:
                                          Theme.of(context).iconTheme.color,
                                      hintText: 'Mesaj yaz...',
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 18),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  DateTime date = DateTime.now();
                                  String messageId = Uuid().v1();
                                  if (_textEditingController.text.isNotEmpty) {
                                    if (mounted) {
                                      if (_scrollController.position.pixels >=
                                          _scrollController
                                                  .position.maxScrollExtent -
                                              200) {
                                        // Eğer son 300 pikseldeyse scrool işlemini gerçekleştir
                                        if (mounted) {
                                          Future.delayed(
                                              Duration(milliseconds: 50), () {
                                            _scrollController.animateTo(
                                              _scrollController
                                                  .position.maxScrollExtent,
                                              curve: Curves.easeInOut,
                                              duration:
                                                  Duration(milliseconds: 200),
                                            );
                                          });
                                        }
                                      }
                                    }

                                    // Önce mevcut mesajları kopyalayın
                                    var existingMessages =
                                        List.from(message.values);

                                    existingMessages.add({
                                      'text':
                                          _textEditingController.text.trim(),
                                      'date': date,
                                      'isSeen': false,
                                      'receiverId': userData['uid'],
                                      'senderId': FirebaseAuth
                                          .instance.currentUser!.uid,
                                      'messageId': messageId,
                                      "sending": true,
                                    });
                                    var newMessage = {
                                      for (var i = 0;
                                          i < existingMessages.length;
                                          i++)
                                        i: existingMessages[i],
                                    };
                                    MessageBox.saveMessageData(
                                        userData['uid'], newMessage);
                                    FireStoreMethods().sendMessage(
                                      _textEditingController.text.trim(),
                                      userData['uid'],
                                      FirebaseAuth.instance.currentUser!.uid,
                                      date,
                                      messageId,
                                    );

                                    _textEditingController.clear();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 12, right: 10),
                                  child: const Icon(
                                    Iconsax.send_1,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: !emojiShowing,
                      child: SizedBox(
                        height: 350,
                        child: EmojiPicker(
                          textEditingController: _textEditingController,
                          onBackspacePressed: _onBackspacePressed,
                          config: Config(
                            height: 256,
                            checkPlatformCompatibility: true,
                            emojiViewConfig: EmojiViewConfig(
                              // Issue: https://github.com/flutter/flutter/issues/28894
                              emojiSizeMax: 28 *
                                  (foundation.defaultTargetPlatform ==
                                          TargetPlatform.iOS
                                      ? 1.20
                                      : 1.0),
                            ),
                            viewOrderConfig: const ViewOrderConfig(
                              top: EmojiPickerItem.categoryBar,
                              middle: EmojiPickerItem.emojiView,
                              bottom: EmojiPickerItem.searchBar,
                            ),
                            skinToneConfig: const SkinToneConfig(),
                            categoryViewConfig: const CategoryViewConfig(),
                            bottomActionBarConfig:
                                const BottomActionBarConfig(),
                            searchViewConfig: const SearchViewConfig(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
