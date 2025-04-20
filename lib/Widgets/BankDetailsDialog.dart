import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BankDetailsDialog extends StatefulWidget {
  @override
  State<BankDetailsDialog> createState() => _BankDetailsDialogState();
}

class _BankDetailsDialogState extends State<BankDetailsDialog> {
  final String iban = 'TR33 0006 1005 1978 6457 8413 26';
  Map<String, dynamic>? userData;
  bool _isLoading = false;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
        username = userData?['username'];
        _isLoading = false;
      });
    }
  }

  void _copyIbanToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: iban));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('IBAN Panoya Kopyalandı!'),
      ),
    );
  }

  void _copyUserNameToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: iban));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kullanıcı Adınız Panoya Kopyalandı!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SvgPicture.asset(
        'assets/svg/banklogo.svg',
        width: 40,
        height: 40,
      ),
      content: _isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Banka Adı:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text('Vakıflar Bankası'),
                const SizedBox(height: 15),
                const Text(
                  'IBAN:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(iban),
                const SizedBox(height: 15),
                Text(
                  "Kullanıcı Adınız : $username",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Para yüklemek için verilen ibana yüklemek istedğiniz mikatarı gönderiniz açıklama kısmına ise kullanıcı adınızı yazınız.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                )
              ],
            ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _copyUserNameToClipboard(context);
                Navigator.of(context).pop();
              },
              child: Center(
                child: Container(
                    alignment: Alignment.center,
                    width: 120,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color.fromRGBO(0, 86, 255, 1),
                    ),
                    child: const Text(
                      "Kullanıcı Adını Kopyala",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {
                _copyIbanToClipboard(context);
                Navigator.of(context).pop();
              },
              child: Center(
                child: Container(
                    alignment: Alignment.center,
                    width: 120,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color.fromRGBO(0, 86, 255, 1),
                    ),
                    child: const Text(
                      "IBAN'ı Kopyala",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
