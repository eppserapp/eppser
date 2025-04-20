import 'dart:async';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:marqueer/marqueer.dart';

class BuyPage extends StatefulWidget {
  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _tlController = TextEditingController();
  final String apiUrl = 'https://finans.truncgil.com/today.json';
  bool _isLoading = false;
  Timer? _timer;
  double _exchangeRate = 0.0;
  bool _isTltoGold = true;
  var ApiData;
  double _commission = 0.0;
  double goldCommission = 0.0;
  double tlCommission = 0.0;
  double goldLiquidity = 0.0;

  @override
  void initState() {
    super.initState();
    _tlController.addListener(_onTextChanged);
    _goldController.addListener(_onTextChanged);
    fetchCommissionRates();
    getGoldLiquidity();
    apiData();
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer t) async {
      await apiData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> getGoldLiquidity() async {
    try {
      final liquidityRef =
          FirebaseFirestore.instance.collection("Liquidity").doc("Gold");

      liquidityRef.snapshots().listen(
        (DocumentSnapshot snapshot) {
          setState(() {
            goldLiquidity =
                (snapshot.data() as Map<String, dynamic>)['liquidity']
                        ?.toDouble() ??
                    0.0;
          });
        },
      );
    } catch (e) {
      print("Hata: $e");
      throw Exception("Likidite alınırken bir hata oluştu.");
    }
  }

  Future<void> buyGold({
    required BuildContext context,
    required String userId,
    required double amount,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      amount = double.parse(amount.toStringAsFixed(4));
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('buyGold');
      final response = await callable.call({
        'userId': userId,
        'amount': amount,
      }).whenComplete(
        () {
          setState(() {
            _isLoading = false;
          });
        },
      );

      if (response.data['success']) {
        showSnackBar(context, "Altın satın alma başarılı!");
      } else {
        showSnackBar(context, "Altın satın alma başarısız!");
      }
    } catch (e) {
      if (e is FirebaseFunctionsException && e.code == 'failed-precondition') {
        print(e);
      } else {
        print("Hata oluştu: $e");
      }
    }
  }

  Future<void> buyTL({
    required BuildContext context,
    required String userId,
    required double amount,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      amount = double.parse(amount.toStringAsFixed(4));
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('buyTL');
      final response = await callable.call({
        'userId': userId,
        'amount': amount,
      }).whenComplete(
        () {
          setState(() {
            _isLoading = false;
          });
        },
      );

      if (response.data['success']) {
        showSnackBar(context, "Altın satma işlemi başarılı!");
      } else {
        showSnackBar(context, "Altın satma işlemi başarısız!");
      }
    } catch (e) {
      if (e is FirebaseFunctionsException && e.code == 'failed-precondition') {
        print(e);
      } else {
        print("Hata oluştu: $e");
      }
    }
  }

  void showInsufficientLiquidityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              SvgPicture.asset(
                'assets/svg/xau.svg',
                height: 30,
                width: 30,
              ),
              const SizedBox(width: 14),
              Text(
                "Likidite Yetersiz",
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color),
              ),
            ],
          ),
          content: const Text(
            "Üzgünüz işlemi gerçekleştirmek için yeterli altın likiditesi yok!",
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Tamam",
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyMedium!.color)),
            ),
          ],
        );
      },
    );
  }

  String _previousTlValue = '';
  String _previousGoldValue = '';

  void _onTextChanged() {
    String currentTlValue = _tlController.text;
    String currentGoldValue = _goldController.text;

    // Sadece bir nokta olmasına izin vermek için kontrol
    if (currentTlValue.split('.').length > 2) {
      currentTlValue = currentTlValue.substring(0, currentTlValue.length - 1);
    }

    // TL değeri kontrolü
    if (currentTlValue != _previousTlValue) {
      currentTlValue = currentTlValue.replaceAll(RegExp(r'[^\d.]'), '');

      if (currentTlValue.isEmpty) {
        _tlController.value = const TextEditingValue(text: '');
        _previousTlValue = '';
      } else {
        try {
          double value = double.parse(currentTlValue);
          String formattedValue =
              NumberFormat("#,###.##", "en_US").format(value);

          if (formattedValue != _previousTlValue) {
            _tlController.value = TextEditingValue(
              text: formattedValue,
              selection: TextSelection.collapsed(offset: formattedValue.length),
            );
            _previousTlValue = formattedValue;
          }
        } catch (e) {
          print("Error parsing TL value: $e");
        }
      }
    }

    // Altın değeri kontrolü
    if (currentGoldValue.split('.').length > 2) {
      currentGoldValue =
          currentGoldValue.substring(0, currentGoldValue.length - 1);
    }

    if (currentGoldValue != _previousGoldValue) {
      currentGoldValue = currentGoldValue.replaceAll(RegExp(r'[^\d.]'), '');

      if (currentGoldValue.isEmpty) {
        _goldController.value = const TextEditingValue(text: '');
        _previousGoldValue = '';
      } else {
        try {
          double value = double.parse(currentGoldValue);
          String formattedValue =
              NumberFormat("#,###.####", "en_US").format(value);

          if (formattedValue != _previousGoldValue) {
            _goldController.value = TextEditingValue(
              text: formattedValue,
              selection: TextSelection.collapsed(offset: formattedValue.length),
            );
            _previousGoldValue = formattedValue;
          }
        } catch (e) {
          print("Error parsing Gold value: $e");
        }
      }
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

  Future<void> apiData() async {
    setState(() {
      _isLoading = true;
    });
    final response = await Dio().get(apiUrl);

    if (response.statusCode == 200) {
      setState(() {
        ApiData = response.data;
        _exchangeRate = double.parse(response.data['gram-altin']['Alış']
            .replaceAll('.', '')
            .replaceAll(',', '.'));
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _calculateGoldToTl() {
    final goldText = _goldController.text;
    double? gold =
        NumberFormat("#,###.####", "en_US").parse(goldText).toDouble();
    double tl = gold * _exchangeRate;
    setState(() {
      _tlController.text = NumberFormat("#,###.##", "en_US").format(tl);
      _commission = double.parse((tl * tlCommission).toStringAsFixed(2));
      if (_tlController.text == "" || _goldController.text == "") {
        _tlController.clear();
        _goldController.clear();
      }
    });
  }

  void _calculateTlToGold() {
    final tlText = _tlController.text;
    double? tl = NumberFormat("#,###.##", "en_US").parse(tlText).toDouble();

    double gold = tl / _exchangeRate;
    setState(() {
      _goldController.text = NumberFormat("#,###.####", "en_US").format(gold);
      _commission = double.parse((tl * goldCommission).toStringAsFixed(2));
      if (_tlController.text == "" || _goldController.text == "") {
        _tlController.clear();
        _goldController.clear();
      }
    });
  }

  void _swapFields() {
    setState(() {
      _isTltoGold = !_isTltoGold;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text("Satın Al")),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            ApiData == null
                ? const SizedBox()
                : Center(
                    child: Container(
                      height: 50.0,
                      color: Colors.black,
                      child: Marqueer(
                        interaction: false,
                        pps: 50,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '₺${ApiData["gram-altin"]["Alış"]}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                            const SizedBox(width: 20),
                            Image.asset(
                              'assets/svg/usd.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '₺${ApiData["USD"]["Alış"]}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                            const SizedBox(width: 20),
                            SvgPicture.asset(
                              'assets/svg/xau.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${ApiData["ons"]["Alış"]}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                            const SizedBox(width: 20),
                            Image.asset(
                              'assets/svg/eur.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '₺${ApiData["EUR"]["Alış"]}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                            const SizedBox(width: 20),
                            Image.asset(
                              'assets/svg/gbp.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '₺${ApiData["GBP"]["Alış"]}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  TextField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                    ],
                    autofocus: true,
                    controller: _isTltoGold ? _tlController : _goldController,
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
                        suffixIcon: _isTltoGold
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child:
                                            Image.asset('assets/svg/tr.png')),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: SvgPicture.asset(
                                            'assets/svg/xau.svg')),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                        hintText: '0.00',
                        hintStyle: const TextStyle(color: Colors.grey),
                        labelText: _isTltoGold ? 'TRY' : 'Altın (gram)',
                        labelStyle: const TextStyle(color: Colors.white)),
                    onChanged: (value) {
                      if (!_isTltoGold) {
                        _calculateGoldToTl();
                      } else {
                        _calculateTlToGold();
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: TextField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                      ],
                      controller: _isTltoGold ? _goldController : _tlController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(0, 86, 255, 1),
                                width: 2.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(245, 247, 249, 1),
                              width: 2,
                            ),
                          ),
                          suffixIcon: _isTltoGold
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: SvgPicture.asset(
                                              'assets/svg/xau.svg')),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child:
                                              Image.asset('assets/svg/tr.png')),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                          hintText: '0.00',
                          hintStyle: const TextStyle(color: Colors.grey),
                          labelText: _isTltoGold ? 'Altın (gram)' : 'TRY',
                          labelStyle: const TextStyle(color: Colors.white),
                          helper: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Komisyon: ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _isTltoGold ? '-' : '+',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  AnimatedFlipCounter(
                                    decimalSeparator: '.',
                                    thousandSeparator: ',',
                                    prefix: '₺',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Likitide : ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  AnimatedFlipCounter(
                                    decimalSeparator: '.',
                                    thousandSeparator: ',',
                                    fractionDigits: 2,
                                    duration: const Duration(milliseconds: 500),
                                    value: goldLiquidity,
                                    textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    ' gr.',
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          )),
                      onChanged: (value) {
                        if (_isTltoGold) {
                          _calculateGoldToTl();
                        } else {
                          _calculateTlToGold();
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(18)),
                          color: _isTltoGold ? Colors.red : Colors.amber,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Iconsax.arrange_circle,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: _swapFields,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (goldLiquidity <
                        double.parse(
                            _goldController.text.trim().replaceAll(',', '')) &&
                    _isTltoGold) {
                  showInsufficientLiquidityDialog(context);
                }
                if (_tlController.text.isNotEmpty &&
                    _goldController.text.isNotEmpty &&
                    _isTltoGold) {
                  buyGold(
                      context: context,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      amount: double.parse(
                          _goldController.text.trim().replaceAll(',', '')));
                }
                if (_tlController.text.isNotEmpty &&
                    _goldController.text.isNotEmpty &&
                    _isTltoGold == false) {
                  buyTL(
                      context: context,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      amount: double.parse(
                          _goldController.text.trim().replaceAll(',', '')));
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
                      : Text(
                          _isTltoGold ? "Altın Al" : " Altın Sat",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
