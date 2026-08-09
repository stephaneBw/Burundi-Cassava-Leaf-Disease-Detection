// Shows the animated splash screen before entering the main app.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/routes.dart';
import '../../../core/constants/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.bgLight), context);
    precacheImage(const AssetImage(AppAssets.bgDark), context);
    precacheImage(const AssetImage(AppAssets.farmerGreet), context);
    precacheImage(const AssetImage(AppAssets.farmerResult), context);
  }

  Future<void> _initializeApp() async {
    // Keep the branded transition brief; service initialization already happens before runApp.
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.logo, width: 250, height: 250, fit: BoxFit.contain),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
