import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eppser/Web/ContactPage.dart';
import 'package:eppser/Web/FAQPage.dart';
import 'package:eppser/Web/WebLandingPage.dart';
import 'package:eppser/Widgets/FadeInUp.dart';
import 'package:eppser/Widgets/HoverableText.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
                  InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FAQPage(),
                          )),
                      child: const HoverableText(text: 'SSS')),
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
        child: FadeInUpWidget(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      const Text(
                        "Altın Kadar Sağlam Gelecek",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width - 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white),
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "eppser, finansal özgürlüğünüzü destekleyen, yenilikçi ve kullanıcı dostu bir platformdur. Altın alım-satımı konusunda düşük komisyon oranları sunarak, size en avantajlı ticaret fırsatlarını sağlar. Kullanıcı dostu arayüzümüz sayesinde işlemlerinizi hızlı ve güvenli bir şekilde gerçekleştirebilirsiniz. "
                            "eppser token, platform üzerindeki etkileşimlerinizi ve yatırımlarınızı daha da değerli hale getirir. Şirketin kârından pay alarak, sadece altın ticareti yapmanın ötesinde, uzun vadeli bir değer ortaklığına sahip olursunuz. Ayrıca, TL ya da altın gönderebilme özelliğimiz ile işlemlerinizi kolayca yönetebilirsiniz. "
                            "Vizyonumuz, size en iyi altın ticareti deneyimini sunmak ve finansal hedeflerinize ulaşmanıza yardımcı olmaktır. eppser ile güvenli, şeffaf ve yenilikçi bir yatırım deneyiminin keyfini çıkarın.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(
                    vertical: 24.0, horizontal: 32.0),
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
      ),
    );
  }
}
