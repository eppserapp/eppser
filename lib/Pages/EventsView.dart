import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Widgets/UserCard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventsView extends StatefulWidget {
  final data;
  const EventsView({super.key, required this.data});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlik Detayları'),
      ),
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.data['imageUrl'] != null
              ? Image.network(
                  widget.data['imageUrl'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/images/moneybackground.jpg',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
          const SizedBox(height: 10),
          Text(
            'Etkinlik Adı: ${widget.data['title'] ?? 'N/A'}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.data['eventDate'] != null
                ? 'Tarih: ${DateFormat('dd.MM.yyyy').format((widget.data['eventDate'] as Timestamp).toDate().toLocal())}'
                : "hata",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Açıklama: ${widget.data['description'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          userCard(
            snap: widget.data['createdBy'],
          )
        ],
      )),
    );
  }
}
