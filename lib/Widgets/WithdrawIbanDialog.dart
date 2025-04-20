import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class WithdrawIbanDialog extends StatefulWidget {
  @override
  _WithdrawIbanDialogState createState() => _WithdrawIbanDialogState();
}

class _WithdrawIbanDialogState extends State<WithdrawIbanDialog> {
  final _ibanController = TextEditingController();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String errorMessage = '';
  String _previousValue = '';

  void initState() {
    super.initState();
    _balanceController.addListener(_onTextChanged);
  }

  bool _validateIban(String iban) {
    return iban.length == 26 && iban.startsWith('TR');
  }

  void _onTextChanged() {
    String currentValue = _balanceController.text;

    // Eğer değer değişmemişse (yani sadece imleç hareket etmişse) hiçbir şey yapma
    if (currentValue == _previousValue) return;

    // Sadece sayıları ve noktayı kabul et
    currentValue = currentValue.replaceAll(RegExp(r'[^\d.]'), '');

    if (currentValue.isEmpty) {
      _balanceController.value = const TextEditingValue(text: '');
      _previousValue = '';
      return;
    }

    try {
      double value = double.parse(currentValue);
      String formattedValue = NumberFormat("#,###.##", "en_US").format(value);

      // Eğer yeni değer eskisinden farklıysa güncelle
      if (formattedValue != _previousValue) {
        _balanceController.value = TextEditingValue(
          text: formattedValue,
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
        _previousValue = formattedValue;
      }
    } catch (e) {
      // Hata durumunda bir şey yapma, kullanıcının yazmaya devam etmesine izin ver
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          SvgPicture.asset(
            'assets/svg/banklogo.svg',
            width: 40,
            height: 40,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            'Altyapısı İle Ödeme Yapılacaktır',
            style: TextStyle(color: Colors.green, fontSize: 14),
          )
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Para çekmek için IBAN adresinizi giriniz:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _ibanController,
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
                labelText: 'IBAN',
                labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
                hintText: 'TRXX XXXX XXXX XXXX XXXX XXXX XX',
                errorText: errorMessage.isNotEmpty ? errorMessage : null,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _nameController,
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
                labelText: 'Ad Soyad',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _balanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
                labelText: 'Miktar',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                String enteredIban =
                    _ibanController.text.trim().replaceAll(' ', '');
                if (_validateIban(enteredIban)) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Para çekme işlemi başlatıldı!')),
                  );
                } else {
                  setState(() {
                    errorMessage = 'Geçersiz IBAN, lütfen tekrar deneyin.';
                  });
                }
              },
              child: Center(
                child: Container(
                    alignment: Alignment.center,
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      color: const Color.fromRGBO(0, 86, 255, 1),
                    ),
                    child: const Text(
                      "Onayla",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(context);
              },
              child: Center(
                child: Container(
                    alignment: Alignment.center,
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      color: const Color.fromRGBO(0, 86, 255, 1),
                    ),
                    child: const Text(
                      "İptal",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }
}
