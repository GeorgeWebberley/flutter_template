import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/providers/local_notification_provider.dart';
import 'package:flutter_firebase_template/providers/local_storage_provider.dart';
import 'package:flutter_firebase_template/providers/push_notification_provider.dart';
import 'package:flutter_firebase_template/providers/share_provider.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/widgets/wrapper.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();

  // Get the environment from the provided arguments. Default to 'development' if none passed.
  try {
    String env = const String.fromEnvironment("ENVIRONMENT",
        defaultValue: 'development');
    assert(env == 'development' || env == 'staging' || env == 'production');
    // load the environment variables
    await dotenv.load(fileName: 'dotenv.$env');
  } catch (error) {
    debugPrint(error.toString());
  }

  LocalStorageProvider localStorageProvider = LocalStorageProvider();
  ShareProvider shareProvider = ShareProvider();
  LocalNotificationProvider localNotificationProvider =
      LocalNotificationProvider();
  await localNotificationProvider.initialize();
  PushNotificationProvider pushNotificationProvider =
      PushNotificationProvider(localStorageProvider: localStorageProvider);
  AuthService authService = AuthService();
  await pushNotificationProvider.init();

  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(
      providers: [
        Provider<PushNotificationProvider>(
            create: (context) => pushNotificationProvider),
        Provider<LocalStorageProvider>(
            create: (context) => localStorageProvider),
        Provider<AuthService>(create: (context) => authService),
        Provider<ShareProvider>(create: (context) => shareProvider),
        Provider<LocalNotificationProvider>(
          create: (_) => localNotificationProvider,
        )
      ],
      child: MyApp(authService: authService),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.authService});

  final AuthService authService;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
      initialData: null,
      value: authService
          .user, // A stream, for the app user so we can check auth status in real time
      child: MaterialApp(
        title: 'Nutriveat',
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
        theme: ThemeData(
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primary,
            )),
        // Wrapper checks if user is logged in or not, and navigates accordingly
        home: const Wrapper(),
      ),
    );
  }
}
