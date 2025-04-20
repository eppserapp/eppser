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

class BuyTokenPage extends StatefulWidget {
  @override
  _BuyTokenPageState createState() => _BuyTokenPageState();
}

class _BuyTokenPageState extends State<BuyTokenPage> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _tlController = TextEditingController();
  final String apiUrl = 'https://finans.truncgil.com/today.json';
  bool _isLoading = false;
  Timer? _timer;
  bool _isTokenToTl = true;
  var ApiData;
  String _previousTlValue = '';
  String _previousTokenValue = '';
  double tokenLiquidity = 0.0;
  double totalTokensForSale = 0.0;

  @override
  void initState() {
    super.initState();
    _tlController.addListener(
        () => _onTextChanged(_tlController, _previousTlValue, (value) {
              _previousTlValue = value;
            }));

    _tokenController.addListener(
        () => _onTextChanged(_tokenController, _previousTokenValue, (value) {
              _previousTokenValue = value;
            }));
    getTokenLiquidity();
    fetchUserTokenSales();
    apiData();
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer t) async {
      await apiData();
    });
  }

  Future<void> getTokenLiquidity() async {
    try {
      final liquidityRef =
          FirebaseFirestore.instance.collection("Liquidity").doc("Token");

      liquidityRef.snapshots().listen(
        (DocumentSnapshot snapshot) {
          setState(() {
            tokenLiquidity =
                (snapshot.data() as Map<String, dynamic>)['liquidity']
                        ?.toDouble() ??
                    0.0;
          });
        },
      );
    } catch (e) {
      print("Hata: $e");
      throw Exception("Gold likidite alınırken bir hata oluştu.");
    }
  }

  void showInsufficientLiquidityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Image.asset(
                'assets/images/eppser.png',
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
            "Üzgünüz işlemi gerçekleştirmek için yeterli token likiditesi yok!",
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

  Future<void> buyToken({
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
          FirebaseFunctions.instance.httpsCallable('buyToken');
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
        showSnackBar(context, "Token satın alma başarılı!");
      } else {
        showSnackBar(context, "Token satın alma başarısız!");
      }
    } catch (e) {
      if (e is FirebaseFunctionsException && e.code == 'failed-precondition') {
        print(e);
      } else {
        print("Hata oluştu: $e");
      }
    }
  }

  Future<void> sellToken({
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
          FirebaseFunctions.instance.httpsCallable('sellToken');
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
        showSnackBar(context, "Token satışa sunuldu!");
      } else {
        showSnackBar(context, "Token satışı başarısız oldu!");
      }
    } catch (e) {
      if (e is FirebaseFunctionsException && e.code == 'failed-precondition') {
        print(e);
      } else {
        print("Hata oluştu: $e");
      }
    }
  }

  Future<void> cancelAllTokenSales({
    required BuildContext context,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('cancelAllTokenSales');
      final response = await callable.call({
        'userId': FirebaseAuth.instance.currentUser!.uid,
      }).whenComplete(
        () {
          setState(() {
            _isLoading = false;
          });
        },
      );

      if (response.data['success']) {
        showSnackBar(context, "Token satışı iptal edildi!");
      } else {
        showSnackBar(context, "Token satış iptali başarısız oldu!");
      }
    } catch (e) {
      if (e is FirebaseFunctionsException && e.code == 'failed-precondition') {
        print(e);
      } else {
        print("Hata oluştu: $e");
      }
    }
  }

  void fetchUserTokenSales() {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('TokenSale')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((querySnapshot) {
      double totalTokensForSale = 0.0;

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          totalTokensForSale += data['tokenAmount'] ?? 0.0;
        }
      }

      setState(() {
        this.totalTokensForSale = totalTokensForSale;
      });
    }, onError: (error) {
      print("Hata oluştu: $error");
    });
  }

  void _onTextChanged(TextEditingController controller, String previousValue,
      Function(String) updatePreviousValue) {
    String currentValue = controller.text;

    if (currentValue == previousValue) return;

    currentValue = currentValue.replaceAll(RegExp(r'[^\d.]'), '');

    if (currentValue.isEmpty) {
      controller.value = const TextEditingValue(text: '');
      updatePreviousValue('');
      return;
    }

    double value = double.parse(currentValue);
    String formattedValue = NumberFormat("#,###.##", "en_US").format(value);

    if (formattedValue != previousValue) {
      controller.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
      updatePreviousValue(formattedValue);
    }
  }

  Future<void> apiData() async {
    final response = await Dio().get(apiUrl);

    if (response.statusCode == 200) {
      setState(() {
        ApiData = response.data;
      });
    }
  }

  void _calculateTokenToTl() {
    final tokenText = _tokenController.text;
    double? token =
        NumberFormat("#,###.##", "en_US").parse(tokenText).toDouble();
    double tl = token * 1;
    setState(() {
      _tlController.text = NumberFormat("#,###.##", "en_US").format(tl);
    });
  }

  void _calculateTlToToken() {
    final tlText = _tlController.text;
    double? tl = NumberFormat("#,###.##", "en_US").parse(tlText).toDouble();

    double token = tl;
    setState(() {
      _tokenController.text = NumberFormat("#,###.##", "en_US").format(token);
    });
  }

  void _swapFields() {
    setState(() {
      _isTokenToTl = !_isTokenToTl;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tokenController.dispose();
    _tlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text("Satın Al")),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'assets/images/background.jpg',
                ),
                fit: BoxFit.cover)),
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
            if (totalTokensForSale != 0)
              const SizedBox(
                height: 10,
              ),
            if (totalTokensForSale != 0)
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: Colors.black),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${NumberFormat("#,###.##", "en_US").format(totalTokensForSale)} token satışta!',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Emin misiniz?',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                    fontSize: 24),
                              ),
                              content: const Text(
                                'Bu işlemi gerçekleştirmek istediğinizden emin misiniz?',
                                style: TextStyle(fontSize: 18),
                              ),
                              actions: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Hayır',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 20),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    cancelAllTokenSales(
                                      context: context,
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Evet',
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 20),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Colors.red),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'İptal Et',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  TextField(
                    autofocus: true,
                    controller: _isTokenToTl ? _tlController : _tokenController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                    ],
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
                        suffixIcon: _isTokenToTl
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
                                        child: Image.asset(
                                            'assets/images/eppser.png')),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                        hintText: '0.00',
                        hintStyle: const TextStyle(color: Colors.grey),
                        labelText: _isTokenToTl ? 'TRY' : 'eppser Token',
                        labelStyle: const TextStyle(color: Colors.white)),
                    onChanged: (value) {
                      if (!_isTokenToTl) {
                        _calculateTokenToTl();
                      } else {
                        _calculateTlToToken();
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: TextField(
                      controller:
                          _isTokenToTl ? _tokenController : _tlController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                      ],
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
                          suffixIcon: _isTokenToTl
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
                                          child: Image.asset(
                                              'assets/images/eppser.png')),
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
                          labelText: _isTokenToTl ? 'eppser Token' : 'TRY',
                          labelStyle: const TextStyle(color: Colors.white),
                          helper: Row(
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
                                value: tokenLiquidity,
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                      onChanged: (value) {
                        if (_isTokenToTl) {
                          _calculateTokenToTl();
                        } else {
                          _calculateTlToToken();
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
                          color: _isTokenToTl ? Colors.red : Colors.black,
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
                if (tokenLiquidity <
                    double.parse(
                        _tokenController.text.trim().replaceAll(',', ''))) {
                  showInsufficientLiquidityDialog(context);
                }
                if (_tlController.text.isNotEmpty &&
                    _tokenController.text.isNotEmpty &&
                    _isTokenToTl) {
                  buyToken(
                      context: context,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      amount: double.parse(
                          _tokenController.text.trim().replaceAll(',', '')));
                }

                if (_tlController.text.isNotEmpty &&
                    _tokenController.text.isNotEmpty &&
                    _isTokenToTl == false) {
                  sellToken(
                      context: context,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      amount: double.parse(
                          _tokenController.text.trim().replaceAll(',', '')));
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
                          _isTokenToTl ? "Satın Al" : "Sat",
                          style: TextStyle(
                              color: _isLoading ? Colors.black : Colors.white,
                              fontSize: 18),
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
