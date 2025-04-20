import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoHome extends StatefulWidget {
  const VideoHome({super.key});

  @override
  State<VideoHome> createState() => _VideoHomeState();
}

class _VideoHomeState extends State<VideoHome> {
  final List<String> videoUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Row(
          children: [
            Icon(
              Iconsax.arrow_right_3,
              size: 28,
              color: Colors.amber,
            ),
            const Text(
              "Sinema",
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ).animate().move(
                  duration: 800.ms,
                  begin: const Offset(-30, 0),
                  end: Offset.zero,
                  curve: Curves.easeOut,
                ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Iconsax.maximize_3),
              iconSize: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return VideoPage(url: videoUrls[index]);
        },
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  final String url;

  const VideoPage({super.key, required this.url});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isManuallyPaused = false; // Manuel durdurma durumunu takip et

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _videoPlayerController.initialize().then((_) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: true,
          showControls: false,
        );
        _isInitialized = true;
      });
    }).catchError((error) {
      print("Video yüklenirken hata: $error");
    });
  }

  // Tıklama ile oynatma/durdurma
  void _togglePlayPause() {
    if (_chewieController != null) {
      setState(() {
        if (_chewieController!.isPlaying) {
          _chewieController!.pause();
          _isManuallyPaused = true; // Manuel durdurma olarak işaretle
        } else {
          _chewieController!.play();
          _isManuallyPaused =
              false; // Manuel oynatma, otomatik kontrolü serbest bırak
        }
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized && _chewieController != null
        ? VisibilityDetector(
            key: Key(widget.url),
            onVisibilityChanged: (visibilityInfo) {
              if (_chewieController != null) {
                if (visibilityInfo.visibleFraction > 0.9 &&
                    !_isManuallyPaused) {
                  // Sadece manuel olarak durdurulmadıysa oynat
                  _chewieController!.play();
                } else if (visibilityInfo.visibleFraction <= 0.9) {
                  _chewieController!.pause();
                }
              }
            },
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover, // Ekranı tamamen kaplar, kırpma yapar
                      child: SizedBox(
                        width: _videoPlayerController.value.size.width,
                        height: _videoPlayerController.value.size.height,
                        child: Chewie(controller: _chewieController!),
                      ),
                    ),
                  ),
                  if (_chewieController!.isPlaying == false &&
                      _isManuallyPaused)
                    const Center(
                      child: Icon(
                        Iconsax.play_circle,
                        color: Colors.white,
                        size: 90,
                      ),
                    ),
                ],
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
