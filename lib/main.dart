import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hyend/controllers/theme_controller.dart';
import 'package:hyend/pages/home.dart';
import 'package:hyend/pages/onboarding.dart';
import 'package:hyend/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Theme controller lives for the whole app.
  final themeCtrl = Get.put(ThemeController(), permanent: true);

  runApp(MyApp(initialMode: themeCtrl.themeMode));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialMode;
  const MyApp({super.key, required this.initialMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HyEnd',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: initialMode,
      initialRoute: '/',
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700),
      getPages: [
        GetPage(name: '/', page: () => const Onboarding()),
        GetPage(name: '/onboarding', page: () => const Onboarding()),
        GetPage(name: '/home', page: () => const HomePage()),
      ],
    );
  }
}
