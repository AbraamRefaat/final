import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Service/language_service.dart';
import 'package:untitled2/Views/MainNavigationPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _initializeApp();
    super.initState();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize language service
      final languageService = Get.find<LanguageService>();
      await languageService.loadSavedLanguage();

      // Wait for 3 seconds then navigate
      await Future.delayed(Duration(seconds: 3));
      Get.off(() => MainNavigationPage());
    } catch (e) {
      // Fallback: navigate after 3 seconds even if language service fails
      await Future.delayed(Duration(seconds: 3));
      Get.off(() => MainNavigationPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Stack(
          children: [
            Image.asset(
              'images/$splashLogo',
              width: Get.width,
              height: Get.height,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(child: CupertinoActivityIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
