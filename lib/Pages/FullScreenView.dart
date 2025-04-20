import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenView extends StatefulWidget {
  final snap;
  final ispath;
  const FullScreenView({super.key, required this.snap, required this.ispath});

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: IconButton(
            icon: const Icon(
              Iconsax.arrow_left_2,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: widget.ispath
            ? Image.file(
                File(widget.snap),
                fit: BoxFit.cover,
              )
            : PhotoView(
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                imageProvider: CachedNetworkImageProvider(widget.snap),
              ),
      ),
    );
  }
}
