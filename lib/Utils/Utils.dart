import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// for picking up image from gallery
Future<List<Uint8List>> pickImages() async {
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile>? _files = await _imagePicker.pickMultiImage(imageQuality: 75);

  if (_files.isNotEmpty) {
    List<Uint8List> imageBytesList = [];

    for (XFile file in _files) {
      Uint8List imageBytes = await file.readAsBytes();
      imageBytesList.add(imageBytes);
    }

    return imageBytesList;
  }

  if (kDebugMode) {
    print('No Images Selected');
  }

  return [];
}

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source, imageQuality: 75);
  if (_file != null) {
    return await _file.readAsBytes();
  }
  if (kDebugMode) {
    print('No Image Selected');
  }
}

Future<List<String>> pickMultipleVideos() async {
  try {
    var results = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    if (results != null) {
      List<String> videoPaths =
          results.files.map((file) => file.path!).toList();

      return videoPaths;
    }
  } catch (e) {
    print('Error picking videos: $e');
  }
  return [];
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
    ),
  );
}
