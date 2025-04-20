import 'dart:ui';
import 'package:eppser/Pages/StoryPage.dart';
import 'package:eppser/Pages/addStory.dart';
import 'package:eppser/Widgets/storyCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  bool isLoading = false;
  int chunkIndex = 0;
  List following = [];
  String profImage = "";

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      following = userSnap.data()?['following'];
      profImage = userSnap.data()?['profImage'];
      following.add(FirebaseAuth.instance.currentUser!.uid);

      setState(() {});
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  int chunkSize = 10;
  List<List<dynamic>> get chunks {
    following.add(FirebaseAuth.instance.currentUser!.uid);
    List<dynamic> myList = following;
    return List.generate(
      (myList.length / chunkSize).ceil(),
      (i) => myList.sublist(
          i * chunkSize,
          (i + 1) * chunkSize < myList.length
              ? (i + 1) * chunkSize
              : myList.length),
    );
  }

  Stream<QuerySnapshot> getStoriesStream(List<dynamic> chunk) {
    if (chunk.isEmpty) {
      return Stream<QuerySnapshot>.empty();
    }
    return FirebaseFirestore.instance
        .collection('Story')
        .where('uid', whereIn: chunk)
        .orderBy('datePublished', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.black,
          expandedHeight: 180,
          pinned: true,
          centerTitle: false,
          title: const Text(
            "Timeline",
            style: TextStyle(
                fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                      image: AssetImage(
                        'assets/images/background.jpg',
                      ),
                      fit: BoxFit.cover)),
              child: Stack(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: getStoriesStream(chunks[chunkIndex]),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      } else {
                        //unique uid
                        var list = [];
                        snapshot.data?.docs.forEach((element) {
                          if (element.data() is Map) {
                            list.addAll([(element.data() as Map)['uid']]);
                          }
                        });

                        var data = list.toSet().toList();
                        bool data2 = data
                            .contains(FirebaseAuth.instance.currentUser!.uid);

                        return ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: data.isEmpty ? 1 : data.length,
                          itemBuilder: (contex, index) {
                            if (index >= 10 && index % 10 == 0) {
                              chunkIndex++;
                            }
                            bool isSeen = true;
                            if (data.isNotEmpty) {
                              for (var i = 0; i < list.length + 1; i++) {
                                var index = i == list.length ? i - 1 : i;
                                var a = (snapshot.data!.docs[index].data()
                                        as Map<String, dynamic>)['isSeen']
                                    .contains(
                                        FirebaseAuth.instance.currentUser!.uid);
                                if (!a) {
                                  isSeen = false;
                                  break;
                                }
                              }
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (index == 0)
                                  GestureDetector(
                                    onTap: (() => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => data2
                                                ? StoryPage(
                                                    uid: FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                  )
                                                : const addStoryPage()))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 80),
                                      child: Column(
                                        children: [
                                          data2
                                              ? Container(
                                                  width: 85,
                                                  height: 85,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              profImage),
                                                          fit: BoxFit.cover),
                                                      border: Border.all(
                                                          color: const Color
                                                              .fromRGBO(
                                                              0, 86, 255, 1),
                                                          width: 3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              85 * 0.4)),
                                                )
                                              : Container(
                                                  width: 85,
                                                  height: 85,
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              85 * 0.4)),
                                                  child: const Icon(
                                                    Iconsax.add,
                                                    color: Colors.white,
                                                    size: 40,
                                                  ),
                                                ),
                                          Container(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            width: 120,
                                            child: const Center(
                                              child: Text(
                                                "Hikayen",
                                                maxLines: 2,
                                                softWrap: false,
                                                style: TextStyle(
                                                    fontFamily: 'font2',
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    overflow:
                                                        TextOverflow.fade),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if (index == 0)
                                  Column(
                                    children: [
                                      const SizedBox(
                                        height: 100,
                                      ),
                                      Container(
                                        width: 3,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ],
                                  ),
                                if (data.isNotEmpty &&
                                    data[index] !=
                                        FirebaseAuth.instance.currentUser!.uid)
                                  storyCard(
                                    isSeen: isSeen,
                                    uid: data,
                                    index: index,
                                  ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // SliverAppBar'dan sonra etkinlikler başlığı ve kartları ekleniyor
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Icon(
                      Iconsax.calendar_1,
                      size: 28,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Etkinlikler",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Etkinlikler ListView.builder ile
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  // Örnek etkinlik verileri
                  final etkinlikler = [
                    {
                      "image":
                          "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80",
                      "avatar":
                          "https://randomuser.me/api/portraits/men/32.jpg",
                      "title": "Doğa Yürüyüşü",
                      "desc":
                          "Şehrin stresinden uzaklaşmak için doğa yürüyüşüne katıl! Katılım ücretsizdir.",
                      "date": "12 Mayıs"
                    },
                    {
                      "image":
                          "https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80",
                      "avatar":
                          "https://randomuser.me/api/portraits/women/44.jpg",
                      "title": "Teknoloji Semineri",
                      "desc":
                          "Yapay zeka ve yazılım dünyasındaki son gelişmeleri konuşuyoruz. Herkes davetlidir.",
                      "date": "20 Mayıs"
                    },
                    {
                      "image":
                          "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80",
                      "avatar":
                          "https://randomuser.me/api/portraits/men/45.jpg",
                      "title": "Kitap Kulübü",
                      "desc":
                          "Bu ayın kitabını tartışmak için buluşuyoruz. Katılım herkese açık.",
                      "date": "25 Mayıs"
                    },
                    {
                      "image":
                          "https://images.unsplash.com/photo-1503676382389-4809596d5290?auto=format&fit=crop&w=800&q=80",
                      "avatar":
                          "https://randomuser.me/api/portraits/women/65.jpg",
                      "title": "Film Gecesi",
                      "desc": "Açık havada film keyfi! Sandalyeni al gel.",
                      "date": "28 Mayıs"
                    },
                    {
                      "image":
                          "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80",
                      "avatar":
                          "https://randomuser.me/api/portraits/men/12.jpg",
                      "title": "Bisiklet Turu",
                      "desc": "Şehirde bisiklet turu. Kaskını unutma!",
                      "date": "2 Haziran"
                    },
                    {
                      "image":
                          "https://images.unsplash.com/photo-1465101178521-c1a9136a3c8b?auto=format&fit=crop&w=800&q=80",
                      "avatar":
                          "https://randomuser.me/api/portraits/women/12.jpg",
                      "title": "Resim Atölyesi",
                      "desc": "Sanatla buluşmak isteyen herkese açık atölye.",
                      "date": "5 Haziran"
                    },
                    {
                      "image":
                          "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80",
                      "avatar":
                          "https://randomuser.me/api/portraits/men/22.jpg",
                      "title": "Gönüllülük Buluşması",
                      "desc":
                          "Topluma katkı sağlamak için bir araya geliyoruz.",
                      "date": "8 Haziran"
                    },
                    {
                      "image":
                          "https://images.unsplash.com/photo-1465101178521-c1a9136a3c8b?auto=format&fit=crop&w=800&q=80",
                      "avatar":
                          "https://randomuser.me/api/portraits/women/22.jpg",
                      "title": "Yoga Sabahı",
                      "desc":
                          "Güne yoga ile başlamak isteyenler için ücretsiz etkinlik.",
                      "date": "10 Haziran"
                    },
                    {
                      "image":
                          "https://images.unsplash.com/photo-1503676382389-4809596d5290?auto=format&fit=crop&w=800&q=80",
                      "avatar":
                          "https://randomuser.me/api/portraits/men/33.jpg",
                      "title": "Kodlama Maratonu",
                      "desc": "24 saatlik kodlama maratonuna hazır mısın?",
                      "date": "15 Haziran"
                    },
                    {
                      "image":
                          "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80",
                      "avatar":
                          "https://randomuser.me/api/portraits/women/33.jpg",
                      "title": "Müzik Dinletisi",
                      "desc":
                          "Canlı müzik performansları ile keyifli bir akşam.",
                      "date": "18 Haziran"
                    },
                  ];
                  final etkinlik = etkinlikler[index % etkinlikler.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: Image.network(
                            etkinlik["image"]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.clock,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  etkinlik["date"]!,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 20,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius:
                                        BorderRadius.circular(80 * 0.4)),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(60 * 0.4),
                                      child: SizedBox(
                                        height: 60,
                                        width: 60,
                                        child: Image.network(
                                          etkinlik["avatar"]!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.error,
                                                      color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          etkinlik["title"]!,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          etkinlik["desc"]!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                              fontSize: 10),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
