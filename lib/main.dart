import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gold_scheme/core/constants/app_string/app_strings.dart';
import 'package:gold_scheme/core/router/app_router.dart';
import 'package:gold_scheme/core/theme/app_theme.dart';
import 'package:gold_scheme/core/theme/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: _getDesignSize(context),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, child) {
        return MaterialApp.router(title: AppStrings.app.appName, debugShowCheckedModeBanner: false, theme: AppTheme.light, darkTheme: AppTheme.dark, themeMode: themeMode, routerConfig: router);
      },
    );
  }

  Size _getDesignSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Tablet design size
    if (width >= 600) {
      return const Size(834, 1194); // iPad
    }

    // Phone design size
    return const Size(375, 812); // iPhone X/11/12/13
  }
}
