import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OnscreenScreen extends StatelessWidget {
  const OnscreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/ellipse.png',
              width: 150,
              height: 150,
            ),
          ),
          const Positioned(
            top: 54,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'To-Do List',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3FBFBF),
                ),
              ),
            ),
          ),
          Center(
            heightFactor: 247,
            widthFactor: 21,
            child: Image.asset(
              'assets/NBOOK.png',
              width: 350,
              height: 350,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isFirstTime', false);
                  Navigator.pushReplacementNamed(context, '/ProjectList');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FBFBF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Let's Start",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 40),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF3FBFBF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}