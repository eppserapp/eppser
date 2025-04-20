import 'package:eppser/Web/WebLandingPage.dart';
import 'package:eppser/Web/WebLandingPageMobile.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout({super.key});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return const WebLandingPage();
      } else {
        return const WebLandingPageMobile();
      }
    });
  }
}
