import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/CreateGroup.dart';
import 'package:eppser/Pages/GroupChat.dart';
import 'package:eppser/Widgets/GroupCard.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: CommunityHeaderDelegate(),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Groups').snapshots(),
              builder: (context, snapshot) {
                // Eğer bağlantı bekleme durumundaysa (ilk yükleme vs.)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.04),
                                    width: 70,
                                    height: 70,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.70,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      height: 20,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.40,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.04),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 15,
                    ),
                    itemCount: 7,
                  );
                }
                return Column(
                  children: [
                    const SizedBox(
                      height: 120,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final groupData = snapshot.data!.docs[index].data();
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupChat(
                                snap: groupData['groupId'],
                              ),
                            ),
                          ),
                          child: GroupCard(snap: groupData['groupId']),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Özel başlık için SliverPersistentHeaderDelegate tanımlıyoruz
class CommunityHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 70; // Başlık küçüldüğündeki minimum yükseklik

  @override
  double get maxExtent =>
      140.0; // Başlık tamamen açıldığındaki maksimum yükseklik

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Kaydırma oranını hesapla (0.0 - 1.0 arası)
    final double progress =
        (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return Stack(
      clipBehavior: Clip.none, // Çocuk widget'ların taşmasına izin ver
      fit: StackFit.expand,
      children: [
        // Arka plan resmi
        Image.network(
          'https://cdnuploads.aa.com.tr/uploads/Contents/2018/07/10/thumbs_b_c_66c4535fcc5cc49e96dd7cc6187ddd7f.jpg',
          fit: BoxFit.cover,
        ),
        // AppBar (siyah ve kaydırma ile görünür)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: progress,
            child: Container(
              height: 70,
              color: Colors.transparent,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Gençlik Ve Spor Bakanlığı',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Geri düğmesi
        Positioned(
          top: 20,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        // Yeni grup oluşturma butonu
        Positioned(
          top: 20,
          right: 10,
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CreateGroup(),
              );
            },
            icon: const Icon(Iconsax.add, color: Colors.white),
          ),
        ),
        // Profil fotoğrafı
        // Profil fotoğrafı + Ad + Biyografi (Twitter tarzı)
        Positioned(
          bottom: -160,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 1 - progress,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profil Fotoğrafı
                ClipRRect(
                  borderRadius: BorderRadius.circular(100 * 0.4),
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: CachedNetworkImage(
                      placeholderFadeInDuration:
                          const Duration(microseconds: 1),
                      fadeOutDuration: const Duration(microseconds: 1),
                      fadeInDuration: const Duration(milliseconds: 1),
                      imageUrl:
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAVcWT8y5HNy8sKVKBAq6sTSiGHVBaa2u37w&s',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.black),
                    ),
                  ),
                ),

                Text(
                  'Gençlik Ve Spor Bakanlığı',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),

                Text(
                  '@GSB',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Gençlik projeleriyle ilgilenen aktif bir gönüllü. Yeni insanlarla tanışmayı ve topluluklara katkı sağlamayı sever.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
