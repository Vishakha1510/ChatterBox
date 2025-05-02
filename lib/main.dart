import 'package:chatterbox/views/screens/chat_page.dart';
import 'package:chatterbox/views/screens/homepage.dart';
import 'package:chatterbox/views/screens/login_page.dart';
import 'package:chatterbox/views/screens/signup.dart';
import 'package:chatterbox/views/screens/splash_screen.dart';
import 'package:chatterbox/views/screens/user_authentications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    GetMaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashScreen(),
        'user_choice': (context) => UserChooseAuthentication(),
        'login': (context) => LoginPage(),
        'signup': (context) => SignupPage(),
        'home': (context) => Homepage(),
        'chat_page': (context) => ChatPage(),
      },
    ),
  );
}
