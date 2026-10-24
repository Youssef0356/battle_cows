import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'presentation/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/premium_service.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load saved settings & entitlements first.
  await LocaleController.instance.initialize();
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
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Battle Cows',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: LocaleController.instance.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
