import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String profImage;
  final String name;
  final String surname;
  final String searchname;
  final String username;
  final String bio;
  final List followers;
  final List following;

  const User(
      {required this.name,
      required this.surname,
      required this.searchname,
      required this.username,
      required this.uid,
      required this.profImage,
      required this.bio,
      required this.followers,
      required this.following});

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"],
      name: snapshot["name"],
      surname: snapshot["surname"],
      searchname: snapshot["searchname"],
      uid: snapshot["uid"],
      profImage: snapshot["profImage"],
      bio: snapshot["bio"],
      followers: snapshot["followers"],
      following: snapshot["following"],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "name": name,
        "surname": surname,
        "searchname": searchname,
        "uid": uid,
        "profImage": profImage,
        "bio": bio,
        "followers": followers,
        "following": following,
      };
}
