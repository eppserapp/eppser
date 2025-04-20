import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class ServerData {
  final String baseUrl = "https://eppser.com:3000/api/messages";

  Future<void> sendMessages() async {
    var box = Hive.box('messageBox');

    // Kutudaki tüm anahtarları alın
    var keys = box.keys;

    for (var key in keys) {
      var messagesMap = box.get(key);

      // Null kontrolü ve 'sending' değeri true olan mesajları filtreleme
      if (messagesMap != null) {
        for (var messageKey in messagesMap.keys) {
          var message = messagesMap[messageKey];

          if (message != null && message['sending'] == true) {
            final url = Uri.parse('$baseUrl/send-message');
            var request = http.MultipartRequest('POST', url);

            // JSON verilerini ekle
            request.fields['sender'] = message['senderId'];
            request.fields['receiver'] = message['receiverId'];
            if (message['text'] != null) {
              request.fields['message'] = message['text'];
            }

            // Dosya ekleme
            if (message['filePaths'] != null) {
              List<String> filePaths = List<String>.from(message['filePaths']);
              for (var filePath in filePaths) {
                File file = File(filePath);
                request.files
                    .add(await http.MultipartFile.fromPath('files', file.path));
              }
            }

            var response = await request.send();

            if (response.statusCode == 200) {
              var responseBody = await response.stream.bytesToString();
              var responseData = jsonDecode(responseBody);

              if (responseData['file_urls'] != null) {
                message['file_urls'] =
                    List<String>.from(responseData['file_urls']);
              }

              message['sending'] = false;
              messagesMap[messageKey] = message;
              await box.put(key, messagesMap);

              print(responseBody);
            } else {
              print(await response.stream.bytesToString());
              throw Exception('Failed to send message with key: $messageKey');
            }
          }
        }
      }
    }
  }

  Future<void> fetchAndSaveMessages(String receiverId) async {
    var box = Hive.box('messageBox');

    final url = Uri.parse('$baseUrl/get-messages');
    var response = await http.post(url,
        body: jsonEncode({'receiver': receiverId}),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);

      if (responseData['messages'] != null) {
        List<dynamic> messages = responseData['messages'];

        for (var message in messages) {
          var senderId = message['sender'];

          // Var olan mesajları getir
          var existingMessages = List.from(box.get(senderId)?.values ?? []);

          // Aynı messageId'ye sahip mesajı kontrol et
          bool messageExists = existingMessages.any((existingMessage) =>
              existingMessage['messageId'] == message['id']);

          if (!messageExists) {
            // Yeni mesajı ekle
            existingMessages.add({
              'messageId': message['id'],
              'senderId': senderId,
              'receiverId': message['receiver'],
              'text': message['message'],
              'file_urls': message['file_urls'],
              'date': DateTime.parse(message['timestamp']),
              'isSeen': message['seen'],
              'sending': false
            });

            // Mesajları index ile map haline getir
            var newMessagesMap = {
              for (var i = 0; i < existingMessages.length; i++)
                i: existingMessages[i],
            };

            // Kutuyu güncelle
            await box.put(senderId, newMessagesMap);
          }
        }
      }
    } else {
      throw Exception('Failed to fetch messages');
    }
  }
}
