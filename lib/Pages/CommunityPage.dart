import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/CommunityView.dart';
import 'package:eppser/Pages/CreateGroup.dart';
import 'package:eppser/Pages/GroupChat.dart';
import 'package:eppser/Widgets/GroupCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({
    super.key,
    required this.communityId,
  });
  final String communityId;

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
            delegate: CommunityHeaderDelegate(
              communityId: widget.communityId,
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Community')
                  .doc(widget.communityId)
                  .collection('Groups')
                  .orderBy('date', descending: false)
                  .snapshots(),
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
                                groupId: groupData['groupId'],
                                communityId: widget.communityId,
                              ),
                            ),
                          ),
                          child: GroupCard(
                            groupId: groupData['groupId'],
                            communityId: widget.communityId,
                          ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Community')
            .doc(widget.communityId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final communityData = snapshot.data!.data() as Map<String, dynamic>;
            final members = communityData['members'] ?? [];
            if (members.contains(FirebaseAuth.instance.currentUser!.uid)) {
              return const SizedBox.shrink();
            }
            return InkWell(
              onTap: () {
                FirebaseFirestore.instance
                    .collection('Community')
                    .doc(widget.communityId)
                    .update({
                  'members': FieldValue.arrayUnion(
                      [FirebaseAuth.instance.currentUser!.uid])
                });
                setState(() {});
              },
              child: Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 86, 255, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    'Katıl',
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// Özel başlık için SliverPersistentHeaderDelegate tanımlıyoruz
class CommunityHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String communityId;
  const CommunityHeaderDelegate({required this.communityId});

  @override
  double get minExtent => 70; // Başlık küçüldüğündeki minimum yükseklik

  @override
  double get maxExtent =>
      120; // Başlık tamamen açıldığındaki maksimum yükseklik

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Kaydırma oranını hesapla (0.0 - 1.0 arası)
    final double progress =
        (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Community')
          .doc(communityId)
          .snapshots(),
      builder: (context, communitySnapshot) {
        if (!communitySnapshot.hasData) {
          // Placeholder while the community data is loading
          return Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/moneybackground.jpg',
                fit: BoxFit.cover,
              ),
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
              Positioned(
                top: 20,
                right: 10,
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CreateGroup(
                        communityId: communityId,
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.add, color: Colors.white),
                ),
              ),
              Positioned(
                top: 20,
                right: 40,
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CommunityView(
                        snap: communityId,
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.info_circle, color: Colors.white),
                ),
              ),
            ],
          );
        }

        final communityData =
            communitySnapshot.data!.data() as Map<String, dynamic>;
        var communityName = communityData['name'] ?? 'Community Name';
        var description = communityData['about'] ?? '';
        var coverImage = communityData['imageUrl'];
        var profileImage = communityData['photoUrl'];

        return Stack(
          clipBehavior: Clip.none, // Çocuk widget'ların taşmasına izin ver
          fit: StackFit.expand,
          children: [
            coverImage != null
                ? Image.network(
                    coverImage,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/moneybackground.jpg',
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
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        communityName,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // Yeni grup oluşturma butonu
            Positioned(
              top: 20,
              right: 50,
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CreateGroup(
                      communityId: communityId,
                    ),
                  );
                },
                icon: const Icon(
                  Iconsax.add_circle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 10,
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CommunityView(
                      snap: communityId,
                    ),
                  );
                },
                icon: const Icon(
                  Iconsax.info_circle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 1 - progress,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    profileImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100 * 0.4),
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: CachedNetworkImage(
                                placeholderFadeInDuration:
                                    const Duration(microseconds: 1),
                                fadeOutDuration:
                                    const Duration(microseconds: 1),
                                fadeInDuration: const Duration(milliseconds: 1),
                                imageUrl: profileImage,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error,
                                        color: Colors.black),
                              ),
                            ),
                          )
                        : Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                color: const Color.fromRGBO(0, 86, 255, 1),
                                borderRadius: BorderRadius.circular(100 * 0.4)),
                            child: const Icon(
                              Iconsax.people,
                              color: Colors.white,
                              size: 70,
                            ),
                          ),
                    const SizedBox(height: 8),
                    Text(
                      communityName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
