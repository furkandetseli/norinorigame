import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/main_screen.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'localization/app_localizations.dart';
import 'services/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize AdMob
    await MobileAds.instance.initialize().then((initStatus) {
      debugPrint('AdMob SDK initialized: ${initStatus.adapterStatuses}');
    });
  } catch (e) {
    debugPrint('Error initializing AdMob: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(prefs),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AdService _adService;

  @override
  void initState() {
    super.initState();
    _adService = AdService();
    _initializeAdService();
  }

  Future<void> _initializeAdService() async {
    try {
      await _adService.initialize();
      debugPrint('AdService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AdService: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Norinori Puzzle',
          debugShowCheckedModeBanner: false,
          theme: settings.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MainScreen(),
        );
      },
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}