import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Orderstatus extends StatefulWidget {
  const Orderstatus({super.key});

  @override
  State<Orderstatus> createState() => _OrderstatusState();
}

class _OrderstatusState extends State<Orderstatus> {

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final orderId = prefs.getString('id');
    print('Retrieved user ID: $orderId'); 
    return orderId;
  }

  void _updateOrderStatus() async {
    final userId = await _getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User not logged in')),
      );
      return;
    }
    try {
      final response = await http.put(
        Uri.parse('http://192.168.1.4:8081/updateOrder/$userId'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_status': 'delivered', 
        }),
      );

      print('Response status: ${response.statusCode}'); 
      print('Response body: ${response.body}'); 

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to delivered')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating order status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Order Status',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _updateOrderStatus, 
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, 
            foregroundColor: Colors.white, 
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), 
            ),
          ),
          child: Text('Order Received'),
        ),
      ),
    );
  }
}
