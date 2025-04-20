import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImageToStorage(
      String childName, String child, Uint8List file, bool isPost) async {
    Reference ref = _storage.ref().child(childName).child(child);
    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<List<String>> uploadImagesToStorage(
    String childName,
    String child,
    List<Uint8List> files,
  ) async {
    Reference ref = _storage.ref().child(childName).child(child);

    List<String> downloadUrls = [];

    for (int i = 0; i < files.length; i++) {
      Uint8List file = files[i];
      String id = Uuid().v1();
      // Resmi Storage'a yükleme
      UploadTask uploadTask = ref.child(id).putData(file);

      // Yükleme durumu izleme
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // Resmin download URL'sini al
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }

  Future<List<String>> uploadVideoToStorage(
    String childName,
    String child,
    List files,
  ) async {
    Reference ref = _storage.ref().child(childName).child(child);

    List<String> downloadUrls = [];

    for (int i = 0; i < files.length; i++) {
      var file = files[i];
      String id = Uuid().v1();
      // Resmi Storage'a yükleme
      UploadTask uploadTask = ref.child(id).putFile(File(file));

      // Yükleme durumu izleme
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // Resmin download URL'sini al
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }
}
