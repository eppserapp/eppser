import 'package:eppser/Pages/bottomBar.dart';
import 'package:eppser/Pages/landing.dart';
import 'package:eppser/providers/dataIndexProvider.dart';
import 'package:eppser/providers/phoneProvider.dart';
import 'package:eppser/providers/themeProvider.dart';
import 'package:eppser/providers/userProvider.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  MobileAds.instance.initialize();
  String storageLocation = (await getApplicationDocumentsDirectory()).path;
  await FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 7));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => phoneProvider()),
        ChangeNotifierProvider(create: (_) => themeProvider()),
        ChangeNotifierProvider(create: (_) => dataIndexProvider())
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('zh'),
          Locale('he'),
          Locale('ru'),
          Locale('fr', 'BE'),
          Locale('fr', 'CA'),
          Locale('ja'),
          Locale('de'),
          Locale('hi'),
          Locale('ar'),
        ],
        locale: const Locale('tr'),
        debugShowCheckedModeBanner: false,
        title: 'eppser',
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return bottomBar();
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            }
            return const LandingScreen();
          },
        ),
      ),
    );
  }
}
