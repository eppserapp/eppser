import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class MyMessageCard extends StatefulWidget {
  final String message;
  final Timestamp date;
  final bool isSeen;
  final snap;

  const MyMessageCard(
      {Key? key,
      required this.message,
      required this.date,
      required this.isSeen,
      required this.snap})
      : super(key: key);

  @override
  State<MyMessageCard> createState() => _MyMessageCardState();
}

class _MyMessageCardState extends State<MyMessageCard> {
  late DateFormat timeFormat;
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    timeFormat = DateFormat.Hm('tr');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 0),
              child: Icon(
                Iconsax.tick_circle5,
                color: widget.snap['isSeen']
                    ? const Color.fromRGBO(0, 86, 255, 1)
                    : Colors.white,
                size: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Icon(
                Iconsax.tick_circle5,
                color: widget.snap['isSeen']
                    ? const Color.fromRGBO(0, 86, 255, 1)
                    : Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        GestureDetector(
          onLongPress: () {
            showDialog(
              useRootNavigator: false,
              context: context,
              builder: (context) {
                return Dialog(
                  child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shrinkWrap: true,
                      children: [
                        'Sil',
                      ]
                          .map(
                            (e) => InkWell(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  child: Text(e),
                                ),
                                onTap: () async {
                                  await FireStoreMethods().deleteMessage(
                                      widget.snap['messageId'],
                                      widget.snap['recieverId'],
                                      widget.snap['senderId']);
                                  // ignore: use_build_context_synchronously
                                  showSnackBar(
                                    context,
                                    'Mesaj Silindi!',
                                  );

                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pop();
                                }),
                          )
                          .toList()),
                );
              },
            );
          },
          child: SizedBox(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 45,
              ),
              child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Column(
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            timeFormat.format(widget.date.toDate()),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
