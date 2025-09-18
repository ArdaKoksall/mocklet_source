import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mocklet_source/app/core/core.dart';
import 'package:mocklet_source/app/data/theme/app_theme.dart';
import 'package:mocklet_source/screens/first/login_screen.dart';
import 'package:mocklet_source/screens/first/signup_screen.dart';
import 'package:mocklet_source/screens/first/welcome_screen.dart';
import 'package:mocklet_source/screens/second/main_screen.dart';

import 'app/data/app_constants.dart';
import 'app/service/theme_service.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServiceProvider).themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: theme,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      supportedLocales: AppConstants.supportedLocales,
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/main': (context) => const MainScreen(),
      },
      initialRoute: ref.read(coreProvider).getRoute(),
    );
  }
}
