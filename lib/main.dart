import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:waajal_elek/pages/splash_screen_page.dart';
import 'package:waajal_elek/services/connectivity_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix certificat SSL sur Android physique
  HttpOverrides.global = MyHttpOverrides();


  await dotenv.load(fileName: '.env');



  await initializeDateFormatting('fr_FR', null);

  runApp(const WaajalElekApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class WaajalElekApp extends StatelessWidget {
  const WaajalElekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),

      ],
      child: MaterialApp(
        title: 'Waajal Ëlëk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        locale: const Locale('fr', 'FR'),

        supportedLocales: const [
          Locale('fr', 'FR'),
        ],

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],


        home: const SplashScreen(),
      ),
    );
  }
}
