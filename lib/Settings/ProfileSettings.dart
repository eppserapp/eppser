import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/LandingPage.dart';
import 'package:eppser/Resources/storageMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  bool _loading = false;
  Uint8List? _file;
  String profImage = "";

  @override
  void dispose() {
    _userNameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
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

  void postImage() async {
    String res = "Some error occurred";
    setState(() {
      _loading = true;
    });
    // start the loading
    try {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) => profImage = value.data()!['profImage'])
          .whenComplete(
              () => FirebaseStorage.instance.refFromURL(profImage).delete());

      String photoUrl = await StorageMethods().uploadImageToStorage(
          'profImage', FirebaseAuth.instance.currentUser!.uid, _file!, true);

      // upload to storage and db
      FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profImage': photoUrl});
      res = "success";
      if (res == "success") {
        setState(() {
          _loading = false;
        });
        // ignore: use_build_context_synchronously
        showSnackBar(
          context,
          'Güncellendi!',
        );
      } else {
        print(res);
      }
    } catch (err) {
      setState(() {
        _loading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Profili Düzenle',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              icon: const Icon(
                Iconsax.login_1,
                color: Colors.black,
                size: 32,
              ),
              onPressed: () => FirebaseAuth.instance
                  .signOut()
                  .whenComplete(() => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LandingScreen(),
                      ),
                      (route) => false)),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(
            height: 24,
          ),
          Center(
            child: Stack(
              children: [
                _file != null
                    ? InkWell(
                        onTap: () => _selectImage(context),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              color: Colors.black,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(_file!))),
                        ),
                      )
                    : InkWell(
                        onTap: () => _selectImage(context),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
          const SizedBox(
            height: 24,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                        color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(
                      color: Colors.black, // Dış border rengi
                      width: 1.5, // Dış border kalınlığı
                    ),
                  ),
                  labelText: 'Ad',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  )),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _surnameController,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                        color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(
                      color: Colors.black, // Dış border rengi
                      width: 1.5, // Dış border kalınlığı
                    ),
                  ),
                  labelText: 'Soyad',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  )),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _userNameController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp("[a-zA-Z0-9-_şğüıçöŞĞÜİÇÖ.]")),
                FilteringTextInputFormatter.deny(RegExp("[ ]"))
              ],
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                        color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(
                      color: Colors.black, // Dış border rengi
                      width: 1.5, // Dış border kalınlığı
                    ),
                  ),
                  labelText: 'Kullanıcı Adı',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  )),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                        color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(
                      color: Colors.black, // Dış border rengi
                      width: 1.5, // Dış border kalınlığı
                    ),
                  ),
                  labelText: 'Hakkında',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  )),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(100, 0, 100, 0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () async {
                setState(() {
                  _loading = true;
                });
                try {
                  if (_nameController.text.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      'name': _nameController.text.trim(),
                    }).whenComplete(() => setState(() {
                              _loading = false;
                            }));
                  }
                  if (_surnameController.text.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      'surname': _surnameController.text.trim(),
                    }).whenComplete(() => setState(() {
                              _loading = false;
                            }));
                  }
                  if (_nameController.text.isNotEmpty ||
                      _surnameController.text.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      'searchname': _nameController.text.trim().toLowerCase() +
                          _surnameController.text.trim().toLowerCase(),
                    }).whenComplete(() => setState(() {
                              _loading = false;
                            }));
                  }
                  if (_userNameController.text.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      'username': _userNameController.text.trim(),
                    }).whenComplete(() => setState(() {
                              _loading = false;
                            }));
                  }
                  if (_bioController.text.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      'bio': _bioController.text.trim()
                    }).whenComplete(() => setState(() {
                              _loading = false;
                            }));
                  }
                  if (_file != null) {
                    return postImage();
                  }
                  // ignore: use_build_context_synchronously
                  showSnackBar(context, "Güncellendi");
                } catch (error) {
                  showSnackBar(context, "Bir hata oluştu");
                }
              },
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : const Text('Güncelle',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
