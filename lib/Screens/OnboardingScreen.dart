import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:ridersapp/Screens/LoginScreen.dart';
import 'package:ridersapp/main.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            OnBoardingSlider(
              finishButtonText: 'Get Started',
              onFinish: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              finishButtonStyle: FinishButtonStyle(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              controllerColor: Colors.blue,
              totalPage: 4,
              headerBackgroundColor: Colors.white,
              pageBackgroundColor: Colors.white,
              background: [
                Container(), // Placeholder for each page's background
                Container(),
                Container(),
                Container(),
              ],
              speed: 1.8,
              pageBodies: [
                _buildPageContent(
                  title: "Your Journey Begins Here",
                  description: "Get on the road and earn your way",
                  imagePath: 'assets/images/delivery1.jpg',
                ),
                _buildPageContent(
                  title: "Deliver More, Earn More",
                  description: "Start delivering and watch your earnings grow",
                  imagePath: 'assets/images/delivery2.png',
                ),
                _buildPageContent(
                  title: "On-demand Delivery",
                  description: "Start your day with a ride, end it with earnings",
                  imagePath: 'assets/images/delivery6.png',
                ),
                _buildPageContent(
                  title: "Start Your Adventure Today",
                  description: "Turn your passion for riding into profit",
                  imagePath: 'assets/images/delivery4.jpg',
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          width: 300, // Adjust the width as needed
          height: 300, // Adjust the height as needed
          fit: BoxFit.cover, // Adjust the fit as needed
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.brown,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
