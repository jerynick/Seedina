import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seedina/login_page/setup/esp_conn_setup.dart';
import 'package:seedina/login_page/setup/selection_plant_step.dart';
import 'package:seedina/main_page/portalscreen.dart';
import 'package:seedina/main_page/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seedina/provider/rtdb_handler.dart';
import 'package:seedina/services/auth_check.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HandlingProvider()
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins'
        ),
        locale: const Locale('id', 'ID'),
        supportedLocales: const [
          Locale('id', 'ID'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: {
          '/': (context) => const SplashScreen(),
          '/authcheck': (context) => AuthCheck(),
          '/portal': (context) => const PortalScreen(),
          '/param': (context) => SetupPlant(),
          '/wifiSetup': (context) => WiFiConnSetup()
        },
      ),
    );
  }
}
