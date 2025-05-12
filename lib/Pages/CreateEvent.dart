import 'package:eppser/Pages/EventsView.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool isLoading = false;
  Uint8List? _image;

  void _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      locale: const Locale("tr", "TR"),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(0, 86, 255, 1), // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Colors.black, // Calendar background color
              onSurface: Colors.white, // Calendar text color
            ),
            dialogTheme: const DialogTheme(
              backgroundColor: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Yeni: image seçme fonksiyonu
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      Uint8List imageBytes = await imageFile.readAsBytes();
      setState(() {
        _image = imageBytes;
      });
    }
  }

  void _createEvent() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Lütfen tüm alanları doldurun ve bir fotoğraf seçin.")));
      return;
    }
    setState(() {
      isLoading = true;
    });
    String res = await FireStoreMethods().createEvent(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      _selectedDate!,
      _image,
      FirebaseAuth.instance.currentUser!.uid,
    );
    setState(() {
      isLoading = false;
    });
    if (res == "success") {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Hata oluştu: $res")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Etkinlik Oluştur",
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // SingleChildScrollView ile sarmalanmıştır
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(0, 86, 255, 1),
                                width: 2.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(245, 247, 249, 1),
                              width: 2,
                            ),
                          ),
                          labelText: 'Başlık',
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          )),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(0, 86, 255, 1),
                                width: 2.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(245, 247, 249, 1),
                              width: 2,
                            ),
                          ),
                          labelText: 'Açıklama',
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          )),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? "Etkinlik Tarihi Seçilmedi"
                                : "Etkinlik Tarihi: ${DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate!)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickDate,
                          child: const Row(
                            children: [
                              Text("Tarih Seç",
                                  style: TextStyle(
                                    color: Color.fromRGBO(0, 86, 255, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(width: 8),
                              Icon(
                                Iconsax.calendar,
                                size: 22,
                                color: Color.fromRGBO(0, 86, 255, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _image != null
                        ? Image.memory(_image!, height: 150)
                        : const SizedBox(
                            height: 150,
                            child: Center(child: Text("Fotoğraf Seçilmedi"))),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text("Resim Seç",
                          style: TextStyle(
                            color: Color.fromRGBO(0, 86, 255, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(0, 86, 255, 1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _createEvent,
                      child: const Text("Oluştur",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Oluşturduğum Etkinlikler",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Events')
                          .where('createdBy',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .orderBy('dateCreated', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text("Hata oluştu."));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text("Etkinlik bulunamadı."));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var doc = snapshot.data!.docs[index];
                            var eventData = doc.data() as Map<String, dynamic>;
                            return InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventsView(data: eventData),
                                  )),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.3),
                                        BlendMode.darken),
                                    image: eventData['imageUrl'] == null
                                        ? const AssetImage(
                                            'assets/images/moneybackground.jpg')
                                        : NetworkImage(eventData['imageUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 300,
                                            child: Text(
                                                eventData['title'] ??
                                                    "Başlık yok",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                )),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: 300,
                                            child: Text(
                                                eventData['description'] ??
                                                    "Açıklama yok",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            DateFormat.yMMMMEEEEd("tr_TR")
                                                .format(
                                              (eventData['dateCreated']
                                                      as Timestamp)
                                                  .toDate(),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Iconsax.trash,
                                              size: 24, color: Colors.red),
                                          onPressed: () async {
                                            bool confirmDelete =
                                                await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.black,
                                                  title: const Text(
                                                      "Silmek istediğinize emin misiniz?",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18)),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text("İptal",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(false);
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text("Sil",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(true);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            if (confirmDelete) {
                                              try {
                                                if (eventData['imageUrl'] !=
                                                    null) {
                                                  await FirebaseStorage.instance
                                                      .refFromURL(
                                                          eventData['imageUrl'])
                                                      .delete();
                                                }

                                                await FirebaseFirestore.instance
                                                    .collection('Events')
                                                    .doc(doc.id)
                                                    .delete();
                                                if (mounted) {
                                                  // widget hala aktif mi?
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              "Etkinlik silindi")));
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  // widget hala aktif mi?
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              "Silme işlemi başarısız: $e")));
                                                }
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
