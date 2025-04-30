import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Database/Message.dart';
import 'package:eppser/Database/Users.dart';
import 'package:eppser/Pages/Chat.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:eppser/Widgets/ChatCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late final List<StreamSubscription> _subscriptions = [];
  var userData;

  @override
  void initState() {
    super.initState();
    fetchAndSaveMessages();
    fetchAndSaveUserData();
    getUserData();
  }

  void getUserData() async {
    // Fetch user data from Firestore and save it to local storage.
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    userData = userDoc.data();
    setState(() {});
  }

  void fetchAndSaveUserData() {
    // Listen to chat partners' data changes.
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
    // Listen for changes in chat list.
    final messagesChatsSubscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Chats')
        .snapshots()
        .listen((chatsSnapshot) {
      for (var chatDoc in chatsSnapshot.docs) {
        final chatPartnerId = chatDoc.id;
        // Listen to changes in messages for each chat partner.
        final messagesSubscription = FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Chats')
            .doc(chatPartnerId)
            .collection('Messages')
            .orderBy('date', descending: false)
            .snapshots()
            .listen((messagesSnapshot) async {
          // Retrieve the current stored messages.
          List existingMessages =
              List.from(MessageBox.getMessage(chatPartnerId)?.values ?? []);

          // Process each message change.
          for (var msgDoc in messagesSnapshot.docs) {
            final messageData = msgDoc.data();
            var senderId = messageData['senderId'];

            // Check if a message with the same messageId already exists.
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

          // Convert the list into a map with index keys.
          var newMessagesMap = {
            for (var i = 0; i < existingMessages.length; i++)
              i: existingMessages[i],
          };

          // Update the local storage.
          await MessageBox.saveMessageData(chatPartnerId, newMessagesMap);
        });
        _subscriptions.add(messagesSubscription);
      }
    });
    _subscriptions.add(messagesChatsSubscription);
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        toolbarHeight: 150,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: userData['profImage'] != null
                  ? NetworkImage(userData['profImage'])
                  : AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hoşgeldin",
                    style: TextStyle(
                        fontSize: 34,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold),
                  ).animate().move(
                        duration: 800.ms,
                        begin: const Offset(-20, 0),
                        end: Offset.zero,
                        curve: Curves.easeOut,
                      ),
                  Text(
                    userData['name'] ?? "",
                    style: const TextStyle(
                        fontSize: 38,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ).animate().move(
                        duration: 800.ms,
                        begin: const Offset(20, 0),
                        end: Offset.zero,
                        curve: Curves.easeOut,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: MessageBox.getAllMessages() != null &&
              UserBox.getAllUserData() != null
          ? ValueListenableBuilder(
              valueListenable: Hive.box('messageBox').listenable(),
              builder: (context, value, child) {
                final items = MessageBox.getAllMessages()?.entries.toList();
                return ListView.builder(
                  itemCount: items?.length,
                  itemBuilder: (context, index) {
                    final item = items![index];
                    var userData;
                    String myId = FirebaseAuth.instance.currentUser!.uid;

                    final messagesMap = (item.value as Map);
                    final lastMessage = messagesMap.entries.last.value;
                    String senderId = lastMessage['senderId'];
                    String receiverId = lastMessage['receiverId'];

                    if (receiverId == myId) {
                      userData = senderId;
                    } else {
                      userData = receiverId;
                    }

                    return GestureDetector(
                        onLongPress: () {
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
                                                // await FireStoreMethods()
                                                //     .deleteChat(
                                                //         snapshot.data!
                                                //                 .docs[index]
                                                //             ['recieverId'],
                                                //         snapshot.data!
                                                //                 .docs[index]
                                                //             ['senderId']);
                                                // // ignore: use_build_context_synchronously
                                                showSnackBar(
                                                  context,
                                                  'Sohbet Silindi!',
                                                );
                                                Navigator.of(context).pop();
                                              }),
                                        )
                                        .toList()),
                              );
                            },
                          );
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Chat(
                                      snap: userData,
                                    )),
                          );
                        },
                        child: ChatCard(
                          snap: userData,
                        ));
                  },
                );
              },
            )
          : SizedBox(),
    );
  }
}
