import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eppser/Web/AboutPageMobile.dart';
import 'package:eppser/Web/ContactPageMobile.dart';
import 'package:eppser/Web/WebLandingPageMobile.dart';
import 'package:eppser/Widgets/FadeInUp.dart';
import 'package:flutter/material.dart';

class FAQPageMobile extends StatefulWidget {
  const FAQPageMobile({super.key});

  @override
  State<FAQPageMobile> createState() => _FAQPageMobileState();
}

class _FAQPageMobileState extends State<FAQPageMobile> {
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
          ],
        ),
        actions: [
          PopupMenuButton(
            icon: Image.asset('assets/icons/menu.png'),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WebLandingPageMobile(),
                      )),
                  child: const Text(
                    "Ana Sayfa",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                )),
                PopupMenuItem(
                    child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPageMobile(),
                      )),
                  child: const Text(
                    "Hakkımızda",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                )),
                PopupMenuItem(
                    child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactPageMobile(),
                      )),
                  child: const Text(
                    "İletişim",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                )),
                const PopupMenuItem(
                  child: Text(
                    "SSS",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ];
            },
          ),
          const SizedBox(
            width: 12,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
