import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatterbox/utils/helpers/firebase_auth_helper.dart';
import 'package:flutter/material.dart';

class UserChooseAuthentication extends StatefulWidget {
  const UserChooseAuthentication({super.key});

  @override
  State<UserChooseAuthentication> createState() =>
      _UserChooseAuthenticationState();
}

class _UserChooseAuthenticationState extends State<UserChooseAuthentication> {
  final List<String> images = [
    'assets/1.png',
    'assets/2.png',
    'assets/logo.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to ChatterBox",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 30),
              CarouselSlider(
                items:
                    images.map((img) {
                      return Image.asset(
                        img,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      );
                    }).toList(),
                options: CarouselOptions(
                  height: 250,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  enlargeCenterPage: true,
                  enlargeFactor: 0.2,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text("Login", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text("Signup", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 15),
              ElevatedButton.icon(
                icon: Icon(Icons.person_pin, size: 24, color: Colors.white),
                onPressed: () async {
                  Map<String, dynamic> response =
                      await FirebaseAuthHelper.firebaseAuthHelper
                          .signInAsGuestUser();

                  if (response['user'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sign In Successfull"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      'home',
                      (route) => false,
                      arguments: response['user'],
                    );
                  } else if (response['error'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['error']),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sign In Failed"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(fontSize: 16),
                ),
                label: Text(
                  "Anonymous Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton.icon(
                icon: Icon(Icons.g_mobiledata, size: 28, color: Colors.white),
                onPressed: () async {
                  Map<String, dynamic> response =
                      await FirebaseAuthHelper.firebaseAuthHelper
                          .signInWithGoogle();

                  if (response['user'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sign In Successfull"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      'home',
                      (route) => false,
                      arguments: response['user'],
                    );
                  } else if (response['error'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['error']),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sign In Failed"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(fontSize: 16),
                ),
                label: Text(
                  "Google Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
