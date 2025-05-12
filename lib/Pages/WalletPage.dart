import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:eppser/Pages/AccountTransactionsPage.dart';
import 'package:eppser/Pages/BuyPage.dart';
import 'package:eppser/Pages/BuyTokenPage.dart';
import 'package:eppser/Pages/MoneyTransfersPage.dart';
import 'package:eppser/Pages/NotificationsPage.dart';
import 'package:eppser/Providers/themeProvider.dart';
import 'package:eppser/Theme/Theme.dart';
import 'package:eppser/Widgets/BankDetailsDialog.dart';
import 'package:eppser/Widgets/WithdrawIbanDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:marqueer/marqueer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final String apiUrl = 'https://finans.truncgil.com/today.json';
  Map<String, dynamic>? userData;
  var accountData;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      accountSubscription;
  bool _isLoading = false;
  var ApiData;
  Timer? _timer;
  var myGroup = AutoSizeGroup();
  String? selectedValue;
  var goldTl;

  List<DropdownMenuItem<String>> get dropdownItems {
    return [
      DropdownMenuItem(
        value: 'Türk Lirası',
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                'assets/svg/tr.png',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Türk Lirası'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'Altın',
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/svg/xau.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text('Altın'),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'eppser Token',
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                'assets/images/eppser.png',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Text('eppser Token'),
          ],
        ),
      ),
    ];
  }

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(userId)) {
      final data = prefs.getString(userId);
      if (data != null) {
        return Map<String, dynamic>.from(
            jsonDecode(data) as Map<String, dynamic>);
      }
    }
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      if (userData != null) {
        await prefs.setString(userId, jsonEncode(userData));
        return userData;
      }
    }
    return null;
  }

  void fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      setState(() {
        userData = snapshot.data();
        _isLoading = false;
      });
    }
  }

  void fetchAccountAndTransactionData() {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      accountSubscription = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Account')
          .doc('wallet')
          .snapshots()
          .listen((snapshot) {
        setState(() {
          if (snapshot.exists) {
            accountData = snapshot.data();
            goldTl = accountData['gold'];
          }
        });
      });

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> apiData() async {
    final response = await Dio().get(apiUrl);

    if (response.statusCode == 200) {
      setState(() {
        ApiData = response.data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedValue = "Türk Lirası";
    apiData();
    fetchUserData();
    fetchAccountAndTransactionData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    accountSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          )
        : Scaffold(
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
                          fontFamily: 'font1',
                          fontSize: 38,
                          color: Colors.white),
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
                      Consumer<ThemeProvider>(
                              builder: (context, provider, child) {
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
                      })
                          .animate()
                          .fadeIn()
                          .move(delay: 300.ms, duration: 600.ms),
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
                      )
                          .animate()
                          .fadeIn()
                          .move(delay: 500.ms, duration: 600.ms),
                    ],
                  )
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ApiData == null
                      ? const SizedBox()
                      : Center(
                          child: Container(
                            height: 50.0,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: Marqueer(
                              interaction: false,
                              pps: 50,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '₺${ApiData["gram-altin"]["Alış"]}',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                        fontSize: 20.0),
                                  ),
                                  const SizedBox(width: 20),
                                  Image.asset(
                                    'assets/svg/usd.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '₺${ApiData["USD"]["Alış"]}',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                        fontSize: 20.0),
                                  ),
                                  const SizedBox(width: 20),
                                  SvgPicture.asset(
                                    'assets/svg/xau.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${ApiData["ons"]["Alış"]}',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                        fontSize: 20.0),
                                  ),
                                  const SizedBox(width: 20),
                                  Image.asset(
                                    'assets/svg/eur.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '₺${ApiData["EUR"]["Alış"]}',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                        fontSize: 20.0),
                                  ),
                                  const SizedBox(width: 20),
                                  Image.asset(
                                    'assets/svg/gbp.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '₺${ApiData["GBP"]["Alış"]}',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                        fontSize: 20.0),
                                  ),
                                  const SizedBox(width: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/moneybackground.jpg'),
                                fit: BoxFit.cover),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: AutoSizeText(
                                                '₺',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                presetFontSizes: const [
                                                  48,
                                                  38,
                                                  28,
                                                  18,
                                                  8
                                                ],
                                                overflow: TextOverflow.ellipsis,
                                                group: myGroup,
                                              )
                                                  .animate()
                                                  .move(
                                                      delay: 500.ms,
                                                      duration: 600.ms)
                                                  .shake(),
                                            ),
                                            WidgetSpan(
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    60,
                                                child: AutoSizeText(
                                                  selectedValue == 'Türk Lirası'
                                                      ? NumberFormat(
                                                              "#,###.##", "en_US")
                                                          .format(
                                                              accountData['tl'])
                                                      : selectedValue == 'Altın'
                                                          ? NumberFormat(
                                                                  "#,###.##", "en_US")
                                                              .format(double.parse(ApiData["gram-altin"]["Alış"]
                                                                      .replaceAll(
                                                                          '.', '')
                                                                      .replaceAll(
                                                                          ',', '.')) *
                                                                  accountData[
                                                                      'gold'])
                                                          : NumberFormat(
                                                                  "#,###.##",
                                                                  "en_US")
                                                              .format(accountData['token']),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  presetFontSizes: const [
                                                    48,
                                                    38,
                                                    28,
                                                    18,
                                                  ],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  group: myGroup,
                                                ),
                                              ),
                                            ),
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
                      ),
                      Center(
                        child: Container(
                          width: selectedValue == "Türk Lirası"
                              ? 160
                              : selectedValue == "eppser Token"
                                  ? 180
                                  : 120,
                          height: 40,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedValue,
                              menuWidth: 180,
                              isExpanded: true,
                              icon: Icon(Iconsax.arrow_down_1,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                              iconSize: 24,
                              elevation: 16,
                              dropdownColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                  fontSize: 16),
                              borderRadius: BorderRadius.circular(24),
                              items: dropdownItems.toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValue = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 140),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              // onTap: () => showDialog(
                              //   context: context,
                              //   builder: (context) => BankDetailsDialog(),
                              // ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Bilgilendirme',
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color),
                                      ),
                                      content: Text(
                                        'Uygulama şu anlık test aşamasında olduğundan bu özellik kullanılamıyor.',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Tamam',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60 * 0.4),
                                          color: Colors.green),
                                      child: const Icon(
                                        Iconsax.add_circle,
                                        size: 34,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ).animate().fadeIn().move(
                                  begin: const Offset(0, 10),
                                  delay: 400.ms,
                                  duration: 600.ms),
                            ),
                            InkWell(
                              // onTap: () => showDialog(
                              //     context: context,
                              //     builder: (context) => WithdrawIbanDialog()),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Bilgilendirme',
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color),
                                      ),
                                      content: Text(
                                        'Uygulama şu anlık test aşamasında olduğundan bu özellik kullanılamıyor.',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Tamam',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60 * 0.4),
                                          color: Colors.red),
                                      child: const Icon(
                                        Iconsax.minus_cirlce,
                                        size: 34,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ).animate().fadeIn().move(
                                  begin: const Offset(0, 10),
                                  delay: 500.ms,
                                  duration: 600.ms),
                            ),
                            InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MoneyTransfersPage(),
                                  )),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60 * 0.4),
                                          color: const Color.fromRGBO(
                                              0, 86, 255, 1)),
                                      child: const Icon(
                                        Iconsax.arrange_circle_2,
                                        size: 34,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ).animate().fadeIn().move(
                                  begin: const Offset(0, 10),
                                  delay: 600.ms,
                                  duration: 600.ms),
                            ),
                            InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AccountTransactionsPage(),
                                  )),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60 * 0.4),
                                          color: Colors.black),
                                      child: const Icon(
                                        Iconsax.archive,
                                        size: 34,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ).animate().fadeIn().move(
                                  begin: const Offset(0, 10),
                                  delay: 700.ms,
                                  duration: 600.ms),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            'Son İşlemler',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 15,
                            ),
                          ).animate().move(
                                duration: 500.ms,
                                begin: const Offset(-20, 0),
                                end: Offset.zero,
                                curve: Curves.easeOut,
                              ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Iconsax.arrow_right_1,
                            size: 15,
                          ).animate().move(
                                duration: 500.ms,
                                begin: const Offset(-20, 0),
                                end: Offset.zero,
                                curve: Curves.easeOut,
                              ),
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .collection('TransactionHistory')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: SizedBox(
                            height: 300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.archive,
                                  color: Colors.grey,
                                  size: 100,
                                ),
                                Text(
                                  'Hesap Geçmişi Boş!',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 20),
                                )
                              ],
                            ),
                          ));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: SizedBox(
                            height: 300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.archive,
                                  color: Colors.grey,
                                  size: 100,
                                ),
                                Text(
                                  'Hesap Geçmişi Boş!',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 20),
                                )
                              ],
                            ),
                          ));
                        }

                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AccountTransactionsPage(),
                              )),
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length > 5
                                ? 5
                                : snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder(
                                  future: getUserInfo(snapshot.data?.docs[index]
                                      .data()['userId']),
                                  builder: (context, userSnapshot) {
                                    if (!userSnapshot.hasData) {
                                      return const Center(
                                          child: SizedBox(
                                        height: 300,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Iconsax.archive,
                                              color: Colors.grey,
                                              size: 100,
                                            ),
                                            Text(
                                              'Hesap Geçmişi Boş!',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 20),
                                            )
                                          ],
                                        ),
                                      ));
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        right: 10,
                                        top: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: userSnapshot.data?[
                                                            'profImage'] ==
                                                        null
                                                    ? Container(
                                                        height: 70,
                                                        width: 70,
                                                        decoration: BoxDecoration(
                                                            color: const Color
                                                                .fromRGBO(
                                                                0, 86, 255, 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(70 *
                                                                        0.4)),
                                                        child: const Icon(
                                                          Iconsax.user,
                                                          color: Colors.white,
                                                          size: 50,
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    70 * 0.4),
                                                        child: SizedBox(
                                                          height: 70,
                                                          width: 70,
                                                          child:
                                                              CachedNetworkImage(
                                                            placeholderFadeInDuration:
                                                                const Duration(
                                                                    microseconds:
                                                                        1),
                                                            fadeOutDuration:
                                                                const Duration(
                                                                    microseconds:
                                                                        1),
                                                            fadeInDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        1),
                                                            imageUrl:
                                                                userSnapshot
                                                                        .data?[
                                                                    'profImage'],
                                                            fit: BoxFit.cover,
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(
                                                                    Icons.error,
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              200,
                                                        ),
                                                        child: Text(
                                                          userSnapshot.data?[
                                                                  'name'] +
                                                              " " +
                                                              userSnapshot
                                                                      .data?[
                                                                  'surname'],
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.color,
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              200,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              snapshot
                                                                          .data
                                                                          ?.docs[
                                                                              index]
                                                                          .data()['isGold'] ==
                                                                      false
                                                                  ? 'Para Transferi'
                                                                  : 'Altın Transferi',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.color,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: NumberFormat(
                                                                  "#,###.##",
                                                                  "en_US")
                                                              .format(snapshot
                                                                      .data
                                                                      ?.docs[index]
                                                                      .data()[
                                                                  'amount'])
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: snapshot
                                                                            .data
                                                                            ?.docs[
                                                                                index]
                                                                            .data()[
                                                                        'userId'] ==
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid
                                                                ? Colors.red
                                                                : Colors.green,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        if (snapshot.data
                                                                    ?.docs[index]
                                                                    .data()[
                                                                'isGold'] ==
                                                            true)
                                                          TextSpan(
                                                            text: ' gr',
                                                            style: TextStyle(
                                                              color: snapshot.data?.docs[index]
                                                                              .data()[
                                                                          'userId'] ==
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        if (snapshot.data
                                                                    ?.docs[index]
                                                                    .data()[
                                                                'isGold'] ==
                                                            false)
                                                          TextSpan(
                                                            text: ' ₺',
                                                            style: TextStyle(
                                                              color: snapshot.data?.docs[index]
                                                                              .data()[
                                                                          'userId'] ==
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 3),
                                                child: Text(
                                                  DateFormat.yMd('tr_TR')
                                                      .format(
                                                    (snapshot.data?.docs[index]
                                                                    .data()[
                                                                'timestamp']
                                                            as Timestamp)
                                                        .toDate(),
                                                  ),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ).animate().move(
                                          duration: 500.ms,
                                          begin: const Offset(-20, 0),
                                          end: Offset.zero,
                                          curve: Curves.easeOut,
                                        );
                                  });
                            },
                          ),
                        );
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuyPage(),
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/goldbackground.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: GestureDetector(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    overflow: TextOverflow.fade,
                                    "Toplam Varlıklarım",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    child: Column(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: goldTl.toStringAsFixed(4),
                                                style: const TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 70,
                                                  fontWeight: FontWeight.bold,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const TextSpan(
                                                text: ' gr.',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 34,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  ApiData == null
                                      ? const SizedBox()
                                      : AnimatedFlipCounter(
                                          decimalSeparator: '.',
                                          thousandSeparator: ',',
                                          prefix: '₺',
                                          fractionDigits: 2,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          value: double.parse(
                                                  ApiData["gram-altin"]["Alış"]
                                                      .replaceAll('.', '')
                                                      .replaceAll(',', '.')) *
                                              accountData['gold'],
                                          textStyle: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn().move(delay: 500.ms, duration: 600.ms),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/cardbackground.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: GestureDetector(
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      child: Text(
                                        'eppser Card',
                                        maxLines: 3,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      overflow: TextOverflow.fade,
                                      "eppser kart ile ödemelerini altın olarak yap",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn()
                          .move(delay: 500.ms, duration: 600.ms),
                      Positioned(
                          top: 10,
                          right: 20,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            height: 30,
                            width: 70,
                            child: const Center(
                              child: Text(
                                'Yakında',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuyTokenPage(),
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/tokenbackground.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  child: Text(
                                    'eppser Token',
                                    maxLines: 3,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  overflow: TextOverflow.fade,
                                  "eppser'a Ortak Ol",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn().move(delay: 500.ms, duration: 600.ms),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(
                            'https://medium.com/@ylcn1777/goldisrealmoney-hareketi-nedir-77c0807f2c65');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          throw 'Link açılamıyor: $url';
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/dollarbackground.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: GestureDetector(
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: Text(
                                      '#goldisrealmoney',
                                      maxLines: 3,
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn().move(delay: 500.ms, duration: 600.ms),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
  }
}
