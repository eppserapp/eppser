//                                                  بِسْــــــــــــــــــمِ اﷲِالرَّحْمَنِ اارَّحِيم
//                                                تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eppser/Pages/BottomBar.dart';
import 'package:eppser/Pages/LandingPage.dart';
import 'package:eppser/Providers/dataIndexProvider.dart';
import 'package:eppser/Providers/phoneProvider.dart';
import 'package:eppser/Providers/themeProvider.dart';
import 'package:eppser/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

class TimestampAdapter extends TypeAdapter<Timestamp> {
  @override
  final int typeId = 1;

  @override
  Timestamp read(BinaryReader reader) {
    return Timestamp.fromMillisecondsSinceEpoch(reader.read());
  }

  @override
  void write(BinaryWriter writer, Timestamp obj) {
    writer.write(obj.millisecondsSinceEpoch);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  themeProvider.loadTheme();
  await Hive.initFlutter();
  await Hive.openBox("userBox");
  await Hive.openBox('messageBox');
  Hive.registerAdapter(TimestampAdapter());
  await Hive.openBox('groupBox');
  await Hive.openBox('groupMessageBox');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings =
      const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await initializeDateFormatting('tr_TR', null);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => dataIndexProvider()),
    ChangeNotifierProvider(create: (_) => phoneProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eppser',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('tr', 'TR'),
      ],
      theme: Provider.of<ThemeProvider>(context).themeData,
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
    );
  }
}
