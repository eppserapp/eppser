import 'package:eppser/Pages/BottomBar.dart';
import 'package:eppser/Pages/LandingPage.dart';
import 'package:eppser/Pages/Register.dart';
import 'package:eppser/Providers/phoneProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class loginVerify extends StatefulWidget {
  const loginVerify({Key? key}) : super(key: key);

  @override
  State<loginVerify> createState() => _loginVerifyState();
}

class _loginVerifyState extends State<loginVerify> {
  var code = "";
  bool _loading = false;

  Future<void> checkPhoneNumber(String phoneNumber) async {
    const functionsUrl =
        "https://us-central1-eppser-1a6a5.cloudfunctions.net/checkPhoneNumber";

    final encodedPhoneNumber = Uri.encodeQueryComponent(phoneNumber);

    final response = await http.get(Uri.parse(
        "$functionsUrl/checkPhoneNumber?phoneNumber=$encodedPhoneNumber"));

    if (response.statusCode == 200) {
      setState(() {
        _loading = true;
      });
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: LandingScreen.verify, smsCode: code);
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => bottomBar()),
          (route) => false,
        );
      }
    } else {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: LandingScreen.verify, smsCode: code);
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => registerPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 10.0, right: 50),
            child: const Text(
              "eppser",
              style: TextStyle(
                  fontFamily: 'font1', fontSize: 40.0, color: Colors.white),
            )),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover),
        ),
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
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 86, 255, 1),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Giriş yapmak için lütfen gelen kodu giriniz!",
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Pinput(
                autofocus: true,
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 60,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.transparent),
                  ),
                ),
                length: 6,
                pinAnimationType: PinAnimationType.scale,
                animationCurve: Curves.easeInOut,
                focusedPinTheme: PinTheme(
                  width: 66,
                  height: 70,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.transparent),
                  ),
                ),
                onChanged: (value) {
                  code = value;
                },
                showCursor: true,
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height / 14,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(0, 86, 255, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      if (code.isNotEmpty) {
                        setState(() {
                          _loading = true;
                        });
                        checkPhoneNumber(Provider.of<phoneProvider>(context,
                                    listen: false)
                                .phn)
                            .whenComplete(() {
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
                        : const Text("Doğrula",
                            style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
