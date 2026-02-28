import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/product_provider.dart';
import 'providers/stock_out_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => StockOutProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, tp, __) => MaterialApp(
          title:                      AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme:                      AppTheme.light,
          darkTheme:                  AppTheme.dark,
          themeMode:                  tp.mode,
          locale:                     const Locale('pt', 'BR'),
          initialRoute:               AppRoutes.splash,
          routes: {
            AppRoutes.splash:         (_) => const SplashScreen(),
            AppRoutes.login:          (_) => const LoginScreen(),
            AppRoutes.register:       (_) => const RegisterScreen(),
            AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
            AppRoutes.home:           (_) => const HomeScreen(),
          },
        ),
      ),
    );
  }
}