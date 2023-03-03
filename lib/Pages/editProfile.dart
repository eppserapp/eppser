import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../Resources/storageMethods.dart';

class editProfilePage extends StatefulWidget {
  const editProfilePage({super.key});

  @override
  State<editProfilePage> createState() => _editProfilePageState();
}

class _editProfilePageState extends State<editProfilePage> {
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

      String photoUrl = await StorageMethods()
          .uploadImageToStorage('profImage', _file!, true);

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
        if (kDebugMode) {
          print(res);
        }
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
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
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  border: OutlineInputBorder(),
                  labelText: 'Ad',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _surnameController,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  border: OutlineInputBorder(),
                  labelText: 'Soyad',
                ),
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
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  border: OutlineInputBorder(),
                  labelText: 'Kullanıcı Adı',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  border: OutlineInputBorder(),
                  labelText: 'Biyografi',
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(100, 0, 100, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  try {
                    if (_nameController.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'name': _nameController.text.trim(),
                      });
                    }
                    if (_surnameController.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'surname': _surnameController.text.trim(),
                      });
                    }
                    if (_nameController.text.isNotEmpty ||
                        _surnameController.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'searchname':
                            _nameController.text.trim().toLowerCase() +
                                _surnameController.text.trim().toLowerCase(),
                      });
                    }
                    if (_userNameController.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'username': _userNameController.text.trim(),
                      });
                    }
                    if (_bioController.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({'bio': _bioController.text.trim()});
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
                    : const Text('Güncelle', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
