import 'package:flutter/material.dart';
import 'package:ridersapp/Screens/FindContacts.dart';
import 'package:ridersapp/Screens/LoginScreen.dart';
import 'package:ridersapp/Screens/MyHomeScreen.dart';
import 'package:ridersapp/Screens/MyWallet.dart';
import 'package:ridersapp/Screens/OnboardingScreen.dart';
import 'package:ridersapp/Screens/OrderInfo.dart';
import 'package:ridersapp/Screens/OrderStatus.dart';
import 'package:ridersapp/Screens/PickupDelivery.dart';
import 'package:ridersapp/Screens/ProfileScreen.dart';
import 'package:ridersapp/Screens/ResetPassword.dart';
import 'package:ridersapp/Screens/RidersDesktop.dart';
import 'package:ridersapp/Screens/SignupScreen.dart';
import 'package:ridersapp/Screens/TestApi.dart';
import 'package:ridersapp/Screens/mapPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const KEYLOGIN = "userid";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LaundryRider',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       
       //Testapi(),
       home: Findcontacts(),
       //Orderinfo(), // Pass a valid userId here

       //Pickupdelivery(),
       //Orderstatus(),
       //Mywallet(),
       //Resetpassword(),
       //SignupScreen(),
       //LoginScreen(),
      // Mappage(),
      //FutureBuilder<bool>(
      //   future: _checkLoginStatus(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Scaffold(
      //         body: Center(child: CircularProgressIndicator()),
      //       );
      //     } else {
      //       final isLoggedIn = snapshot.data ?? false;
      //       return isLoggedIn ? HomeScreen() : OnboardingScreen();
      //     }
      //   },
      // ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    var sharedPref = await SharedPreferences.getInstance();
    return sharedPref.containsKey(KEYLOGIN);
  }
}



// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), 
//     );
//   }
// }




class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Pickupdelivery(),
    Mywallet(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: List.generate(3, (index) {
          return BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _selectedIndex == index ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Image.asset(
                _getImageForIndex(index),
                color: _selectedIndex == index ? Colors.blue : Colors.grey,
                height: 24, // Adjust the height as needed
                width: 24,  // Adjust the width as needed
              ),
            ),
            label: _getLabelForIndex(index),
          );
        }),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,  // Required to show all icons and labels
      ),
    );
  }

  String _getImageForIndex(int index) {
    switch (index) {
      case 0:
        return 'assets/images/delivery_riders.png';
      case 1:
        return 'assets/images/wallet.png';
      case 2:
        return 'assets/images/profile.png';
      default:
        return 'assets/images/home.png';
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Riding';
      case 1:
        return 'Wallet';
      case 2:
        return 'Profile';
      default:
        return '';
    }
  }
}
