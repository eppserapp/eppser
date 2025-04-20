import 'package:flutter/material.dart';

class HoverableText extends StatefulWidget {
  final String text;

  const HoverableText({Key? key, required this.text}) : super(key: key);

  @override
  _HoverableTextState createState() => _HoverableTextState();
}

class _HoverableTextState extends State<HoverableText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: 24,
          color:
              _isHovered ? const Color.fromRGBO(0, 86, 255, 1) : Colors.white,
          fontWeight: FontWeight.bold,
        ),
        child: Text(widget.text),
      ),
    );
  }
}
