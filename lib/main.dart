import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:se7eti/core/utils/themes.dart';
import 'package:se7eti/feature/intro/splash_view.dart';

void main() {
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