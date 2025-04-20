import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            'Bildirimler',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 60,
              ),
              Icon(
                Iconsax.notification,
                size: 100,
                color: Colors.grey[300],
              ),
              Text(
                'Hiç Bildirim Yok!',
                style: TextStyle(color: Colors.grey[300], fontSize: 24),
              )
            ],
          ),
        ));
  }
}
