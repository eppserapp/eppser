import 'dart:typed_data';

import 'package:eppser/Database/GroupsMessage.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';

class SendImagesGroup extends StatefulWidget {
  final snap;
  final name;
  const SendImagesGroup({super.key, this.snap, this.name});

  @override
  State<SendImagesGroup> createState() => _SendImagesGroupState();
}

class _SendImagesGroupState extends State<SendImagesGroup> {
  List<Uint8List>? _file;
  TextEditingController _textEditingController = TextEditingController();
  var message;
  @override
  initState() {
    super.initState();
    message = GroupMessageBox.getGroupMessage(widget.snap['groupId']);
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.black,
          title: const Text(
            'Fotoğraf Yükle',
            style: TextStyle(color: Colors.white),
          ),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text("Galeri'den Seç"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  var file = await pickImages();
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("İptal"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: IconButton(
            icon: const Icon(
              Iconsax.arrow_left_2,
              color: Colors.black,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Fotoğraf Gönder',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _file == null
              ? InkWell(
                  onTap: () => _selectImage(context),
                  child: const Center(
                    child: Icon(
                      Iconsax.add,
                      color: Colors.black,
                      size: 70,
                    ),
                  ),
                )
              : Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5),
                    itemCount: _file!.length,
                    itemBuilder: (context, index) {
                      return Image.memory(
                        _file![index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(Radius.circular(18))),
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 8),
                    child: TextField(
                      style: const TextStyle(color: Colors.black),
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
                    DateTime date = DateTime.now();
                    String messageId = Uuid().v1();
                    if (_file != null) {
                      var existingMessages = message.values != null
                          ? List.from(message.values)
                          : [];

                      existingMessages.add({
                        'name': widget.name,
                        'imageUrl': _file!,
                        'text': _textEditingController.text.trim(),
                        'date': date,
                        'isSeen': false,
                        'senderId': FirebaseAuth.instance.currentUser!.uid,
                        'messageId': messageId,
                        "sending": true,
                      });
                      var newMessage = {
                        for (var i = 0; i < existingMessages.length; i++)
                          i.toString(): existingMessages[i],
                      };
                      GroupMessageBox.saveGroupMessage(
                          widget.snap['groupId'], newMessage);
                      if (_file != null) {
                        FireStoreMethods().sendImageMessageGroup(
                            widget.name,
                            _file!,
                            _textEditingController.text.trim(),
                            widget.snap['communityId'],
                            widget.snap['groupId'],
                            FirebaseAuth.instance.currentUser!.uid,
                            date,
                            messageId);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.only(top: 12, bottom: 12, right: 10),
                    child: const Icon(Iconsax.send_1,
                        size: 30, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
