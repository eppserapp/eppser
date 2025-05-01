import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Database/Groups.dart';
import 'package:eppser/Pages/BottomBar.dart';
import 'package:eppser/Pages/Chat.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class GroupView extends StatefulWidget {
  final snap;
  const GroupView({super.key, this.snap});

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  bool isLoading = false;
  var groupData;
  var userData;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  Uint8List? _file;
  var photoUrl;

  @override
  initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });

    groupData = GroupBox.getGroupData(widget.snap['groupId']);

    var data = await FirebaseFirestore.instance
        .collection('Users')
        .where('uid', whereIn: widget.snap['members'])
        .get();
    userData = data.docs.map((e) => e.data()).toList();
    userData = userData.toList().reversed.toList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('groupBox').listenable(),
      builder: (context, value, child) {
        groupData = GroupBox.getGroupData(widget.snap['groupId']);
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: IconButton(
                icon: Icon(
                  Iconsax.arrow_left_2,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: isLoading
                ? const SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: Text(
                          '${userData.length} Üye',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
            actions: [
              if ((widget.snap['admins'] as List)
                  .contains(FirebaseAuth.instance.currentUser!.uid))
                IconButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          child: StatefulBuilder(
                            builder: (context, setState) =>
                                SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Center(
                                      child: Stack(
                                        children: [
                                          _file != null
                                              ? InkWell(
                                                  onTap: () => showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return SimpleDialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        surfaceTintColor:
                                                            Colors.white,
                                                        title: const Text(
                                                            'Fotoğraf Yükle'),
                                                        children: <Widget>[
                                                          SimpleDialogOption(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              child: const Text(
                                                                  'Kamera'),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.pop(
                                                                    context);
                                                                Uint8List file =
                                                                    await pickImage(
                                                                        ImageSource
                                                                            .camera);
                                                                setState(() {
                                                                  _file = file;
                                                                });
                                                              }),
                                                          SimpleDialogOption(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              child: const Text(
                                                                  "Galeri'den Seç"),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Uint8List file =
                                                                    await pickImage(
                                                                        ImageSource
                                                                            .gallery);
                                                                setState(() {
                                                                  _file = file;
                                                                });
                                                              }),
                                                          SimpleDialogOption(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            child: const Text(
                                                                "İptal"),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  child: Container(
                                                    height: 100,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    30)),
                                                        color: Colors.black,
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: MemoryImage(
                                                                _file!))),
                                                  ),
                                                )
                                              : InkWell(
                                                  onTap: () => showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return SimpleDialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        surfaceTintColor:
                                                            Colors.white,
                                                        title: const Text(
                                                            'Fotoğraf Yükle'),
                                                        children: <Widget>[
                                                          SimpleDialogOption(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              child: const Text(
                                                                  'Kamera'),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.pop(
                                                                    context);
                                                                Uint8List file =
                                                                    await pickImage(
                                                                        ImageSource
                                                                            .camera);
                                                                setState(() {
                                                                  _file = file;
                                                                });
                                                              }),
                                                          SimpleDialogOption(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              child: const Text(
                                                                  "Galeri'den Seç"),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Uint8List file =
                                                                    await pickImage(
                                                                        ImageSource
                                                                            .gallery);
                                                                setState(() {
                                                                  _file = file;
                                                                });
                                                              }),
                                                          SimpleDialogOption(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            child: const Text(
                                                                "İptal"),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  child: Container(
                                                    height: 100,
                                                    width: 100,
                                                    decoration:
                                                        const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  30)),
                                                      color: Colors.black,
                                                    ),
                                                    child: const Icon(
                                                      Iconsax.add,
                                                      color: Colors.white,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    child: TextField(
                                      cursorColor: Colors.black,
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    0, 86, 255, 1),
                                                width: 2.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          labelText: 'Grup Adı',
                                          labelStyle: TextStyle(
                                            color: Colors.grey,
                                          )),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    child: TextField(
                                      cursorColor: Colors.black,
                                      controller: _aboutController,
                                      decoration: const InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    0, 86, 255, 1),
                                                width: 2.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          labelText: 'Hakkında',
                                          labelStyle: TextStyle(
                                            color: Colors.grey,
                                          )),
                                    ),
                                  ),
                                  Center(
                                    child: FloatingActionButton(
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await FireStoreMethods()
                                            .editCommunityGroup(
                                          _nameController.text != ""
                                              ? _nameController.text.trim()
                                              : groupData['name'],
                                          groupData['groupId'],
                                          groupData['communityId'],
                                          _file,
                                          _aboutController.text != ""
                                              ? _aboutController.text.trim()
                                              : groupData['about'],
                                        )
                                            .then((value) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          Navigator.of(context).pop();
                                          showSnackBar(
                                              context, "Grup Güncellendi!");
                                        });
                                      },
                                      shape: const CircleBorder(),
                                      backgroundColor:
                                          const Color.fromRGBO(0, 86, 255, 1),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Iconsax.edit_2,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    size: 30,
                  ),
                ),
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          title: const Text('Gruptan Çık'),
                          content: const Text(
                              'Gruptan çıkmak istediğinize emin misiniz?',
                              style: TextStyle(color: Colors.black)),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'İptal',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('Community')
                                    .doc(groupData['communityId'])
                                    .collection('Groups')
                                    .doc(groupData['groupId'])
                                    .update({
                                  'members': FieldValue.arrayRemove(
                                      [FirebaseAuth.instance.currentUser!.uid]),
                                  'admins': FieldValue.arrayRemove(
                                      [FirebaseAuth.instance.currentUser!.uid])
                                });

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => bottomBar(),
                                    ),
                                    (route) => false);
                              },
                              child: const Text(
                                'Evet',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Iconsax.login_1,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    size: 32,
                  ))
            ],
          ),
          body: RefreshIndicator(
            backgroundColor: Colors.white,
            color: Colors.black,
            onRefresh: () {
              return getData();
            },
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                : ListView.builder(
                    itemCount: userData.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          // if (index == 0)
                          //   InkWell(
                          //     onTap: () {},
                          //     child: Row(
                          //       children: [
                          //         Padding(
                          //           padding: const EdgeInsets.only(
                          //               left: 10, right: 10),
                          //           child: Container(
                          //             decoration: BoxDecoration(
                          //               color: Theme.of(context)
                          //                   .textTheme
                          //                   .bodyMedium
                          //                   ?.color,
                          //               borderRadius: BorderRadius.all(
                          //                   Radius.circular(50 * 0.4)),
                          //             ),
                          //             height: 50,
                          //             width: 50,
                          //             child: Icon(
                          //               Iconsax.user_add,
                          //               color: Theme.of(context)
                          //                   .scaffoldBackgroundColor,
                          //               size: 24,
                          //             ),
                          //           ),
                          //         ),
                          //         Text(
                          //           'Üye ekle (Davet Et)',
                          //           style: TextStyle(
                          //               color: Theme.of(context)
                          //                   .textTheme
                          //                   .bodyMedium
                          //                   ?.color,
                          //               fontSize: 18,
                          //               fontWeight: FontWeight.bold),
                          //         )
                          //       ],
                          //     ),
                          //   ),
                          InkWell(
                            onTap: () => userData[index]['uid'] !=
                                    FirebaseAuth.instance.currentUser!.uid
                                ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Chat(snap: userData[index]['uid']),
                                    ),
                                  )
                                : null,
                            onLongPress: () {
                              if (groupData['admins'].contains(
                                  FirebaseAuth.instance.currentUser!.uid)) {
                                showDialog(
                                  context: context,
                                  builder: (context) => SimpleDialog(
                                    backgroundColor: Colors.white,
                                    surfaceTintColor: Colors.white,
                                    children: [
                                      if (groupData['admins'].contains(
                                              userData[index]['uid']) &&
                                          groupData['uid'] !=
                                              userData[index]['uid'])
                                        SimpleDialogOption(
                                          padding: const EdgeInsets.all(10),
                                          child: const Text(
                                              'Yöneticilikten Çıkar',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('Community')
                                                .doc(groupData['communityId'])
                                                .collection('Groups')
                                                .doc(groupData['groupId'])
                                                .update({
                                              'admins': FieldValue.arrayRemove(
                                                  [userData[index]['uid']])
                                            });
                                            Navigator.pop(context);
                                            getData();
                                          },
                                        ),
                                      if (!groupData['admins']
                                          .contains(userData[index]['uid']))
                                        SimpleDialogOption(
                                          padding: const EdgeInsets.all(10),
                                          child: const Text('Yönetici Yap',
                                              style: TextStyle(
                                                  color: Colors.green)),
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('Community')
                                                .doc(groupData['communityId'])
                                                .collection('Groups')
                                                .doc(groupData['groupId'])
                                                .update({
                                              'admins': FieldValue.arrayUnion(
                                                  [userData[index]['uid']])
                                            });
                                            getData();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      if (groupData['admins'].contains(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid) &&
                                          !groupData['admins'].contains(
                                              userData[index]['uid']) &&
                                          groupData['uid'] !=
                                              userData[index]['uid'])
                                        SimpleDialogOption(
                                          padding: const EdgeInsets.all(10),
                                          child: const Text('Gruptan Çıkar',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('Community')
                                                .doc(groupData['communityId'])
                                                .collection('Groups')
                                                .doc(groupData['groupId'])
                                                .update({
                                              'members': FieldValue.arrayRemove(
                                                  [userData[index]['uid']]),
                                            });
                                            setState(() {
                                              userData.removeWhere((element) =>
                                                  element['uid'] ==
                                                  userData[index]['uid']);
                                            });
                                            Navigator.pop(context);
                                          },
                                        )
                                    ],
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, top: 5, right: 10),
                                  child: userData[index]['profImage'] != null
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50 * 0.4)),
                                          child: Image.network(
                                            userData[index]['profImage'],
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                  0, 86, 255, 1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      50 * 0.4)),
                                          child: const Icon(
                                            Iconsax.people,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6),
                                          child: Text(
                                            userData[index]['name'] +
                                                " " +
                                                userData[index]['surname'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        if (groupData['admins']
                                            .contains(userData[index]['uid']))
                                          Container(
                                            padding: const EdgeInsets.only(
                                                left: 7, right: 7),
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                              'Yönetici',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                                fontSize: 18,
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                    if (userData[index]['bio'] != null)
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6),
                                        child: Text(
                                          userData[index]['bio'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
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
                    }),
          ),
        );
      },
    );
  }
}
