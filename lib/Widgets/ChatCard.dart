import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eppser/Database/Message.dart';
import 'package:eppser/Database/Users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({
    super.key,
    required this.snap,
  });
  final snap;
  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  var userData;
  var message;
  String name = "";
  bool isLoading = false;
  bool tick = false;

  @override
  void initState() {
    super.initState();
    dataHive();
  }

  dataHive() {
    userData = UserBox.getUserData(widget.snap);
    if (message = MessageBox.getMessage(widget.snap) != null) {
      message = MessageBox.getMessage(widget.snap);
    } else {
      message = null;
    }
    if (userData != null) {
      name = userData['name'] + " " + userData['surname'];
      tick = userData['tick'];
    }
  }

  String getFileTypeOfLastUrl(List<dynamic> urls) {
    // Dosya uzantılarını belirleyelim
    List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    List<String> videoExtensions = ['mp4', 'avi', 'mov', 'wmv'];
    List<String> documentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

    // Listedeki son URL'yi alalım
    String lastUrl = urls.last;

    // URL'deki dosya uzantısını alalım
    String extension = lastUrl.split('.').last.toLowerCase();

    // Dosya türünü kontrol edelim
    if (imageExtensions.contains(extension)) {
      return 'Fotoğraf';
    } else if (videoExtensions.contains(extension)) {
      return 'Video';
    } else if (documentExtensions.contains(extension)) {
      return 'Dosya';
    } else {
      return 'Dosya';
    }
  }

  String getTimeAgo(DateTime dateTime) {
    DateTime localDateTime = dateTime.toLocal();
    DateTime now = DateTime.now().toLocal();

    if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day) {
      // Bugünse sadece saat olarak göster
      return DateFormat.Hm().format(localDateTime);
    } else if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day - 1) {
      // Dünse "Dün" olarak göster
      return "Dün";
    } else {
      // Diğer durumlar için tarih formatını kullan
      return DateFormat.yMd('TR_tr').format(localDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading || userData == null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.70,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(20)),
                            height: 20, // Burada uygun bir yükseklik belirleyin
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.40,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(20)),
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
          )
        : ValueListenableBuilder(
            valueListenable: Hive.box('messageBox').listenable(),
            builder: (context, value, child) {
              dataHive();
              return Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 10,
                  top: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: userData['profimage'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                0, 86, 255, 1),
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: const Icon(
                                          Iconsax.user,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                                      filterQuality: FilterQuality.low,
                                      placeholderFadeInDuration:
                                          const Duration(microseconds: 1),
                                      fadeOutDuration:
                                          const Duration(microseconds: 1),
                                      fadeInDuration:
                                          const Duration(milliseconds: 1),
                                      imageUrl: userData['profimage'],
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error,
                                              color: Colors.black),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      color:
                                          const Color.fromRGBO(0, 86, 255, 1),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: const Icon(
                                    Iconsax.user,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 200,
                                  ),
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                tick
                                    ? const Padding(
                                        padding: EdgeInsets.only(
                                          left: 3,
                                          top: 5,
                                        ),
                                        child: Icon(
                                          Iconsax.verify5,
                                          color: Color.fromRGBO(0, 86, 255, 1),
                                          size: 20,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            if (message != null &&
                                message.values != null &&
                                message.values.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (message.values.last['senderId'] ==
                                          FirebaseAuth
                                              .instance.currentUser?.uid &&
                                      message.values.last['sending'])
                                    const Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Icon(
                                        Iconsax.clock,
                                        color: Colors.grey,
                                        size: 12,
                                      ),
                                    ),
                                  if (message.values.last['senderId'] ==
                                          FirebaseAuth
                                              .instance.currentUser?.uid &&
                                      !message.values.last['sending'])
                                    message.values.last['isSeen']
                                        ? const Padding(
                                            padding: EdgeInsets.only(
                                              right: 3,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Iconsax.tick_circle,
                                                  color: Color.fromRGBO(
                                                      0, 86, 255, 1),
                                                  size: 12,
                                                ),
                                                Icon(
                                                  Iconsax.tick_circle,
                                                  color: Color.fromRGBO(
                                                      0, 86, 255, 1),
                                                  size: 12,
                                                )
                                              ],
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                right: 3, top: 3),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Iconsax.tick_circle,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  size: 12,
                                                ),
                                                Icon(
                                                  Iconsax.tick_circle,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  size: 12,
                                                )
                                              ],
                                            ),
                                          ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              200,
                                    ),
                                    child: Row(
                                      children: [
                                        if (message.values.last['file_urls'] !=
                                                null &&
                                            getFileTypeOfLastUrl(message.values
                                                    .last['file_urls']) ==
                                                'Fotoğraf')
                                          Icon(Iconsax.gallery,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                              size: 14),
                                        if (message.values.last['file_urls'] !=
                                                null &&
                                            getFileTypeOfLastUrl(message.values
                                                    .last['file_urls']) ==
                                                'Video')
                                          Icon(Iconsax.video_circle,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                              size: 14),
                                        if (message.values.last['file_urls'] !=
                                                null &&
                                            getFileTypeOfLastUrl(message.values
                                                    .last['file_urls']) ==
                                                'Dosya')
                                          Icon(Iconsax.document_text,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                              size: 14),
                                        const SizedBox(width: 5),
                                        if (message.values.last['file_urls'] !=
                                            null)
                                          Text(
                                            getFileTypeOfLastUrl(message
                                                .values.last['file_urls']),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                              fontSize: 14,
                                            ),
                                          ),
                                        if (message.values.last['text'] != null)
                                          Text(
                                            message.values.last['text'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Theme.of(context)
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            getTimeAgo(message.values.last['date']),
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (message.values.last['date'] != null)
                          if (message.values
                                  .where((message) =>
                                      message['isSeen'] == false &&
                                      message['recieverId'] ==
                                          FirebaseAuth
                                              .instance.currentUser?.uid)
                                  .length >
                              0)
                            Container(
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(
                                    color: const Color.fromRGBO(0, 86, 255, 1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    message.values
                                        .where((message) =>
                                            message['isSeen'] == false &&
                                            message['recieverId'] ==
                                                FirebaseAuth
                                                    .instance.currentUser?.uid)
                                        .length
                                        .toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                )),
                      ],
                    )
                  ],
                ),
              );
            },
          );
  }
}
