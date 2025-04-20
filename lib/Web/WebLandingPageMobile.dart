import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eppser/Web/AboutPageMobile.dart';
import 'package:eppser/Web/ContactPageMobile.dart';
import 'package:eppser/Web/FAQPageMobile.dart';
import 'package:eppser/Widgets/FadeInUp.dart';
import 'package:flutter/material.dart';

class WebLandingPageMobile extends StatefulWidget {
  const WebLandingPageMobile({super.key});

  @override
  State<WebLandingPageMobile> createState() => _WebLandingPageMobileState();
}

class _WebLandingPageMobileState extends State<WebLandingPageMobile> {
  bool menuButton = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 700,
            toolbarHeight: 70,
            backgroundColor: Colors.black,
            pinned: true,
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
                            fontFamily: 'font1',
                            fontSize: 42,
                            color: Colors.amber),
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
                    const PopupMenuItem(
                        child: Text(
                      "Ana Sayfa",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
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
                    PopupMenuItem(
                        child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FAQPageMobile(),
                          )),
                      child: const Text(
                        "SSS",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ))
                  ];
                },
              ),
              const SizedBox(
                width: 12,
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/background2.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width - 20,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const FadeInUpWidget(
                                  child: Text(
                                    "Yatırımlarınızı güvenle yönetin!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                const FadeInUpWidget(
                                  child: Text(
                                    "Anında altın alıp satmak için şimdi harekete geçin. "
                                    "Piyasa hareketlerinden anında haberdar olun, "
                                    "altın işlemlerinizde avantajlı komisyon oranlarından yararlanın. "
                                    "Bugün kazanmaya başlayın!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                FadeInUpWidget(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(0, 86, 255, 1),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 28, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ).copyWith(
                                      backgroundColor: WidgetStateProperty
                                          .resolveWith<Color>(
                                        (Set<WidgetState> states) {
                                          if (states
                                              .contains(WidgetState.hovered)) {
                                            return Colors
                                                .white; // Üzerine gelindiğinde beyaz olacak
                                          }
                                          return const Color.fromRGBO(
                                              0, 86, 255, 1); // Varsayılan renk
                                        },
                                      ),
                                      foregroundColor: WidgetStateProperty
                                          .resolveWith<Color>(
                                        (Set<WidgetState> states) {
                                          if (states
                                              .contains(WidgetState.hovered)) {
                                            return const Color.fromRGBO(
                                                0,
                                                86,
                                                255,
                                                1); // Üzerine gelindiğinde yazı rengi mavi olacak
                                          }
                                          return Colors
                                              .white; // Varsayılan yazı rengi
                                        },
                                      ),
                                    ),
                                    child: const Text(
                                      "Giriş Yap",
                                      style: TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // launchUrl(Uri.parse(
                                    //     "https://play.google.com/store/apps/details?id=com.eppser.app&hl=tr&gl=US"));
                                  },
                                  child: FadeInUpWidget(
                                    child: Container(
                                      height: 100,
                                      width: 200,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/svg/googleplay.png'),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeInUpWidget(
              child: Padding(
                padding: const EdgeInsets.symmetric(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: NetworkImage(
                                    'https://images.unsplash.com/photo-1673905106456-08b002f6bb2b?q=80&w=1936&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Düşük Komisyon ile Altın Al-Sat",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "eppser ile altın alım satım işlemlerini en düşük komisyon oranları ile gerçekleştirin. "
                                "Piyasa hareketlerine hızlıca erişim sağlayın ve yatırım fırsatlarını kaçırmayın.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeInUpWidget(
              child: Padding(
                padding: const EdgeInsets.symmetric(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: NetworkImage(
                                    'https://images.unsplash.com/photo-1623118176083-897933d9977f?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "eppser Token",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "eppser token sahipleri, eppser'ın karına ortak olma fırsatını yakalar. "
                                "Token sahipliği, size daha fazla kazanç sağlar ve geleceğin finans dünyasında yerinizi almanızı sağlar.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeInUpWidget(
              child: Padding(
                padding: const EdgeInsets.symmetric(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: NetworkImage(
                                    'https://images.unsplash.com/photo-1571867424488-4565932edb41?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Kolayca TL ve Altın Gönderin",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "eppser ile anında TL veya altın gönderebilirsiniz. "
                                "Güvenli ve hızlı transferlerle para ve altın göndermek hiç bu kadar kolay olmamıştı.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeInUpWidget(
              child: Padding(
                padding: const EdgeInsets.symmetric(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: NetworkImage(
                                    'https://images.unsplash.com/photo-1569060368681-889a62a8f416?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "#goldisrealmoney",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "#goldisrealmoney hareketi, altının gerçek ve kalıcı bir değer ölçüsü olduğunu savunan bir inisiyatiftir. Bu hareket, altın standardının önemini vurgulayarak, para birimlerinin güvenilir ve istikrarlı bir temel üzerine oturması gerektiğini savunur. Modern ekonomik sistemlerin karşı karşıya olduğu enflasyon, para birimi değer kaybı gibi sorunlara dikkat çekerek, altının evrensel bir değer saklama aracı ve değişim aracı olarak yeniden kabul edilmesi gerektiğini öne sürer. Altın, tarih boyunca zenginlik ve güvenin sembolü olmuştur; bu nedenle, #goldisrealmoney hareketi, altının finansal sistemdeki yerini yeniden kazanması için toplumsal bilinci artırmayı amaçlamaktadır.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
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
          ),
        ],
      ),
    );
  }
}
