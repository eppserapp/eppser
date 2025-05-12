import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eppser/Pages/LoginVerify.dart';
import 'package:eppser/Pages/Register.dart';
import 'package:eppser/Providers/phoneProvider.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  final user;
  static String verify = "";
  const LandingScreen({Key? key, this.user}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  TextEditingController countryCodeController =
      TextEditingController(text: "+90");
  TextEditingController phoneController = TextEditingController();
  int provider = 0;
  bool _loading = false;

  void _validatePhoneInput() {
    if (phoneController.text.trim().length < 10) {
      showSnackBar(context, 'Lütfen geçerli bir telefon numarası giriniz!');
    }
  }

  Future<void> checkPhoneNumber(String phoneNumber) async {
    setState(() {
      _loading = true;
    });
    await FirebaseAuth.instance
        .verifyPhoneNumber(
          // ignore: unnecessary_string_interpolations
          phoneNumber: '${countryCodeController.text + phoneController.text}',
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            print('Verification failed: ${e.code} - ${e.message}');
            if (e.code == 'invalid-phone-number') {
              showSnackBar(context, 'Sağlanan telefon numarası geçerli değil!');
            } else {
              showSnackBar(
                  context, 'Doğrulama sırasında hata oluştu: ${e.message}');
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            LandingScreen.verify = verificationId;
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        )
        .whenComplete(() => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const loginVerify())));
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover),
          ),
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: <Widget>[
                //content ui
                Positioned(
                  top: 8.0,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //logo section
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                AnimatedTextKit(animatedTexts: [
                                  ColorizeAnimatedText('eppser',
                                      textStyle: const TextStyle(
                                        fontFamily: 'font1',
                                        fontSize: 80,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      colors: [
                                        Colors.white,
                                        const Color.fromRGBO(0, 86, 255, 1),
                                      ])
                                ]),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, right: 25, top: 50),
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Değiştirildi: Telefon numarası girişi iki TextField olarak (ülke kodu ve numara)
                                  Container(
                                    height: size.height / 12,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18.0),
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          child: TextField(
                                            controller: countryCodeController,
                                            keyboardType: TextInputType.phone,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 18,
                                          width: 2,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: TextField(
                                            autofocus: true,
                                            onChanged: (value) {
                                              Provider.of<phoneProvider>(
                                                      context,
                                                      listen: false)
                                                  .set(countryCodeController
                                                          .text +
                                                      value);
                                            },
                                            controller: phoneController,
                                            keyboardType: TextInputType.phone,
                                            cursorColor: const Color.fromRGBO(
                                                0, 86, 255, 1),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Telefon',
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      _validatePhoneInput();
                                      if (phoneController.text.isNotEmpty) {
                                        setState(() {
                                          _loading = true;
                                        });
                                        checkPhoneNumber(
                                                '${countryCodeController.text + phoneController.text}')
                                            .whenComplete(() {
                                          setState(() {
                                            _loading = false;
                                          });
                                        });
                                      }
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        height: size.height / 14,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          color: const Color.fromRGBO(
                                              0, 86, 255, 1),
                                        ),
                                        child: _loading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : const Text(
                                                "Devam Et",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          buildFooter(size),

                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'Gizlilik Politikası ',
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      color:
                                          const Color.fromRGBO(0, 86, 255, 1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                    children: <TextSpan>[
                                      const TextSpan(
                                        text: 've',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      TextSpan(
                                        text: ' Kullanım Koşulları',
                                        style: GoogleFonts.nunito(
                                            fontSize: 18,
                                            color: const Color.fromRGBO(
                                                0, 86, 255, 1),
                                            fontWeight: FontWeight.bold),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {},
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFooter(Size size) {
    return Align(
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          style: GoogleFonts.nunito(
            fontSize: 18,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: 'Bir hesabın yok mu? ',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: 'Kayıt ol',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const registerPage(),
                  ));
                },
              style: GoogleFonts.nunito(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
