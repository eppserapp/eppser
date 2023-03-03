import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/signUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eppser/models/user.dart' as model;

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('Users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  Future<User?> createUser(
    String username,
    String name,
    String surname,
    String searchname,
    String bio,
    bool tick,
  ) async {
    if (username.isNotEmpty ||
        name.isNotEmpty ||
        surname.isNotEmpty ||
        bio.isNotEmpty) {
      var user = await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('Sağlanan telefon numarası geçersiz');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          signUpPage.verify = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }

  Future<void> firestoreAdd(
    String username,
    String name,
    String surname,
    String searchname,
    String bio,
    bool tick,
  ) async {
    User? currentUser = await _auth.currentUser;

    await currentUser?.reload();

    await _firestore.collection("Users").doc(_auth.currentUser?.uid).set({
      'username': username,
      'uid': _auth.currentUser?.uid,
      'profImage':
          'https://firebasestorage.googleapis.com/v0/b/eppser-1a6a5.appspot.com/o/user.png?alt=media&token=98d04c95-0483-4395-bf5d-f4a63ac82d0b',
      'name': name,
      'surname': surname,
      'searchname': searchname,
      'bio': bio,
      'tick': tick,
      'followers': [],
      'following': [],
    });
  }
}
