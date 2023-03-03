import 'package:eppser/Pages/signUpVerify.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:eppser/providers/phoneProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

TextEditingController countryController = TextEditingController();
var phone = "";

class signUpPage extends StatefulWidget {
  const signUpPage({Key? key}) : super(key: key);

  static String verify = "";

  @override
  State<signUpPage> createState() => _signUpPage();
}

class _signUpPage extends State<signUpPage> {
  int provider = 0;
  bool _loading = false;

  @override
  void initState() {
    countryController.text = "+90";

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
            padding: const EdgeInsets.only(bottom: 10.0, right: 50),
            child: const Text(
              "eppser",
              style: TextStyle(fontFamily: 'font1', fontSize: 40.0),
            )),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Telefon Doğrulama",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Başlamadan telefonunuzu kaydetmemiz gerekiyor!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: countryController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Text(
                      "|",
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextField(
                      onChanged: (value) {
                        phone = value;
                        Provider.of<phoneProvider>(context, listen: false)
                            .set(countryController.text + phone);
                      },
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Telefon",
                      ),
                    ))
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      if (phone.isNotEmpty &&
                          countryController.text.isNotEmpty) {
                        setState(() {
                          _loading = true;
                        });
                        await FirebaseAuth.instance
                            .verifyPhoneNumber(
                          phoneNumber: '${countryController.text + phone}',
                          verificationCompleted:
                              (PhoneAuthCredential credential) {},
                          verificationFailed: (FirebaseAuthException e) {
                            print(e);
                            if (e.code == 'invalid-phone-number') {
                              showSnackBar(context,
                                  'Sağlanan telefon numarası geçersiz');
                            }
                          },
                          codeSent: (String verificationId, int? resendToken) {
                            signUpPage.verify = verificationId;
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        )
                            .whenComplete(() {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const signUpVerify()));
                          setState(() {
                            _loading = false;
                          });
                        });
                      }
                    },
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("Gönder")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
