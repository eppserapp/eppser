import 'package:eppser/Pages/bottomBar.dart';
import 'package:eppser/Resources/authMethods.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:eppser/providers/phoneProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class registerPage extends StatefulWidget {
  const registerPage({Key? key}) : super(key: key);
  static String verify = "";

  @override
  State<registerPage> createState() => _registerPage();
}

class _registerPage extends State<registerPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  bool _loading = false;
  bool tick = false;
  var provider;

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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 10.0),
              child: const Text(
                "eppser",
                style: TextStyle(fontFamily: 'font1', fontSize: 40.0),
              )),
        ),
        body: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(fontSize: 20),
                )),
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
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  if (_nameController.text.isNotEmpty &&
                      _surnameController.text.isNotEmpty &&
                      _userNameController.text.isNotEmpty) {
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
                            _nameController.text.toLowerCase() +
                                _surnameController.text.toLowerCase(),
                            _bioController.text.trim(),
                            tick)
                        .whenComplete(() {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => bottomBar()),
                          ModalRoute.withName('/'));
                    });
                  } else {
                    return showSnackBar(context, "Zorunlu alanları doldurunuz");
                  }
                  // ignore: use_build_context_synchronously
                },
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Colors.white,
                      ))
                    : const Text('Devam et', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ));
  }
}
