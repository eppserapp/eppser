import 'dart:convert';

import 'package:eppser/Pages/BottomBar.dart';
import 'package:eppser/Providers/phoneProvider.dart';
import 'package:eppser/Resources/authMethods.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class registerPage extends StatefulWidget {
  const registerPage({Key? key}) : super(key: key);

  @override
  State<registerPage> createState() => _registerPage();
}

class _registerPage extends State<registerPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  var provider;
  bool _loading = false;
  bool _uniqueUserName = false;

  Future<void> checkUsernameAvailability() async {
    final username = _userNameController.text.trim();
    if (username.isEmpty) {
      showSnackBar(context, 'Lütfen bir kullanıcı adı giriniz.');
    }

    final url = Uri.parse(
        'https://us-central1-eppser-1a6a5.cloudfunctions.net/checkUsernameAvailability?username=$username');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _uniqueUserName = data['available'];
      });
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    provider = Provider.of<phoneProvider>(context, listen: false).phn;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Iconsax.arrow_left_2,
              color: Colors.black,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: RichText(
                  text: TextSpan(
                    text: 'Kayıt ol',
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      color: const Color.fromRGBO(0, 86, 255, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Lütfen gerekli alanları doldurunuz!',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: TextField(
                cursorColor: Colors.black,
                controller: _nameController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(245, 247, 249, 1),
                        width: 2,
                      ),
                    ),
                    labelText: 'Ad',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    )),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: TextField(
                cursorColor: Colors.black,
                controller: _surnameController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(245, 247, 249, 1),
                        width: 2,
                      ),
                    ),
                    labelText: 'Soyad',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    )),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: TextField(
                cursorColor: Colors.black,
                controller: _userNameController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp("[a-zA-Z0-9-_şğüıçöŞĞÜİÇÖ.]")),
                  FilteringTextInputFormatter.deny(RegExp("[ ]"))
                ],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    checkUsernameAvailability();
                  }
                },
                decoration: InputDecoration(
                    suffix: _uniqueUserName
                        ? const Icon(
                            Iconsax.tick_circle,
                            color: Colors.green,
                          )
                        : const Icon(
                            Iconsax.close_circle,
                            color: Colors.red,
                          ),
                    prefixIcon: const Icon(Iconsax.user_edit),
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
                    labelStyle: const TextStyle(
                      color: Colors.black,
                    )),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: TextField(
                cursorColor: Colors.black,
                controller: _bioController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.note_2),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(245, 247, 249, 1),
                        width: 2,
                      ),
                    ),
                    labelText: 'Hakkında',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    )),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: MediaQuery.of(context).size.height / 14,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.2,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 86, 255, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18))),
                onPressed: () async {
                  if (_uniqueUserName) {
                    if (_nameController.text.isNotEmpty &&
                        _surnameController.text.isNotEmpty &&
                        _userNameController.text.isNotEmpty &&
                        _bioController.text.isNotEmpty) {
                      setState(() {
                        _loading = true;
                      });
                      await FireStoreMethods().addPhone(provider.toString(),
                          FirebaseAuth.instance.currentUser!.uid);
                      await AuthMethods()
                          .firestoreAdd(
                        _userNameController.text.trim(),
                        _nameController.text.trim(),
                        _surnameController.text.trim(),
                        _bioController.text.trim(),
                      )
                          .whenComplete(() {
                        setState(() {
                          _loading = false;
                        });
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => bottomBar()));
                      });
                    } else {
                      return showSnackBar(
                          context, "Zorunlu alanları doldurunuz");
                    }
                  } else {
                    return showSnackBar(
                        context, 'Bu kullanıcı adı kullanılıyor!');
                  }
                  // ignore: use_build_context_synchronously
                },
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Colors.white,
                      ))
                    : const Text('Kayıt ol',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ));
  }
}
