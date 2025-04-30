import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Resources/storageMethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addPhone(
    String phone,
    String uid,
  ) async {
    String res = "Some error occurred";
    try {
      _firestore
          .collection('Phones')
          .doc(uid)
          .set({'phone': phone, 'uid': uid});
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('Users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('Users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('Users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('Users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('Users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> unFollowUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('Users').doc(uid).get();
      List followers = (snap.data()! as dynamic)['followers'];

      if (followers.contains(followId)) {
        await _firestore.collection('Users').doc(followId).update({
          'followers': FieldValue.arrayRemove([followId])
        });

        await _firestore.collection('Users').doc(uid).update({
          'followers': FieldValue.arrayRemove([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> deleteStory(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('Story').doc(postId).delete();

      res = 'success';
    } catch (err) {
      print(err);
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadPostStory(
    String description,
    List<Uint8List> file,
    String uid,
  ) async {
    String res = "Some error occurred";
    try {
      var photoUrl = await StorageMethods().uploadImagesToStorage(
        'Story',
        FirebaseAuth.instance.currentUser!.uid,
        file,
      );
      String postId = const Uuid().v1();
      _firestore.collection('Story').doc(postId).set({
        "description": description,
        "uid": uid,
        "likes": [],
        "isSeen": [],
        "postId": postId,
        "datePublished": DateTime.now(),
        "postUrl": photoUrl,
        "video": false,
      });
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadVideoStory(
      String description, var file, String uid, var duration) async {
    String res = "Some error occurred";
    try {
      var videoUrl = await StorageMethods().uploadVideoToStorage(
        'Story',
        FirebaseAuth.instance.currentUser!.uid,
        file,
      );
      String postId = const Uuid().v1();

      _firestore.collection('Story').doc(postId).set({
        "description": description,
        "uid": uid,
        "likes": [],
        "isSeen": [],
        "postId": postId,
        "datePublished": DateTime.now(),
        "postUrl": videoUrl,
        "video": true,
        "duration": duration
      });
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> seenStory(String postId, String uid) async {
    String res = "Some error occurred";
    try {
      _firestore.collection('Story').doc(postId).update({
        'isSeen': FieldValue.arrayUnion([uid])
      });

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> sendMessage(String text, String receiverId, String senderId,
      DateTime date, String messageId) async {
    _firestore
        .collection('Users')
        .doc(receiverId)
        .collection('Chats')
        .doc(senderId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'text': text,
      'date': date,
      'isSeen': false,
      'receiverId': receiverId,
      'senderId': senderId,
      'messageId': messageId,
      "sending": false
    });

    _firestore
        .collection('Users')
        .doc(senderId)
        .collection('Chats')
        .doc(receiverId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'text': text,
      'date': date,
      'isSeen': false,
      'receiverId': receiverId,
      'senderId': senderId,
      'messageId': messageId,
      "sending": false
    });

    _firestore
        .collection('Users')
        .doc(senderId)
        .collection('Chats')
        .doc(receiverId)
        .set({
      'receiverId': receiverId,
      'senderId': senderId,
      'timeSent': date,
      'lastMessage': text
    });

    _firestore
        .collection('Users')
        .doc(receiverId)
        .collection('Chats')
        .doc(senderId)
        .set({
      'receiverId': senderId,
      'senderId': receiverId,
      'timeSent': date,
      'lastMessage': text
    });
  }

  Future<void> sendImageMessage(
      List<Uint8List> image,
      String text,
      String receiverId,
      String senderId,
      DateTime date,
      String messageId) async {
    var imageUrl = await StorageMethods().uploadImagesToStorage(
      'Messages',
      FirebaseAuth.instance.currentUser!.uid,
      image,
    );

    _firestore
        .collection('Users')
        .doc(receiverId)
        .collection('Chats')
        .doc(senderId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'imageUrl': imageUrl,
      'text': text,
      'date': date,
      'isSeen': false,
      'receiverId': receiverId,
      'senderId': senderId,
      'messageId': messageId,
      "sending": false
    });

    _firestore
        .collection('Users')
        .doc(senderId)
        .collection('Chats')
        .doc(receiverId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'imageUrl': imageUrl,
      'text': text,
      'date': date,
      'isSeen': false,
      'receiverId': receiverId,
      'senderId': senderId,
      'messageId': messageId,
      "sending": false
    });

    _firestore
        .collection('Users')
        .doc(senderId)
        .collection('Chats')
        .doc(receiverId)
        .set({
      'receiverId': receiverId,
      'senderId': senderId,
      'timeSent': date,
    });

    _firestore
        .collection('Users')
        .doc(receiverId)
        .collection('Chats')
        .doc(senderId)
        .set({
      'receiverId': senderId,
      'senderId': receiverId,
      'timeSent': date,
    });
  }

  Future<void> sendVideoMessage(List video, String text, String receiverId,
      String senderId, DateTime date, String messageId) async {
    var videoUrl = await StorageMethods().uploadVideoToStorage(
      'Messages',
      FirebaseAuth.instance.currentUser!.uid,
      video,
    );

    _firestore
        .collection('Users')
        .doc(receiverId)
        .collection('Chats')
        .doc(senderId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'videoUrl': videoUrl,
      'text': text,
      'date': date,
      'isSeen': false,
      'receiverId': receiverId,
      'senderId': senderId,
      'messageId': messageId,
      "sending": false
    });

    _firestore
        .collection('Users')
        .doc(senderId)
        .collection('Chats')
        .doc(receiverId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'videoUrl': videoUrl,
      'text': text,
      'date': date,
      'isSeen': false,
      'receiverId': receiverId,
      'senderId': senderId,
      'messageId': messageId,
      "sending": false
    });

    _firestore
        .collection('Users')
        .doc(senderId)
        .collection('Chats')
        .doc(receiverId)
        .set({
      'receiverId': receiverId,
      'senderId': senderId,
      'timeSent': date,
    });

    _firestore
        .collection('Users')
        .doc(receiverId)
        .collection('Chats')
        .doc(senderId)
        .set({
      'receiverId': senderId,
      'senderId': receiverId,
      'timeSent': date,
    });
  }

  Future<String> deleteMessage(
      String messageId, String receiverId, String senderId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('Users')
          .doc(senderId)
          .collection('Chats')
          .doc(receiverId)
          .collection('Messages')
          .doc(messageId)
          .delete();

      await _firestore
          .collection('Users')
          .doc(receiverId)
          .collection('Chats')
          .doc(senderId)
          .collection('Messages')
          .doc(messageId)
          .delete();

      res = 'success';
    } catch (err) {
      print(err);
      res = err.toString();
    }
    return res;
  }

  Future<void> sendImageMessageGroup(
      String name,
      List<Uint8List> image,
      String text,
      String groupId,
      String senderId,
      DateTime date,
      String messageId) async {
    var imageUrl = await StorageMethods().uploadImagesToStorage(
      'Messages',
      FirebaseAuth.instance.currentUser!.uid,
      image,
    );

    _firestore
        .collection('Groups')
        .doc(groupId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'name': name,
      'imageUrl': imageUrl,
      'text': text,
      'date': date,
      'isSeen': [FirebaseAuth.instance.currentUser!.uid],
      'senderId': senderId,
      'messageId': messageId,
      "sending": false
    });

    _firestore
        .collection('Groups')
        .doc(groupId)
        .update({'lastMessageTime': DateTime.now()});
  }

  Future<void> sendVideoMessageGroup(String name, List video, String text,
      String groupId, String senderId, DateTime date, String messageId) async {
    var videoUrl = await StorageMethods().uploadVideoToStorage(
      'Messages',
      FirebaseAuth.instance.currentUser!.uid,
      video,
    );

    _firestore
        .collection('Groups')
        .doc(groupId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'name': name,
      'videoUrl': videoUrl,
      'text': text,
      'date': date,
      'isSeen': [FirebaseAuth.instance.currentUser!.uid],
      'senderId': senderId,
      'messageId': messageId,
      "sending": false
    });
    _firestore
        .collection('Groups')
        .doc(groupId)
        .update({'lastMessageTime': DateTime.now()});
  }

  Future<void> sendImageMessageChanel(
      String name,
      List<Uint8List> image,
      String text,
      String groupId,
      String chanelId,
      String senderId,
      DateTime date,
      String messageId) async {
    var imageUrl = await StorageMethods().uploadImagesToStorage(
      'Messages',
      FirebaseAuth.instance.currentUser!.uid,
      image,
    );

    _firestore
        .collection('Chanels')
        .doc(chanelId)
        .collection('Groups')
        .doc(groupId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'name': name,
      'imageUrl': imageUrl,
      'text': text,
      'date': date,
      'isSeen': [FirebaseAuth.instance.currentUser!.uid],
      'senderId': senderId,
      'messageId': messageId,
      "sending": false
    });

    _firestore
        .collection('Chanels')
        .doc(chanelId)
        .collection('Groups')
        .doc(groupId)
        .update({'lastMessageTime': DateTime.now()});
  }

  Future<void> sendVideoMessageChanel(
      String name,
      List video,
      String text,
      String groupId,
      String chanelId,
      String senderId,
      DateTime date,
      String messageId) async {
    var videoUrl = await StorageMethods().uploadVideoToStorage(
      'Messages',
      FirebaseAuth.instance.currentUser!.uid,
      video,
    );

    _firestore
        .collection('Chanels')
        .doc(chanelId)
        .collection('Groups')
        .doc(groupId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'name': name,
      'videoUrl': videoUrl,
      'text': text,
      'date': date,
      'isSeen': [FirebaseAuth.instance.currentUser!.uid],
      'senderId': senderId,
      'messageId': messageId,
      "sending": false
    });
    _firestore
        .collection('Chanels')
        .doc(chanelId)
        .collection('Groups')
        .doc(groupId)
        .update({'lastMessageTime': DateTime.now()});
  }

  Future<String> deleteChat(String receiverId, String senderId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('Users')
          .doc(senderId)
          .collection('Chats')
          .doc(receiverId)
          .delete();
      await _firestore
          .collection('Users')
          .doc(senderId)
          .collection('Chats')
          .doc(receiverId)
          .collection('Messages')
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.delete();
              }));

      await _firestore
          .collection('Users')
          .doc(receiverId)
          .collection('Chats')
          .doc(senderId)
          .delete();
      await _firestore
          .collection('Users')
          .doc(receiverId)
          .collection('Chats')
          .doc(senderId)
          .collection('Messages')
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.delete();
              }));
      res = 'success';
    } catch (err) {
      print(err);
      res = err.toString();
    }
    return res;
  }

  Future<void> sendMessageGroup(String text, String senderId, DateTime date,
      String name, String messageId, String groupId) async {
    _firestore
        .collection('Groups')
        .doc(groupId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'text': text,
      'date': date,
      'isSeen': [FirebaseAuth.instance.currentUser!.uid],
      'senderId': senderId,
      'name': name,
      'messageId': messageId,
      "sending": false
    });

    _firestore
        .collection('Groups')
        .doc(groupId)
        .update({'lastMessageTime': DateTime.now()});
  }

  Future<void> sendChanelMessage(String text, String senderId, DateTime date,
      String name, String messageId, String groupId, String community) async {
    _firestore
        .collection('Community')
        .doc(community)
        .collection('Groups')
        .doc(groupId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'text': text,
      'date': date,
      'isSeen': [FirebaseAuth.instance.currentUser!.uid],
      'senderId': senderId,
      'name': name,
      'messageId': messageId,
      "sending": false
    });
  }

  Future<void> createGroup(
    String name,
    String uid,
    List admins,
    List members,
    Uint8List? file,
    String about,
  ) async {
    try {
      if (file != null) {
        String groupId = const Uuid().v1();
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('Groups', groupId, file, true);

        _firestore.collection('Groups').doc(groupId).set({
          'name': name,
          'uid': uid,
          'groupId': groupId,
          'admins': admins,
          'members': members,
          'photoUrl': photoUrl,
          'about': about,
          'date': DateTime.now(),
          'lastMessageTime': DateTime.now()
        });
      } else {
        String groupId = const Uuid().v1();
        _firestore.collection('Groups').doc(groupId).set({
          'name': name,
          'uid': uid,
          'groupId': groupId,
          'admins': admins,
          'members': members,
          'photoUrl': null,
          'about': about,
          'date': DateTime.now(),
          'lastMessageTime': DateTime.now()
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> editGroup(
    String name,
    String groupId,
    Uint8List? file,
    String about,
  ) async {
    try {
      if (file != null) {
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('Groups', groupId, file, true);

        _firestore.collection('Groups').doc(groupId).update({
          'name': name,
          'photoUrl': photoUrl,
          'about': about,
        });
      } else {
        _firestore.collection('Groups').doc(groupId).update({
          'name': name,
          'about': about,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> editCommunityGroup(
    String name,
    String groupId,
    String communityId,
    Uint8List? file,
    String about,
  ) async {
    try {
      if (file != null) {
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('Community', communityId, file, true);

        _firestore
            .collection('Community')
            .doc(communityId)
            .collection('Groups')
            .doc(groupId)
            .update({
          'name': name,
          'photoUrl': photoUrl,
          'about': about,
        });
      } else {
        _firestore
            .collection('Community')
            .doc(communityId)
            .collection('Groups')
            .doc(groupId)
            .update({
          'name': name,
          'about': about,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> editCommunity(
    String name,
    String communityId,
    Uint8List? file,
    Uint8List? file2,
    String about,
  ) async {
    try {
      if (file != null) {
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('Community', communityId, file, true);

        _firestore.collection('Community').doc(communityId).update({
          'name': name,
          'photoUrl': photoUrl,
          'about': about,
        });
      } else if (file2 != null) {
        String photoUrl2 = await StorageMethods()
            .uploadImageToStorage('Community', communityId, file2, true);

        _firestore.collection('Community').doc(communityId).update({
          'name': name,
          'imageUrl': photoUrl2,
          'about': about,
        });
      } else {
        _firestore.collection('Community').doc(communityId).update({
          'name': name,
          'about': about,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> createCommunity(
    String name,
    String uid,
    List admins,
    List members,
    Uint8List? file,
    String about,
  ) async {
    try {
      if (file != null) {
        String communityId = const Uuid().v1();
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('Community', communityId, file, true);

        String groupId = const Uuid().v1();
        _firestore.collection('Community').doc(communityId).set({
          'name': name,
          'approved': false,
          'uid': uid,
          'communityId': communityId,
          'admins': admins,
          'members': members,
          'photoUrl': photoUrl,
          'about': about,
          'date': DateTime.now(),
        });
        _firestore
            .collection('Community')
            .doc(communityId)
            .collection('Groups')
            .doc(groupId)
            .set({
          'name': "Duyurular",
          'uid': uid,
          'groupId': groupId,
          'community': communityId,
          'admins': admins,
          'members': members,
          'photoUrl': photoUrl,
          'about': about,
          'date': DateTime.now(),
        });
      } else {
        String communityId = const Uuid().v1();
        String groupId = const Uuid().v1();
        _firestore.collection('Community').doc(communityId).set({
          'name': name,
          'approved': false,
          'uid': uid,
          'communityId': communityId,
          'admins': admins,
          'members': members,
          'photoUrl': null,
          'about': about,
          'date': DateTime.now(),
        });
        _firestore
            .collection('Community')
            .doc(communityId)
            .collection('Groups')
            .doc(groupId)
            .set({
          'name': "Duyurular",
          'uid': uid,
          'groupId': groupId,
          'communityId': communityId,
          'admins': admins,
          'members': members,
          'photoUrl': null,
          'about': about,
          'date': DateTime.now(),
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> createCommunityGroup(
    String name,
    String uid,
    String communityId,
    List admins,
    List members,
    Uint8List? file,
    String about,
  ) async {
    try {
      if (file != null) {
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('Community', communityId, file, true);

        String groupId = const Uuid().v1();

        _firestore
            .collection('Community')
            .doc(communityId)
            .collection('Groups')
            .doc(groupId)
            .set({
          'name': name,
          'uid': uid,
          'groupId': groupId,
          'community': communityId,
          'admins': admins,
          'members': members,
          'photoUrl': photoUrl,
          'about': about,
          'date': DateTime.now(),
        });
      } else {
        String groupId = const Uuid().v1();

        _firestore
            .collection('Community')
            .doc(communityId)
            .collection('Groups')
            .doc(groupId)
            .set({
          'name': name,
          'uid': uid,
          'groupId': groupId,
          'community': communityId,
          'admins': admins,
          'members': members,
          'photoUrl': null,
          'about': about,
          'date': DateTime.now(),
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
