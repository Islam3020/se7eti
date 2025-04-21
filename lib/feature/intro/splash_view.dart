import 'package:flutter/material.dart';
import 'package:se7eti/core/enum/user_type_enum.dart';
import 'package:se7eti/core/functions/navigation.dart';
import 'package:se7eti/core/services/local_storage.dart';
import 'package:se7eti/feature/doctor/nav_bar_widget.dart';
import 'package:se7eti/feature/intro/onboarding/onboarding_view.dart';
import 'package:se7eti/feature/intro/welcome_view.dart';
import 'package:se7eti/feature/patient/patient_nav_bar.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  


  @override
  void initState() {
    super.initState();
   
    
    Future.delayed(const Duration(seconds: 3), () {
      bool isOnboardingShown =
          AppLocalStorage.getData(key: AppLocalStorage.isOnboardingShown)==true;
      if (AppLocalStorage.getData(key: AppLocalStorage.userType) != null) {
        if (AppLocalStorage.getData(key: AppLocalStorage.userType) == UserType.doctor.toString()) {
          pushReplacement(context, const DoctorNavBar());
        } else {
          pushAndRemoveUntil(context, const PatientNavBarWidget());
        }
      } else {
        if (isOnboardingShown) {
          pushReplacement(context, const WelcomeView());
        } else {
          pushReplacement(context, const OnboardingView());
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 250,
            ),
          ],
        ),
      ),
    );
  }
}