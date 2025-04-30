import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Resources/storageMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController _surnameController = TextEditingController();
  bool _loading = false;
  Uint8List? _file;
  String profImage = "";

  @override
  void dispose() {
    _userNameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
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
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Profili Düzenle',
          style: TextStyle(color: Colors.white),
        ),
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
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(120 * 0.4)),
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(_file!))),
                        ),
                      )
                    : InkWell(
                        onTap: () => _selectImage(context),
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(120 * 0.4)),
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          child: Icon(
                            Iconsax.add,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            size: 40,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Lütfen güncellemek istediğiniz alanları doldurunuz!',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: const Color.fromRGBO(0, 86, 255, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: TextField(
              cursorColor: Theme.of(context).textTheme.bodyMedium!.color,
              controller: _nameController,
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Iconsax.user,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                        color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(245, 247, 249, 1),
                      width: 2,
                    ),
                  ),
                  labelText: 'Ad',
                  labelStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  )),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: TextField(
              cursorColor: Theme.of(context).textTheme.bodyMedium!.color,
              controller: _surnameController,
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Iconsax.user,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                        color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(245, 247, 249, 1),
                      width: 2,
                    ),
                  ),
                  labelText: 'Soyad',
                  labelStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  )),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: TextField(
              cursorColor: Theme.of(context).textTheme.bodyMedium!.color,
              controller: _userNameController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp("[a-zA-Z0-9-_şğüıçöŞĞÜİÇÖ.]")),
                FilteringTextInputFormatter.deny(RegExp("[ ]"))
              ],
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Iconsax.user_edit,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                        color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(245, 247, 249, 1),
                      width: 2,
                    ),
                  ),
                  labelText: 'Kullanıcı Adı',
                  labelStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
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
                  backgroundColor:
                      Theme.of(context).textTheme.bodyMedium!.color,
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
                    showSnackBar(context, "Güncellendi");
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
                    showSnackBar(context, "Güncellendi");
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
                    showSnackBar(context, "Güncellendi");
                  }

                  if (_file != null) {
                    return postImage();
                  }
                } catch (error) {
                  showSnackBar(context, "Bir hata oluştu");
                }
              },
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ))
                  : Text('Güncelle',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      )),
            ),
          ),
        ],
      ),
    );
  }
}
