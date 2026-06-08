import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_mfa_screen.dart';
import 'screens/auth/email_verify_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
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
        initialRoute: _getInitialRoute(),
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  String _getInitialRoute() {
    if (authService.isAdminLoggedIn) return '/admin-dashboard';
    if (authService.isLoggedIn) return '/home';
    return '/login';
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _pageRoute(const LoginScreen(), settings);
      case '/signup':
        return _pageRoute(const SignupScreen(), settings);
      case '/verify-email':
        return _pageRoute(const EmailVerifyScreen(), settings);
      case '/home':
        return _pageRoute(const HomeScreen(), settings);
      case '/admin-login':
        return _pageRoute(const AdminLoginScreen(), settings);
      case '/admin-mfa':
        return _pageRoute(const AdminMfaScreen(), settings);
      case '/admin-dashboard':
        return _pageRoute(const AdminDashboardScreen(), settings);
      default:
        return _pageRoute(const LoginScreen(), settings);
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
