import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_project/projectlist.dart';
import 'package:to_do_list_project/saveproject.dart';
import 'OnscreenScreen.dart';
import 'ProjectDetail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: isFirstTime ? '/' : '/ProjectList',
      routes: {
        '/': (context) => OnscreenScreen(),
        '/SaveProject': (context) => SaveProject(),
        '/ProjectList': (context) => const ProjectList(),// Pass empty list
        '/ProjectDetail': (context) => ProjectDetail(project: {},),

      },
    );
  }
}