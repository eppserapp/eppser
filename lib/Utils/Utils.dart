import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// for picking up image from gallery
pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source, imageQuality: 25);
  if (_file != null) {
    return await _file.readAsBytes();
  }
  if (kDebugMode) {
    print('No Image Selected');
  }
}

pickVideo(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickVideo(
      source: source, maxDuration: const Duration(minutes: 15));
  if (_file != null) {
    return await _file.readAsBytes();
  }
  if (kDebugMode) {
    print('No Video Selected');
  }
}

// for displaying snackbars
showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black,
      padding: const EdgeInsets.all(15),
    ),
  );
}
