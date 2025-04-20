import 'package:cached_network_image/cached_network_image.dart';
import 'package:eppser/Pages/CommunityPage.dart';
import 'package:eppser/Pages/NotificationsPage.dart';
import 'package:eppser/Providers/themeProvider.dart';
import 'package:eppser/Theme/Theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: const Text(
                "eppser",
                style: TextStyle(
                    fontFamily: 'font1', fontSize: 38, color: Colors.white),
              ).animate().move(
                    duration: 800.ms,
                    begin: const Offset(-20, 0),
                    end: Offset.zero,
                    curve: Curves.easeOut,
                  ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<ThemeProvider>(builder: (context, provider, child) {
                  return IconButton(
                    onPressed: () async {
                      provider.toggleTheme();
                    },
                    icon: provider.themeData == lightMode
                        ? const Icon(
                            Iconsax.moon,
                            size: 28,
                            color: Colors.white,
                          )
                        : const Icon(
                            Iconsax.sun_1,
                            size: 28,
                            color: Colors.white,
                          ),
                  );
                }).animate().fadeIn().move(delay: 300.ms, duration: 600.ms),
                IconButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ));
                  },
                  icon: const Icon(
                    Iconsax.notification,
                    size: 28,
                    color: Colors.white,
                  ),
                ).animate().fadeIn().move(delay: 500.ms, duration: 600.ms),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Iconsax.profile_2user,
                  size: 28,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                SizedBox(
                  width: 5,
                ),
                Text("Topluluklar",
                    style: GoogleFonts.signika(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 24,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Toplam 10 topluluk olacak
              itemBuilder: (context, index) {
                final communityNames = [
                  "Gençlik ve Spor Bakanlığı",
                  "eppser Technology",
                  "Kültür ve Turizm Derneği",
                  "Eğitim ve Araştırma Vakfı",
                  "Sağlık ve Yaşam Platformu",
                  "Çevre ve Doğa Koruma Grubu",
                  "Bilim ve Teknoloji Kulübü",
                  "Sanat ve Tasarım Topluluğu",
                  "Sosyal Yardımlaşma Derneği",
                  "Spor ve Fitness Kulübü"
                ];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CommunityPage()));
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              // Farklı tasarım çeşidi için index'e göre iki farklı görsel kullanılıyor
                              child: index % 2 == 0
                                  ? Image.network(
                                      'https://cdnuploads.aa.com.tr/uploads/Contents/2018/07/10/thumbs_b_c_66c4535fcc5cc49e96dd7cc6187ddd7f.jpg',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/moneybackground.jpg',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 5,
                            child: Container(
                              width: 70,
                              height: 30,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      "10",
                                      style: GoogleFonts.exo(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Iconsax.profile_2user,
                                      size: 22,
                                      color: Colors.deepOrange,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            left: 10,
                            right: 10,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 20,
                              height: 80,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: SizedBox(
                                        height: 60,
                                        width: 60,
                                        child: index % 2 == 0
                                            ? CachedNetworkImage(
                                                placeholderFadeInDuration:
                                                    const Duration(
                                                        microseconds: 1),
                                                fadeOutDuration: const Duration(
                                                    microseconds: 1),
                                                fadeInDuration: const Duration(
                                                    milliseconds: 1),
                                                imageUrl:
                                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAVcWT8y5HNy8sKVKBAq6sTSiGHVBaa2u37w&s',
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url,
                                                        error) =>
                                                    const Icon(Icons.error,
                                                        color: Colors.black),
                                              )
                                            : CachedNetworkImage(
                                                placeholderFadeInDuration:
                                                    const Duration(
                                                        microseconds: 1),
                                                fadeOutDuration: const Duration(
                                                    microseconds: 1),
                                                fadeInDuration: const Duration(
                                                    milliseconds: 1),
                                                imageUrl:
                                                    'https://play-lh.googleusercontent.com/uBGehMmEy7REdSI3Nr-XFQIKQj0vfziIZfrCobLRDxHB8O7BIl5tdZy4aViTxwnad0I=w480-h960-rw',
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url,
                                                        error) =>
                                                    const Icon(Icons.error,
                                                        color: Colors.black),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          communityNames[
                                              index % communityNames.length],
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla nec purus feugiat, molestie ipsum et, varius dolor.",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                            fontSize: 10,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          height: 3,
                          width: 50,
                          decoration: BoxDecoration(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
