import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'presentation/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/premium_service.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the saved premium entitlement first so ad requests are never made
  // for players who already bought "Remove Ads".
  await PremiumService.instance.loadEntitlement();
  await MobileAds.instance.initialize();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const BattleCowsApp());
  // Connect to the Play Store in the background; startup must not block on it.
  unawaited(PremiumService.instance.initialize());
}

class BattleCowsApp extends StatelessWidget {
  const BattleCowsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battle Cows',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
