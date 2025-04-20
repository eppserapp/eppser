import 'package:chewie/chewie.dart';
import 'package:eppser/Resources/firestoreMethods.dart';
import 'package:eppser/Utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

class addStoryPage extends StatefulWidget {
  const addStoryPage({super.key});

  @override
  State<addStoryPage> createState() => _addStoryPageState();
}

class _addStoryPageState extends State<addStoryPage> {
  var _file;
  bool isLoading = false;
  VideoPlayerController? controller;
  var duration;
  String type = "";
  final TextEditingController _descriptionController = TextEditingController();
  ChewieController? chewieController;

  // _selectVideo(BuildContext parentContext) async {
  //   return showDialog(
  //     context: parentContext,
  //     builder: (BuildContext context) {
  //       return SimpleDialog(
  //         backgroundColor: Colors.black,
  //         title:
  //             const Text('Video Paylaş', style: TextStyle(color: Colors.white)),
  //         children: <Widget>[
  //           SimpleDialogOption(
  //               padding: const EdgeInsets.all(20),
  //               child: const Text("Galeri'den Seç"),
  //               onPressed: () async {
  //                 try {
  //                   Navigator.of(context).pop();
  //                   _file = await pickMultipleVideos();
  //                   setState(() {});
  //                 } catch (e) {
  //                   print(e);
  //                 }
  //               }),
  //           SimpleDialogOption(
  //             padding: const EdgeInsets.all(20),
  //             child: const Text("İptal"),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  // void postVideo(String uid) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   // start the loading
  //   try {
  //     // upload to storage and db
  //     String res = await FireStoreMethods().uploadVideoStory(
  //         _descriptionController.text.trim(), _file, uid, duration);
  //     if (res == "success") {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       // ignore: use_build_context_synchronously
  //       showSnackBar(
  //         context,
  //         'Paylaşıldı!',
  //       );
  //     } else {
  //       // ignore: use_build_context_synchronously
  //       showSnackBar(context, res);
  //     }
  //   } catch (err) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print(err);
  //     showSnackBar(
  //       context,
  //       err.toString(),
  //     );
  //   }
  // }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.black,
          title: const Text(
            'Fotoğraf Yükle',
            style: TextStyle(color: Colors.white),
          ),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text("Galeri'den Seç"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  var file = await pickImages();
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("İptal"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void postImage(String uid) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPostStory(
        _descriptionController.text,
        _file!,
        uid,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        // ignore: use_build_context_synchronously
        showSnackBar(
          context,
          'Paylaşıldı!',
        );
        clearImage();
        clearText();
      } else {
        // ignore: use_build_context_synchronously
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearText() {
    _descriptionController.clear();
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
    chewieController?.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mounted) {
      controller != null
          ? SchedulerBinding.instance.addPostFrameCallback((_) {
              chewieController = ChewieController(
                videoPlayerController: controller!,
                autoInitialize: true,
                autoPlay: false,
                looping: true,
              );
            })
          : const SizedBox();
    }
    return _file == null
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("Hikayem"),
              backgroundColor: Colors.black,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () async {
                        _selectImage(context);
                      },
                      child: const Text("Fotoğraf",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // SizedBox(
                  //   width: 120,
                  //   height: 45,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.black,
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10))),
                  //     onPressed: () async {
                  //       _selectVideo(context);
                  //     },
                  //     child: const Text("Video",
                  //         style: TextStyle(color: Colors.white)),
                  //   ),
                  // )
                ],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("Paylaş"),
              backgroundColor: Colors.black,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // type == "video"
                    //     ? postVideo(FirebaseAuth.instance.currentUser!.uid)
                    //     : postImage(FirebaseAuth.instance.currentUser!.uid);
                    postImage(FirebaseAuth.instance.currentUser!.uid);
                  },
                  icon: const Icon(
                    Iconsax.document_upload,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator(
                        color: Colors.black,
                        backgroundColor: Colors.white,
                      )
                    : type == "video"
                        ? Expanded(
                            child: Center(
                              child: controller!.value.isInitialized &&
                                      controller != null
                                  ? AspectRatio(
                                      aspectRatio:
                                          controller!.value.aspectRatio,
                                      child:
                                          Chewie(controller: chewieController!))
                                  : const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.black),
                                    ),
                            ),
                          )
                        : _file != null && _file.isNotEmpty
                            ? Expanded(
                                child: Image.memory(
                                  _file[0],
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2.0),
                              ),
                              border: OutlineInputBorder(),
                              hintText: 'Açıklama',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
