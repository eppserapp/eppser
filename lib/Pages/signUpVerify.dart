import 'package:eppser/Pages/register.dart';
import 'package:eppser/Pages/signUp.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class signUpVerify extends StatefulWidget {
  const signUpVerify({Key? key}) : super(key: key);

  @override
  State<signUpVerify> createState() => _signUpVerifyState();
}

class _signUpVerifyState extends State<signUpVerify> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var code = "";
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
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
              Pinput(
                length: 6,
                onChanged: (value) {
                  code = value;
                },
                showCursor: true,
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
                      if (code.isNotEmpty) {
                        setState(() {
                          _loading = true;
                        });
                        try {
                          PhoneAuthCredential credential =
                              PhoneAuthProvider.credential(
                                  verificationId: signUpPage.verify,
                                  smsCode: code);

                          // Sign the user in (or link) with the credential
                          await auth
                              .signInWithCredential(credential)
                              .whenComplete(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const registerPage()));
                            setState(() {
                              _loading = false;
                            });
                          });
                        } catch (e) {
                          showSnackBar(context, "Yanlış Kod");
                        }
                      }
                    },
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("Kayıt ol")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
