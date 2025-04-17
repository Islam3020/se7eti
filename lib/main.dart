import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:se7eti/core/utils/themes.dart';
import 'package:se7eti/feature/intro/splash_view.dart';
import 'package:se7eti/firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const Se7eti());
}
class Se7eti extends StatelessWidget {
  const Se7eti({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(

      debugShowCheckedModeBanner: false,
       theme: AppThemes.lightTheme,
       locale:const  Locale('ar'),
        supportedLocales:const  [
          Locale('ar'),
        ],
        localizationsDelegates:const  [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
      home:const SplashView(),
    );
  }
}