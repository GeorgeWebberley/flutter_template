import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/providers/local_storage_provider.dart';
import 'package:flutter_firebase_template/providers/push_notification_provider.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/widgets/wrapper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  PushNotificationProvider pushNotificationProvider =
      PushNotificationProvider(localStorageProvider: localStorageProvider);
  await pushNotificationProvider.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<PushNotificationProvider>(
            create: (context) => pushNotificationProvider),
        Provider<LocalStorageProvider>(
            create: (context) => localStorageProvider)
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
      initialData: null,
      value: AuthService()
          .user, // A stream, for the app user so we can check auth status in real time
      child: MaterialApp(
        title: 'My Personal App',
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
