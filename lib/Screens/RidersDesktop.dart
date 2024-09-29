import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class Ridersdesktop extends StatefulWidget {
  const Ridersdesktop({super.key});

  @override
  State<Ridersdesktop> createState() => _RidersdesktopState();
}

class _RidersdesktopState extends State<Ridersdesktop> {
  int totalItems = 0;
  int totalDeliveredItems = 0;
  int totalActiveItems = 0;
  int totalCancelledItems = 0;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Center(child: Text('Riders Dashboard')),
      ),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.5), // Lighter color with low opacity
                BlendMode.modulate, // Blend mode to lighten the image
              ),
              child: Image.asset(
                '',
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildCard('Total Items', totalItems, Colors.blueAccent),
                    const SizedBox(height: 16),
                    buildCard('Total Delivered Items', totalDeliveredItems, Colors.green),
                    const SizedBox(height: 16),
                    buildCard('Total Active Items', totalActiveItems, Colors.orange),
                    const SizedBox(height: 16),
                    buildCard('Total Cancelled Items', totalCancelledItems, Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(String title, int count, Color color) {
    return Card(
      elevation: 8,
      child: Container(
        height: 100, // Fixed height for all cards
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color.withOpacity(0.1),
        ),
        child: Center(
          child: Text(
            '$title: $count',
            style: GoogleFonts.mulish(
              color: color,
              fontSize: 20, // Adjust font size as needed
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> fetchOrders() async {
    const url = 'http://192.168.1.14:8081/laundry/apis/Orders/allOrders';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = response.body;
      final json = jsonDecode(body);
      if (json is Map<String, dynamic> && json['data'] is List) {
        setState(() {
          final orders = json['data'];
          totalItems = orders.length;
          totalDeliveredItems = orders.where((order) => order['order_status']?.toLowerCase() == 'delivered').length;
          totalActiveItems = orders.where((order) => order['order_status']?.toLowerCase() == 'active').length;
          totalCancelledItems = orders.where((order) => order['order_status']?.toLowerCase() == 'cancelled').length;
        });
        print('Orders fetched successfully!');
      } else {
        print('Unexpected JSON structure: $json');
      }
    } else {
      print('Failed to load orders. Status code: ${response.statusCode}');
    }
  }
}
