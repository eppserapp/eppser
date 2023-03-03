import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class fullScreen extends StatelessWidget {
  final image;
  final tag;
  const fullScreen({Key? key, required this.image, this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var val = tag.toString();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 25,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          height: double.infinity,
          child: Hero(
            tag: '$val',
            child: Center(
              child: InteractiveViewer(
                maxScale: 20,
                minScale: 0.1,
                child: CachedNetworkImage(
                  height: double.infinity,
                  placeholderFadeInDuration: const Duration(microseconds: 1),
                  fadeOutDuration: const Duration(microseconds: 1),
                  fadeInDuration: const Duration(milliseconds: 1),
                  imageUrl: image,
                  fit: BoxFit.fitWidth,
                  placeholder: (context, url) => Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
