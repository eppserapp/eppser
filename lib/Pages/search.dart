import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/profile.dart';
import 'package:eppser/providers/themeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class searchPage extends StatefulWidget {
  const searchPage({super.key});

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  var searchResult;
  late BannerAd myBanner;
  var provider;

  @override
  void initState() {
    myBanner = BannerAd(
        size: AdSize.banner,
        adUnitId: "ca-app-pub-3940256099942544/6300978111",
        listener: const BannerAdListener(),
        request: const AdRequest());
    myBanner.load();
    super.initState();
  }

  String value = "";
  void searchFromFirebase(String query) async {
    final result = await FirebaseFirestore.instance
        .collection('Users')
        .where('searchname', isGreaterThanOrEqualTo: query)
        .limit(50)
        .get();

    setState(() {
      searchResult = result.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    provider = Provider.of<themeProvider>(context, listen: true).theme;
    return Scaffold(
      backgroundColor: provider == true ? Colors.white : Colors.black,
      body: Column(
        children: [
          Container(
            height: 170,
            decoration: const BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/background.png',
                  ),
                  fit: BoxFit.cover,
                )),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "eppser",
                      style: TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                          fontFamily: 'font1'),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    onChanged: (val) {
                      searchFromFirebase(val.toLowerCase());
                      value = val;
                    },
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        focusColor: Colors.white,
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        hintText: "Ara",
                        hintStyle: const TextStyle(color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Iconsax.search_normal,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        suffixIconColor: Colors.white),
                  )
                ],
              ),
            ),
          ),
          value.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                  itemCount: searchResult.length,
                  itemBuilder: (context, index) {
                    return searchResult[index]['uid'] !=
                            FirebaseAuth.instance.currentUser!.uid
                        ? Column(
                            children: [
                              InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => profilePage(
                                      uid: searchResult[index]['uid'],
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(70 * 0.4)),
                                        child: Image.network(
                                          searchResult[index]['profImage'],
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          searchResult[index]['name'],
                                          style: TextStyle(
                                              color: provider == true
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              searchResult[index]['surname'],
                                              style: TextStyle(
                                                  color: provider == true
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            searchResult[index]['tick']
                                                ? const Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 5, left: 2),
                                                    child: Icon(
                                                      Iconsax.verify5,
                                                      color: Color.fromRGBO(
                                                          0, 86, 255, 1),
                                                      size: 20,
                                                    ),
                                                  )
                                                : const SizedBox()
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (index == searchResult.length - 1)
                                const SizedBox(height: 80)
                            ],
                          )
                        : const SizedBox();
                  },
                ))
              : const SizedBox(),
        ],
      ),
    );
  }
}
