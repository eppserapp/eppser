import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class sendMessageCard extends StatefulWidget {
  final String message;
  final Timestamp date;
  final snap;

  const sendMessageCard(
      {Key? key, required this.message, required this.date, required this.snap})
      : super(key: key);

  @override
  State<sendMessageCard> createState() => _sendMessageCardState();
}

class _sendMessageCardState extends State<sendMessageCard> {
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 45,
            ),
            child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: Colors.black,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: Column(
                    children: [
                      Text(
                        widget.message,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          timeFormat.format(widget.date.toDate()),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ],
    );
  }
}
