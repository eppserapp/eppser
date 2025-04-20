import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eppser/Web/AboutPage.dart';
import 'package:eppser/Web/ContactPage.dart';
import 'package:eppser/Web/WebLandingPage.dart';
import 'package:eppser/Widgets/FadeInUp.dart';
import 'package:eppser/Widgets/HoverableText.dart';
import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14, left: 16),
              child: AnimatedTextKit(
                totalRepeatCount: 1,
                animatedTexts: [
                  TypewriterAnimatedText(
                    "#goldisrealmoney",
                    textStyle: const TextStyle(
                        fontFamily: 'font1', fontSize: 42, color: Colors.amber),
                  ),
                  WavyAnimatedText("eppser",
                      textStyle: const TextStyle(
                          fontFamily: 'font1',
                          fontSize: 42,
                          color: Colors.white),
                      speed: const Duration(milliseconds: 150)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WebLandingPage(),
                          )),
                      child: const HoverableText(text: 'Ana Sayfa')),
                  const SizedBox(width: 30),
                  InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutPage(),
                          )),
                      child: const HoverableText(text: 'Hakkımızda')),
                  const SizedBox(width: 30),
                  InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactPage(),
                          )),
                      child: const HoverableText(text: 'İletişim')),
                  const SizedBox(width: 30),
                  const HoverableText(text: 'SSS'),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 86, 255, 1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            return Colors
                                .white; // Üzerine gelindiğinde beyaz olacak
                          }
                          return const Color.fromRGBO(
                              0, 86, 255, 1); // Varsayılan renk
                        },
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            return const Color.fromRGBO(0, 86, 255,
                                1); // Üzerine gelindiğinde yazı rengi mavi olacak
                          }
                          return Colors.white; // Varsayılan yazı rengi
                        },
                      ),
                    ),
                    child: const Text(
                      "Griş Yap",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  'Sıkça Sorulan Sorular',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 300),
                  child: FadeInUpWidget(
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ExpansionTile(
                        title: Text(
                          "Altınlarım nerede tutuluyor?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(
                          Icons.expand_more,
                          color: Colors.white,
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Altınlarınız Kuveyttürk Bankasında 995/1000 saflıkta tutulmaktadır.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 300),
                  child: FadeInUpWidget(
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ExpansionTile(
                        title: Text(
                          "Hesabımda bulunan altınların fiziksel olarak karşılığı var mı?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(
                          Icons.expand_more,
                          color: Colors.white,
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Altınlarınzın fiziksel olarak karşılıkları anlaşmalı olunan bankaların kasalarında güvenli bir şekilde saklanmaktadır.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 300),
                  child: FadeInUpWidget(
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ExpansionTile(
                        title: Text(
                          "eppser'da komisyon oranları kaçtır?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(
                          Icons.expand_more,
                          color: Colors.white,
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Altın ve para işlemlerinde komisyon oranları %0.10 ile %1 arasındadır",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 300),
                  child: FadeInUpWidget(
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ExpansionTile(
                        title: Text(
                          "İşlem sınırı var mı?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(
                          Icons.expand_more,
                          color: Colors.white,
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "eppser'da herhangi bir işlem limiti yoktur.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 300),
                  child: FadeInUpWidget(
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ExpansionTile(
                        title: Text(
                          "eppser Token nedir?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(
                          Icons.expand_more,
                          color: Colors.white,
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "eppser Token, epser'a yatırım yapmanızı ve karına ortak olmanızı sağlayan bir dijtal tokendır. "
                              "Ayrıca eppser Token blockchain tabanlı bir token değildir!",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.black,
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo and Description
                  Center(
                    child: Text(
                      "eppser",
                      style: TextStyle(
                          fontFamily: 'font1',
                          fontSize: 42,
                          color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 24),
                  // Copyright
                  Text(
                    "© 2024 eppser Technology - Tüm Hakları Saklıdır",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
