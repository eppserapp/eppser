import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/CommunityPage.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class CreateCommunity extends StatefulWidget {
  const CreateCommunity({super.key});

  @override
  State<CreateCommunity> createState() => _CreateCommunityState();
}

class _CreateCommunityState extends State<CreateCommunity> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  Uint8List? _file;
  var _showText = false;
  bool isLoading = false;

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('Fotoğraf Yükle'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Kamera'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text("Galeri'den Seç"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
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
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Topluluk Oluştur",
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Iconsax.profile_2user,
                  size: 28,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                SizedBox(
                  width: 5,
                ),
                Text("Topluluklar",
                    style: GoogleFonts.signika(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 24,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Community')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(
                    "Hiç Topluluk Yok",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 16),
                  ));
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CommunityPage(
                                      communityId: data['communityId'],
                                    )));
                      },
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  child: data['imageUrl'] != null
                                      ? Image.network(
                                          data['imageUrl'],
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/moneybackground.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                top: 5,
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          data['approved'] != true
                                              ? "Onay Bekliyor!"
                                              : "Aktif",
                                          style: GoogleFonts.exo(
                                            color: data['approved'] != true
                                                ? Colors.red
                                                : Colors.green,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 5,
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          data['members'] != null
                                              ? data['members']
                                                  .length
                                                  .toString()
                                              : "0",
                                          style: GoogleFonts.exo(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Iconsax.profile_2user,
                                          size: 22,
                                          color: Colors.deepOrange,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 10,
                                right: 10,
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 20,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: data['photoUrl'] != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                child: SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child: CachedNetworkImage(
                                                    placeholderFadeInDuration:
                                                        const Duration(
                                                            microseconds: 1),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            microseconds: 1),
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 1),
                                                    imageUrl: data['photoUrl'],
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error,
                                                            color:
                                                                Colors.black),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                height: 60,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(
                                                        0, 86, 255, 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24)),
                                                child: const Icon(
                                                  Iconsax.people,
                                                  color: Colors.white,
                                                  size: 50,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              data['name'] ?? "Topluluk Adı",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              data['about'] ??
                                                  "Topluluk Açıklaması",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                                fontSize: 10,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              height: 3,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                insetPadding: const EdgeInsets.only(
                    left: 10, right: 10, top: 40, bottom: 40),
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: SingleChildScrollView(
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
                                      onTap: () => _selectImage(context),
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(30)),
                                          color: Colors.black,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: MemoryImage(_file!),
                                          ),
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () => _selectImage(context),
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: TextField(
                          cursorColor: Colors.black,
                          controller: _nameController,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(0, 86, 255, 1),
                                  width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                            ),
                            labelText: 'Topluluk Adı',
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: TextField(
                          cursorColor: Colors.black,
                          controller: _aboutController,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(0, 86, 255, 1),
                                  width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                            ),
                            labelText: 'Hakkında',
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      if (_showText)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Zorunlu alanlar boş bırakılamaz!',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      Center(
                        child: FloatingActionButton(
                          onPressed: () async {
                            if (_nameController.text.isNotEmpty &&
                                _aboutController.text.isNotEmpty) {
                              setState(() {
                                isLoading = true;
                              });
                              await FireStoreMethods()
                                  .createCommunity(
                                _nameController.text.trim(),
                                FirebaseAuth.instance.currentUser!.uid,
                                [FirebaseAuth.instance.currentUser!.uid],
                                [FirebaseAuth.instance.currentUser!.uid],
                                _file,
                                _aboutController.text.trim(),
                              )
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.of(context).pop();
                                showSnackBar(context, "Topluluk Oluşturuldu");
                              });
                            } else {
                              setState(() {
                                _showText = true;
                              });
                              Future.delayed(const Duration(seconds: 3), () {
                                setState(() {
                                  _showText = false;
                                });
                              });
                            }
                          },
                          shape: const CircleBorder(),
                          backgroundColor: const Color.fromRGBO(0, 86, 255, 1),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 24),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add,
            size: 30, color: Colors.deepOrange), // Change the icon as needed
      ),
    );
  }
}
