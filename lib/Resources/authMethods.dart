import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> firestoreAdd(
      String username, String name, String surname, String bio) async {
    User? currentUser = await _auth.currentUser;

    await currentUser?.reload();

    await _firestore.collection("Users").doc(_auth.currentUser?.uid).set({
      'username': username,
      'uid': _auth.currentUser?.uid,
      'profImage': null,
      'name': name,
      'surname': surname,
      'bio': bio,
      'tick': false,
      'followers': [],
      'following': [],
    });
  }
}
