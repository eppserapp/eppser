import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Models/post.dart';
import 'package:eppser/Resources/storageMethods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
  ) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('Posts', file, true);
      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
      );
      _firestore.collection('Posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadPostStory(
    String description,
    Uint8List file,
    String uid,
  ) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('Story', file, true);
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
      String videoUrl =
          await StorageMethods().uploadVideoToStorage('Story', file, true);
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

  Future<String> addPhone(
    String phone,
    String uid,
  ) async {
    String res = "Some error occurred";
    try {
      _firestore.collection('Phone').doc(uid).set({'phone': phone, 'uid': uid});
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('Posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('Posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
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

  // Post comment
  Future<String> postComment(
    String postId,
    String text,
    String uid,
  ) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('Posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('Posts').doc(postId).delete();
      // ignore: avoid_single_cascade_in_expression_statements
      await _firestore
          .collection('Posts')
          .doc(postId)
          .collection("comments")
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.delete();
              }));
      ;

      res = 'success';
    } catch (err) {
      print(err);
      res = err.toString();
    }
    return res;
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

  Future<String> deleteComment(String postId, String commentId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('Posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      res = 'success';
    } catch (err) {
      print(err);
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

  Future<void> sendMessage(
      String text, String recieverId, String senderId) async {
    DateTime date = DateTime.now();
    String messageId = const Uuid().v1();
    _firestore
        .collection('Users')
        .doc(recieverId)
        .collection('Chats')
        .doc(senderId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'text': text,
      'date': date,
      'isSeen': false,
      'recieverId': recieverId,
      'senderId': senderId,
      'messageId': messageId
    });

    _firestore
        .collection('Users')
        .doc(senderId)
        .collection('Chats')
        .doc(recieverId)
        .collection('Messages')
        .doc(messageId)
        .set({
      'text': text,
      'date': date,
      'isSeen': false,
      'recieverId': recieverId,
      'senderId': senderId,
      'messageId': messageId
    });

    _firestore
        .collection('Users')
        .doc(senderId)
        .collection('Chats')
        .doc(recieverId)
        .set({
      'recieverId': recieverId,
      'senderId': senderId,
      'timeSent': date,
      'lastMessage': text
    });

    _firestore
        .collection('Users')
        .doc(recieverId)
        .collection('Chats')
        .doc(senderId)
        .set({
      'recieverId': senderId,
      'senderId': recieverId,
      'timeSent': date,
      'lastMessage': text
    });
  }

  Future<String> deleteMessage(
      String messageId, String recieverId, String senderId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('Users')
          .doc(senderId)
          .collection('Chats')
          .doc(recieverId)
          .collection('Messages')
          .doc(messageId)
          .delete();

      await _firestore
          .collection('Users')
          .doc(recieverId)
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

  Future<String> deleteChat(String recieverId, String senderId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('Users')
          .doc(senderId)
          .collection('Chats')
          .doc(recieverId)
          .delete();
      await _firestore
          .collection('Users')
          .doc(senderId)
          .collection('Chats')
          .doc(recieverId)
          .collection('Messages')
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.delete();
              }));

      await _firestore
          .collection('Users')
          .doc(recieverId)
          .collection('Chats')
          .doc(senderId)
          .delete();
      await _firestore
          .collection('Users')
          .doc(recieverId)
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
}
