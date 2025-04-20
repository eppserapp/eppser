import 'dart:async';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class MoneyTransfersPage extends StatefulWidget {
  const MoneyTransfersPage({super.key});

  @override
  State<MoneyTransfersPage> createState() => _MoneyTransfersPageState();
}

class _MoneyTransfersPageState extends State<MoneyTransfersPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  String? selectedValue;
  bool _isLoading = false;
  var accountData = [];
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      accountSubscription;
  double _commission = 0.0;
  double goldCommission = 0.0;
  double tlCommission = 0.0;

  void calculateCommission() {
    final enteredAmount = NumberFormat("#,###.##", "en_US")
        .parse(_textController.text)
        .toDouble();
    if (selectedValue == 'TL') {
      setState(() {
        _commission = enteredAmount * tlCommission;
      });
    } else {
      setState(() {
        _commission = enteredAmount * goldCommission;
      });
    }
  }

  Future<void> fetchCommissionRates() async {
    try {
      // Gold komisyon oranını al
      final goldDoc = await FirebaseFirestore.instance
          .collection("Liquidity")
          .doc("Gold")
          .get();
      goldCommission = goldDoc.data()?['commission'] ?? goldCommission;

      // TL komisyon oranını al
      final tlDoc = await FirebaseFirestore.instance
          .collection("Liquidity")
          .doc("TL")
          .get();
      tlCommission = tlDoc.data()?['commission'] ?? tlCommission;
    } catch (e) {
      print("Komisyon oranlarını alırken hata oluştu: $e");
      throw Exception("Komisyon oranlarını alırken hata oluştu.");
    }
  }

  void fetchAccountAndTransactionData() {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      accountSubscription = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Account')
          .doc('wallet')
          .snapshots()
          .listen((snapshot) {
        setState(() {
          if (snapshot.exists) {
            accountData = [snapshot.data()];
          } else {
            accountData = [];
          }
        });
      });

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> sendFunds({
    required String senderId,
    required String receiverUsername,
    required double amount,
    required String currency,
  }) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('sendFunds');
      final response = await callable.call({
        'senderId': senderId,
        'receiverUsername': receiverUsername,
        'amount': amount,
        'currency': currency,
      }).whenComplete(
        () {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        },
      );

      if (response.data['success'] == true) {
        showSnackBar(context, 'Transfer başarılı!');
      } else {
        showSnackBar(context, 'Transfer başarısız.');
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCommissionRates();
    fetchAccountAndTransactionData();
    selectedValue = "TL";
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    accountSubscription.cancel();
    super.dispose();
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    return [
      DropdownMenuItem(
        value: 'TL',
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                'assets/svg/tr.png',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'TL',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'Altın',
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/svg/xau.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Altın',
              style: TextStyle(color: Colors.amber),
            ),
          ],
        ),
      ),
    ];
  }

  String _previousValue = '';

  void _onTextChanged() {
    String currentValue = _textController.text;
    if (currentValue.split('.').length > 2) {
      currentValue = currentValue.substring(0, currentValue.length - 1);
    }

    // TL veya Altın değeri kontrolü
    if (currentValue != _previousValue) {
      currentValue = currentValue.replaceAll(RegExp(r'[^\d.]'), '');

      if (currentValue.isEmpty) {
        _textController.value = const TextEditingValue(text: '');
        _previousValue = '';
      } else {
        try {
          double value = double.parse(currentValue);
          String formattedValue =
              NumberFormat("#,###.##", "en_US").format(value);

          if (formattedValue != _previousValue) {
            _textController.value = TextEditingValue(
              text: formattedValue,
              selection: TextSelection.collapsed(offset: formattedValue.length),
            );
            _previousValue = formattedValue;
          }
        } catch (e) {
          print("Error parsing value: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text("Transfer"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                controller: _userNameController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp("[a-zA-Z0-9-_şğüıçöŞĞÜİÇÖ.]")),
                  FilteringTextInputFormatter.deny(RegExp("[ ]"))
                ],
                decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(245, 247, 249, 1),
                        width: 2,
                      ),
                    ),
                    labelText: 'Kullanıcı Adı',
                    labelStyle: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
              child: TextField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                ],
                controller: _textController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                        color: Color.fromRGBO(0, 86, 255, 1), width: 2.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(245, 247, 249, 1),
                      width: 2,
                    ),
                  ),
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Colors.grey),
                  label: const Text('Miktar'),
                  labelStyle: const TextStyle(color: Colors.white),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: selectedValue == "TL" ? 80 : 95,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedValue,
                          isExpanded: true,
                          icon: const Icon(Iconsax.arrow_down_1,
                              color: Colors.white),
                          iconSize: 24,
                          elevation: 16,
                          dropdownColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          borderRadius: BorderRadius.circular(20),
                          items: dropdownItems.toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  helper: Row(
                    children: [
                      const Text(
                        'Komisyon: ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '-',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      AnimatedFlipCounter(
                        decimalSeparator: '.',
                        thousandSeparator: ',',
                        prefix: selectedValue == 'TL' ? '₺' : '',
                        suffix: selectedValue == 'TL' ? '' : ' gr',
                        fractionDigits: 2,
                        duration: const Duration(milliseconds: 500),
                        value: _commission,
                        textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                onChanged: (value) {
                  calculateCommission();
                },
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () {
                if (accountData[0]['tl'] <= 0 && selectedValue == 'TL' ||
                    accountData[0]['gold'] <= 0 && selectedValue == 'Altın') {
                  showSnackBar(context, 'Bakiye Yetersiz!');
                } else if (_userNameController.text.isEmpty &&
                    _textController.text.isEmpty) {
                  showSnackBar(context, 'Zorunlu alanlar boş bırkılamaz!');
                } else {
                  sendFunds(
                      senderId: FirebaseAuth.instance.currentUser!.uid,
                      receiverUsername: _userNameController.text.trim(),
                      amount: double.parse(
                          _textController.text.trim().replaceAll(',', '')),
                      currency: selectedValue == 'TL' ? 'tl' : 'gold');
                }
              },
              child: Container(
                  alignment: Alignment.center,
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    color: const Color.fromRGBO(0, 86, 255, 1),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Gönder",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
