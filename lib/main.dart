import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animemes/video_service.dart';
import 'core/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/views/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/utils/constants.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) async{
    int theme = prefs.getInt('theme') ?? 1;
    await Firebase.initializeApp();
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        builder: (_) => ThemeNotifier(themes[theme]),
        child: MaterialApp(
          theme: themes[theme],
          title: 'Animemes',
          debugShowCheckedModeBanner: false,
          routes: {
            '/home': (context) => HomePage(),
          },
          home: HomePage(),
        ),
      ),
    );
  });
}
