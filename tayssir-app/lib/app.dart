import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/resources/resources.dart';
import 'package:tayssir/resources/theme/app_theme.dart';
import 'package:tayssir/router/routes_service.dart';
import 'package:tayssir/providers/settings/settings_provider.dart';
import 'package:tayssir/resources/theme/design_system.dart';
import 'package:tayssir/providers/theme/design_system_provider.dart';
import 'router/app_router.dart';

import 'package:upgrader/upgrader.dart';

void initImages(context) async {
  await precacheImage(const AssetImage(Images.subBg), context);
}

class BayanQuranApp extends ConsumerWidget {
  const BayanQuranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    initImages(context);
    final router = ref.watch(appRouterProvider);
    final ds = ref.watch(designSystemProvider);
    final darkDs = ref.watch(darkDesignSystemProvider);
    final settings = ref.watch(settingsNotifierProvider);
    
    final size = MediaQueryData.fromView(View.of(context)).size;
    final isDesktop = size.width > 800;

    return ScreenUtilInit(
      designSize: isDesktop ? size : const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp.router(
            routerConfig: router,
            title: 'بيان القرآن',
            builder: (context, child) {
              final builderObj = DevicePreview.appBuilder(context, child);
              
              if (kIsWeb) {
                return builderObj;
              }
              
              return UpgradeAlert(
                navigatorKey: router.routerDelegate.navigatorKey,
                showReleaseNotes: false,
                showIgnore: false,
                showLater: false,
                shouldPopScope: () => false,
                upgrader: Upgrader(
                  languageCode: 'ar',
                  minAppVersion: '2.2.0', // Matches new version 2.2.0+43
                  debugDisplayAlways: false,
                ),
                child: builderObj,
              );
            },
            locale: const Locale('ar'),
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme(ds, Brightness.light),
            darkTheme: AppTheme.theme(darkDs, Brightness.dark),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          ),
        );
      },
    );
  }
}
