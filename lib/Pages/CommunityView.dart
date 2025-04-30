import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/BottomBar.dart';
import 'package:eppser/Pages/Chat.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class CommunityView extends StatefulWidget {
  final snap;
  const CommunityView({super.key, required this.snap});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  bool isLoading = false;
  var communityData;
  var userData;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  Uint8List? _file;
  Uint8List? _file2;
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
    // Get the community document using the communityId from widget.snap
    var communityDoc = await FirebaseFirestore.instance
        .collection('Community')
        .doc(widget.snap)
        .get();
    communityData = communityDoc.data();
    if (communityData != null) {
      // Retrieve the members list from the community data
      var members = communityData['members'];
      // Fetch the user details of each member
      var data = await FirebaseFirestore.instance
          .collection('Users')
          .where('uid', whereIn: members)
          .get();
      userData = data.docs.map((e) => e.data()).toList();
      userData = userData.toList().reversed.toList();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: IconButton(
                  icon: const Icon(
                    Iconsax.arrow_left_2,
                    color: Colors.white,
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
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
              actions: [
                if ((communityData['admins'] as List)
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: Center(
                                                child: Stack(
                                                  children: [
                                                    InkWell(
                                                      onTap: () => showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return SimpleDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            surfaceTintColor:
                                                                Colors.white,
                                                            title: const Text(
                                                              'Fotoğraf Yükle',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            children: <Widget>[
                                                              SimpleDialogOption(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          20),
                                                                  child:
                                                                      const Text(
                                                                    'Kamera',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.pop(
                                                                        context);
                                                                    Uint8List
                                                                        file =
                                                                        await pickImage(
                                                                            ImageSource.camera);
                                                                    setState(
                                                                        () {
                                                                      _file =
                                                                          file;
                                                                    });
                                                                  }),
                                                              SimpleDialogOption(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          20),
                                                                  child:
                                                                      const Text(
                                                                    "Galeri'den Seç",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    Uint8List
                                                                        file =
                                                                        await pickImage(
                                                                            ImageSource.gallery);
                                                                    setState(
                                                                        () {
                                                                      _file =
                                                                          file;
                                                                    });
                                                                  }),
                                                              SimpleDialogOption(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20),
                                                                child:
                                                                    const Text(
                                                                  "İptal",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                      child: _file != null
                                                          ? Container(
                                                              height: 100,
                                                              width: 100,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              30)),
                                                                  color: Colors
                                                                      .black,
                                                                  image: DecorationImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: MemoryImage(
                                                                          _file!))),
                                                            )
                                                          : Container(
                                                              height: 100,
                                                              width: 100,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              30)),
                                                                  color: Colors
                                                                      .black),
                                                              child: const Icon(
                                                                Iconsax.add,
                                                                size: 40,
                                                              ),
                                                            ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text('Topluluk Resmi',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                )),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: Center(
                                                child: Stack(
                                                  children: [
                                                    InkWell(
                                                      onTap: () => showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return SimpleDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            surfaceTintColor:
                                                                Colors.white,
                                                            title: const Text(
                                                                'Fotoğraf Yükle',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                            children: <Widget>[
                                                              SimpleDialogOption(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          20),
                                                                  child: const Text(
                                                                      'Kamera',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black)),
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.pop(
                                                                        context);
                                                                    Uint8List
                                                                        file =
                                                                        await pickImage(
                                                                            ImageSource.camera);
                                                                    setState(
                                                                        () {
                                                                      _file2 =
                                                                          file;
                                                                    });
                                                                  }),
                                                              SimpleDialogOption(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          20),
                                                                  child: const Text(
                                                                      "Galeri'den Seç",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black)),
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    Uint8List
                                                                        file =
                                                                        await pickImage(
                                                                            ImageSource.gallery);
                                                                    setState(
                                                                        () {
                                                                      _file2 =
                                                                          file;
                                                                    });
                                                                  }),
                                                              SimpleDialogOption(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20),
                                                                child: const Text(
                                                                    "İptal",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black)),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                      child: _file2 != null
                                                          ? Container(
                                                              height: 100,
                                                              width: 100,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              30)),
                                                                  color: Colors
                                                                      .black,
                                                                  image: DecorationImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: MemoryImage(
                                                                          _file2!))),
                                                            )
                                                          : Container(
                                                              height: 100,
                                                              width: 100,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            30)),
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              child: const Icon(
                                                                Iconsax.add,
                                                                size: 40,
                                                              ),
                                                            ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text('Kapak Resmi',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                )),
                                          ],
                                        ),
                                      ],
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
                                            labelText: 'Topluluk Adı',
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
                                              .editCommunity(
                                            _nameController.text != ""
                                                ? _nameController.text.trim()
                                                : communityData['name'],
                                            communityData['communityId'],
                                            _file,
                                            _file2,
                                            _aboutController.text != ""
                                                ? _aboutController.text.trim()
                                                : communityData['about'],
                                          )
                                              .then((value) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                            Navigator.of(context).pop();
                                            showSnackBar(
                                                context, "Güncellendi!");
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
                    icon: const Icon(
                      Iconsax.edit_2,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            surfaceTintColor: Colors.white,
                            title: const Text('Topluluktan Çık'),
                            content: const Text(
                                'Topluluk çıkmak istediğinize emin misiniz?'),
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
                                      .doc(communityData['communityId'])
                                      .update({
                                    'members': FieldValue.arrayRemove([
                                      FirebaseAuth.instance.currentUser!.uid
                                    ]),
                                    'admins': FieldValue.arrayRemove([
                                      FirebaseAuth.instance.currentUser!.uid
                                    ])
                                  });
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => bottomBar(),
                                      ),
                                      (route) => false);
                                  showSnackBar(context, "Topluluktan Çıkıldı!");
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
                    icon: const Icon(
                      Iconsax.login_1,
                      size: 32,
                      color: Colors.white,
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
                            if (index == 0)
                              const SizedBox(
                                height: 10,
                              ),
                            if (index == 0)
                              InkWell(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50 * 0.4)),
                                        ),
                                        height: 50,
                                        width: 50,
                                        child: Icon(
                                          Iconsax.user_add,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          size: 34,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Üye ekle (Davet Et)',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
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
                                if (communityData['admins'].contains(
                                    FirebaseAuth.instance.currentUser!.uid)) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => SimpleDialog(
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.white,
                                      children: [
                                        if (communityData['admins'].contains(
                                                userData[index]['uid']) &&
                                            communityData['uid'] !=
                                                userData[index]['uid'])
                                          SimpleDialogOption(
                                            padding: const EdgeInsets.all(10),
                                            child: const Text(
                                                'Yöneticilikten Çıkar'),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('Community')
                                                  .doc(communityData[
                                                      'communityId'])
                                                  .update({
                                                'admins':
                                                    FieldValue.arrayRemove([
                                                  userData[index]['uid']
                                                ])
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        if (!communityData['admins']
                                            .contains(userData[index]['uid']))
                                          SimpleDialogOption(
                                            padding: const EdgeInsets.all(10),
                                            child: const Text('Yönetici Yap'),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('Community')
                                                  .doc(communityData[
                                                      'communityId'])
                                                  .update({
                                                'admins': FieldValue.arrayUnion(
                                                    [userData[index]['uid']])
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        if (communityData['admins'].contains(
                                                FirebaseAuth.instance
                                                    .currentUser!.uid) &&
                                            !communityData['admins'].contains(
                                                userData[index]['uid']) &&
                                            communityData['uid'] !=
                                                userData[index]['uid'])
                                          SimpleDialogOption(
                                            padding: const EdgeInsets.all(10),
                                            child: const Text('Kanaldan Çıkar'),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('Community')
                                                  .doc(communityData[
                                                      'communityId'])
                                                  .update({
                                                'members':
                                                    FieldValue.arrayRemove([
                                                  userData[index]['uid'],
                                                ]),
                                                'admins':
                                                    FieldValue.arrayRemove([
                                                  userData[index]['uid'],
                                                ])
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
                                            borderRadius:
                                                const BorderRadius.all(
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
                                              size: 34,
                                            ),
                                          ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                    .bodyMedium!
                                                    .color,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          userData[index]['tick']
                                              ? const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 5, left: 2),
                                                  child: Icon(
                                                    Iconsax.verify5,
                                                    color: Color.fromRGBO(
                                                        0, 86, 255, 1),
                                                    size: 20,
                                                  ),
                                                )
                                              : const SizedBox(),
                                          if (communityData['admins']
                                              .contains(userData[index]['uid']))
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 7, right: 7),
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                              decoration: BoxDecoration(
                                                  color: Colors.amber,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: const Text(
                                                'Yönetici',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                      if (userData[index]['bio'] != "")
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
  }
}
