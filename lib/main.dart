import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import 'RiverPod/connectivity_pod.dart';
import 'Screens/internetconnection/internetconnection.dart';
import 'Screens/splashscreen.dart';
import 'Utils/app_colors.dart';
import 'Utils/appdata_helper.dart';

MaterialColor buildMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;
  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: AppDataHelper.navKey,
          title: AppDataHelper.appName,
          theme: ThemeData(
            primarySwatch: buildMaterialColor(AppColors.primary),
            scaffoldBackgroundColor: AppColors.bgColor,
          ),
          builder: (context, child) {
            return ConnectivityWrapper(child: child!);
          },
          home: const MainScreen(),
        );
      },
    );
  }
}

class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityStatusProvider);

    return Stack(
      children: [
        child,
        if (connectivityStatus == ConnectivityStatus.isDisconnected)
          const InternetConnectionScreen(),
      ],
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        top: true,
        child: SplashScreen(),
      ),
    );
  }
}
