import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/auth/phone_login_screen.dart';
import 'screens/auth/otp_verify_screen.dart';
import 'screens/auth/name_setup_screen.dart';
import 'screens/customer/home_screen.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await NotificationService.instance.initialize();

  final authService = AuthService();
  await authService.init();

  final storage = await StorageService.getInstance();
  final isDarkMode = storage.getDarkMode();

  runApp(NoorBeautyApp(
    authService: authService,
    isDarkMode: isDarkMode,
  ));
}

class NoorBeautyApp extends StatelessWidget {
  final AuthService authService;
  final bool isDarkMode;

  const NoorBeautyApp({
    super.key,
    required this.authService,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider(create: (_) => BookingService()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        builder: (context, child) =>
            AppTheme.applyFontFamily(context, child ?? const SizedBox.shrink()),
        initialRoute: authService.isLoggedIn ? '/home' : '/phone-login',
        // Force the initial navigation stack to contain exactly ONE route.
        // Flutter otherwise expands a path like '/home' into ['/', '/home'],
        // and the phantom '/' falls through to _generateRoute's default
        // (the login screen) — leaving login sitting beneath Home so a back
        // press looks like a logout. This guarantees Home (or login) is the
        // true root.
        onGenerateInitialRoutes: (initialRouteName) {
          final route = _generateRoute(RouteSettings(name: initialRouteName));
          return route != null ? [route] : <Route<dynamic>>[];
        },
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/phone-login':
        return _pageRoute(const PhoneLoginScreen(), settings);
      case '/otp-verify':
        return _pageRoute(const OtpVerifyScreen(), settings);
      case '/name-setup':
        return _pageRoute(const NameSetupScreen(), settings);
      case '/home':
        return _pageRoute(const HomeScreen(), settings);
      default:
        return _pageRoute(const PhoneLoginScreen(), settings);
    }
  }

  PageRouteBuilder<dynamic> _pageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
