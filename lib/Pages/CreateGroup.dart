import 'dart:typed_data';
import 'dart:ui';

import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
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
    return Dialog(
      insetPadding:
          const EdgeInsets.only(left: 10, right: 10, top: 40, bottom: 40),
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
                                    BorderRadius.all(Radius.circular(30)),
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
                  left: 20, right: 20, top: 10, bottom: 10),
              child: TextField(
                cursorColor: Colors.black,
                controller: _nameController,
                decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
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
                  left: 20, right: 20, top: 10, bottom: 10),
              child: TextField(
                cursorColor: Colors.black,
                controller: _aboutController,
                decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
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
                        .createGroup(
                            _nameController.text.trim(),
                            FirebaseAuth.instance.currentUser!.uid,
                            [FirebaseAuth.instance.currentUser!.uid],
                            [FirebaseAuth.instance.currentUser!.uid],
                            _file,
                            _aboutController.text.trim())
                        .then((value) {
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.of(context).pop();
                      showSnackBar(context, "Grup Oluşturuldu");
                    });
                  } else if (_nameController.text.isEmpty ||
                      _aboutController.text.isEmpty) {
                    setState(() {
                      _showText = true;
                    });

                    Future.delayed(Duration(seconds: 3), () {
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
    );
  }
}
