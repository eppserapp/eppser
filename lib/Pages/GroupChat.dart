import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:eppser/Database/Groups.dart';
import 'package:eppser/Database/GroupsMessage.dart';
import 'package:eppser/Pages/FullScreenView.dart';
import 'package:eppser/Pages/GroupView.dart';
import 'package:eppser/Pages/SendImagesGroup.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupChat extends StatefulWidget {
  final snap;
  const GroupChat({super.key, this.snap});

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  TextEditingController _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  var userData;
  var groupData;
  var message = {};
  StreamSubscription? subscription;
  bool? isConnected;
  bool _hasExecuted = false;
  bool isLoading = false;
  bool emojiShowing = false;
  FocusNode focusNode = FocusNode();
  late BannerAd _bannerAd;

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

    getData();

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
    _scrollController.dispose();
    _textEditingController.dispose();
    subscription?.cancel();
    super.dispose();
  }

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

  // Firebase'den mesajları dinleyen ve güncelleyen fonksiyon
  void listenGroupMessages() {
    subscription?.cancel();
    subscription = FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.snap)
        .collection('Messages')
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      Map<String, dynamic> updatedMessages = {};
      int index = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data();
        // Firestore'dan gelen Timestamp'i DateTime'a çevir
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate();
        }
        updatedMessages[index.toString()] = data;
        index++;
      }
      GroupMessageBox.saveGroupMessage(widget.snap, updatedMessages);
      setState(() {
        message = updatedMessages;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    listenGroupMessages();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var Snap = await FirebaseFirestore.instance
          .collection('Groups')
          .doc(widget.snap)
          .get();

      groupData = Snap.data();
      GroupBox.saveGroupData(widget.snap, groupData);
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
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

  String getTimeAgo(DateTime dateTime) {
    DateTime localDateTime = dateTime.toLocal();
    DateTime now = DateTime.now().toLocal();

    if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day) {
      // Bugünse sadece saat olarak göster
      return "Bugün";
    } else if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day - 1) {
      // Dünse "Dün" olarak göster
      return "Dün";
    } else {
      // Diğer durumlar için tarih formatını kullan
      return DateFormat.yMMMMd("Tr_tr").format(localDateTime);
    }
  }

  isSeen() async {
    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.snap)
        .collection('Messages')
        .where('isSeen', isNotEqualTo: [FirebaseAuth.instance.currentUser!.uid])
        .get()
        .then((value) => value.docs.forEach((element) {
              element.reference.update({
                'isSeen': FieldValue.arrayUnion(
                    [FirebaseAuth.instance.currentUser!.uid])
              });
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
                scrolledUnderElevation: 0,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                automaticallyImplyLeading: false,
                leadingWidth: 90,
                leading: Row(
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
                          groupData['photoUrl'] != null
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 40),
                                  child: ClipRRect(
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
                                        imageUrl: groupData['photoUrl'],
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error,
                                                color: Colors.black),
                                      ),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 40),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        color:
                                            const Color.fromRGBO(0, 86, 255, 1),
                                        borderRadius:
                                            BorderRadius.circular(40 * 0.4)),
                                    child: const Icon(
                                      Iconsax.people,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupView(
                              snap: groupData,
                            ),
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Iconsax.more,
                        color: Theme.of(context).iconTheme.color,
                        size: 30,
                      ),
                    ),
                  ),
                ],
                titleSpacing: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      groupData['name'],
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              body: ValueListenableBuilder(
                valueListenable: Hive.box('groupMessageBox').listenable(),
                builder: (context, value, child) {
                  if (GroupMessageBox.getGroupMessage(widget.snap) != null) {
                    message =
                        GroupMessageBox.getGroupMessage(groupData['groupId']);
                  }
                  if (_scrollController.hasClients) {
                    _scrollController.position.addListener(() {
                      if (_scrollController.position.pixels >=
                          _scrollController.position.maxScrollExtent - 200) {
                        if (mounted) {
                          if (message.values.any((element) =>
                              !(element['isSeen'] as List).contains(
                                  FirebaseAuth.instance.currentUser!.uid))) {
                            isSeen();
                          }
                        }
                      }
                    });
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
                                  DateFormat.yMMMMd('tr_TR').format(
                                          message[index.toString()]['date']) !=
                                      DateFormat.yMMMMd('tr_TR').format(
                                          message[(index - 1).toString()]
                                              ['date']))
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
                                      getTimeAgo(
                                          message[index.toString()]['date']),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              if (message[index.toString()] != null)
                                if (message[index.toString()]['senderId'] ==
                                    FirebaseAuth.instance.currentUser!.uid)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 7, right: 7),
                                    child: ChatBubble(
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
                                            if (message[index.toString()]
                                                    ['imageUrl'] !=
                                                null)
                                              GridView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        message[index.toString()]
                                                                            [
                                                                            'imageUrl']
                                                                        .length %
                                                                    2 ==
                                                                0
                                                            ? 2
                                                            : 1,
                                                    mainAxisSpacing: 5,
                                                    crossAxisSpacing: 5),
                                                itemCount:
                                                    message[index.toString()]
                                                            ['imageUrl']
                                                        .length,
                                                itemBuilder: (context, index2) {
                                                  return message[
                                                              index.toString()]
                                                          ['sending']
                                                      ? Stack(
                                                          fit: StackFit.expand,
                                                          children: [
                                                            Image.memory(
                                                              message[index
                                                                          .toString()]
                                                                      [
                                                                      'imageUrl']
                                                                  [index2],
                                                              fit: BoxFit.cover,
                                                            ),
                                                            const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                                backgroundColor:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : InkWell(
                                                          onTap: () =>
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            FullScreenView(
                                                                      ispath:
                                                                          false,
                                                                      snap: message[index.toString()]
                                                                              [
                                                                              'imageUrl']
                                                                          [
                                                                          index2],
                                                                    ),
                                                                  )),
                                                          child: Hero(
                                                            tag: message[index
                                                                        .toString()]
                                                                    ['imageUrl']
                                                                [index2],
                                                            child:
                                                                CachedNetworkImage(
                                                              filterQuality:
                                                                  FilterQuality
                                                                      .low,
                                                              placeholderFadeInDuration:
                                                                  const Duration(
                                                                      microseconds:
                                                                          1),
                                                              fadeOutDuration:
                                                                  const Duration(
                                                                      microseconds:
                                                                          1),
                                                              fadeInDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1),
                                                              imageUrl: message[
                                                                          index
                                                                              .toString()]
                                                                      [
                                                                      'imageUrl']
                                                                  [index2],
                                                              fit: BoxFit.cover,
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(
                                                                      Icons
                                                                          .error,
                                                                      color: Colors
                                                                          .black),
                                                            ),
                                                          ),
                                                        );
                                                },
                                              ),
                                            Text(
                                              message[index.toString()]['text'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  DateFormat.Hm('tr_TR').format(
                                                      message[index.toString()]
                                                          ['date']),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                message[index.toString()]
                                                            ['sending'] ==
                                                        true
                                                    ? const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5),
                                                        child: Icon(
                                                          Iconsax.clock,
                                                          color: Colors.grey,
                                                          size: 12,
                                                        ),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 3),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Iconsax.eye,
                                                              color:
                                                                  Colors.white,
                                                              size: 12,
                                                            ),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              message[index
                                                                          .toString()]
                                                                      ['isSeen']
                                                                  .length
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 10),
                                                            )
                                                          ],
                                                        ))
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              if (message[index.toString()] != null)
                                if (message[index.toString()]['senderId'] !=
                                    FirebaseAuth.instance.currentUser!.uid)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 7, left: 7),
                                    child: ChatBubble(
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
                                            if (message[index.toString()]
                                                    ['imageUrl'] !=
                                                null)
                                              GridView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        message[index.toString()]
                                                                            [
                                                                            'imageUrl']
                                                                        .length %
                                                                    2 ==
                                                                0
                                                            ? 2
                                                            : 1,
                                                    mainAxisSpacing: 5,
                                                    crossAxisSpacing: 5),
                                                itemCount:
                                                    message[index.toString()]
                                                            ['imageUrl']
                                                        .length,
                                                itemBuilder: (context, index2) {
                                                  return message[
                                                              index.toString()]
                                                          ['sending']
                                                      ? Stack(
                                                          fit: StackFit.expand,
                                                          children: [
                                                            Image.memory(
                                                              message[index
                                                                          .toString()]
                                                                      [
                                                                      'imageUrl']
                                                                  [index2],
                                                              fit: BoxFit.cover,
                                                            ),
                                                            const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                                backgroundColor:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : InkWell(
                                                          onTap: () =>
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            FullScreenView(
                                                                      ispath:
                                                                          false,
                                                                      snap: message[index.toString()]
                                                                              [
                                                                              'imageUrl']
                                                                          [
                                                                          index2],
                                                                    ),
                                                                  )),
                                                          child: Hero(
                                                            tag: message[index
                                                                        .toString()]
                                                                    ['imageUrl']
                                                                [index2],
                                                            child:
                                                                CachedNetworkImage(
                                                              filterQuality:
                                                                  FilterQuality
                                                                      .low,
                                                              placeholderFadeInDuration:
                                                                  const Duration(
                                                                      microseconds:
                                                                          1),
                                                              fadeOutDuration:
                                                                  const Duration(
                                                                      microseconds:
                                                                          1),
                                                              fadeInDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1),
                                                              imageUrl: message[
                                                                          index
                                                                              .toString()]
                                                                      [
                                                                      'imageUrl']
                                                                  [index2],
                                                              fit: BoxFit.cover,
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(
                                                                      Icons
                                                                          .error,
                                                                      color: Colors
                                                                          .black),
                                                            ),
                                                          ),
                                                        );
                                                },
                                              ),
                                            Text(
                                              message[index.toString()]['name'],
                                              style: const TextStyle(
                                                  color: Colors.deepOrange,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              message[index.toString()]['text'],
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 3),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          DateFormat.Hm('tr_TR')
                                                              .format(message[index
                                                                      .toString()]
                                                                  ['date']),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        const Icon(
                                                          Iconsax.eye,
                                                          color: Colors.black,
                                                          size: 12,
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          message[index
                                                                      .toString()]
                                                                  ['isSeen']
                                                              .length
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 10),
                                                        )
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ],
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
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(18))),
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
                                icon: const Icon(Iconsax.emoji_happy)),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 0, right: 8),
                                child: TextField(
                                  focusNode: focusNode,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color),
                                  controller: _textEditingController,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    focusColor: Colors.white,
                                    hintText: 'Mesaj yaz...',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (mounted) {
                                  if (_scrollController.position.pixels >=
                                      _scrollController
                                              .position.maxScrollExtent -
                                          200) {
                                    // Eğer son 300 pikseldeyse scrool işlemini gerçekleştir
                                    Future.delayed(Duration(milliseconds: 50),
                                        () {
                                      _scrollController.animateTo(
                                        _scrollController
                                            .position.maxScrollExtent,
                                        curve: Curves.easeInOut,
                                        duration: Duration(milliseconds: 200),
                                      );
                                    });
                                  }
                                }
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Stack(
                                      children: [
                                        Container(
                                          height: 200,
                                          width: double.infinity,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20.0)),
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  height: 7,
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SendImagesGroup(
                                                              snap: groupData,
                                                              name: userData[
                                                                      'name'] +
                                                                  " " +
                                                                  userData[
                                                                      'surname'],
                                                            ),
                                                          ));
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 30,
                                                        right: 15,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            height: 80,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    Colors.blue,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: const Icon(
                                                              Iconsax.gallery,
                                                              color:
                                                                  Colors.white,
                                                              size: 40,
                                                            ),
                                                          ),
                                                          const Text(
                                                            'Fotoğraf',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.0)),
                                  ),
                                  isScrollControlled: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 12, bottom: 12, right: 10),
                                child: const Icon(
                                  Iconsax.attach_circle,
                                  size: 32,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                DateTime date = DateTime.now();
                                String messageId = Uuid().v1();
                                if (_textEditingController.text.isNotEmpty) {
                                  try {
                                    if (mounted) {
                                      if (_scrollController.position.pixels >=
                                          _scrollController
                                                  .position.maxScrollExtent -
                                              200) {
                                        // Eğer son 300 pikseldeyse scrool işlemini gerçekleştir
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
                                  } catch (e) {}
                                  // Önce mevcut mesajları kopyalayın
                                  var existingMessages =
                                      List.from(message.values);

                                  existingMessages.add({
                                    'text': _textEditingController.text.trim(),
                                    'date': date,
                                    'isSeen': [
                                      FirebaseAuth.instance.currentUser!.uid
                                    ],
                                    'senderId':
                                        FirebaseAuth.instance.currentUser!.uid,
                                    'name': userData['name'] +
                                        " " +
                                        userData['surname'],
                                    'messageId': messageId,
                                    "sending": false,
                                  });
                                  var newMessage = {
                                    for (var i = 0;
                                        i < existingMessages.length;
                                        i++)
                                      i.toString(): existingMessages[i],
                                  };
                                  GroupMessageBox.saveGroupMessage(
                                      widget.snap, newMessage);
                                  FireStoreMethods().sendMessageGroup(
                                      _textEditingController.text.trim(),
                                      FirebaseAuth.instance.currentUser!.uid,
                                      date,
                                      userData['name'] +
                                          " " +
                                          userData['surname'],
                                      messageId,
                                      widget.snap);

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
                          checkPlatformCompatibility: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
