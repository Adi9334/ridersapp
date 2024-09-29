import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:ridersapp/Screens/global.dart';
import 'package:ridersapp/Screens/Orderinfo.dart'; // Import your Orderinfo.dart page
import 'package:ridersapp/Screens/MyWallet.dart'; // Import MyWallet.dart
import 'package:shared_preferences/shared_preferences.dart';

class Pickupdelivery extends StatefulWidget {
  const Pickupdelivery({super.key});

  @override
  State<Pickupdelivery> createState() => _PickupdeliveryState();
}

class _PickupdeliveryState extends State<Pickupdelivery> {
  List<dynamic> assignedOrders = [];
  List<dynamic> completedOrders = [];
  bool isLoading = false;
  bool isAssignedSelected = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final id = await prefs.getString('userid');
    try {
      final response = await http.get(Uri.parse('${APIservice.address}/Orders/getOrder/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (mounted) {
          setState(() {
            assignedOrders = data.where((order) => order['order_status'] != 'delivered').toList();
            completedOrders = data.where((order) => order['order_status'] == 'delivered').toList();
            print('Assigned Orders: $assignedOrders'); 
            print('Completed Orders: $completedOrders');
          });
        }
      } else {
        print('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> markAsDelivered(String orderId) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.1.3:8081/laundry/apis/Orders/markDelivered/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_status': 'delivered'}),
      );

      if (response.statusCode == 200) {
        // Refresh orders after marking as delivered
        fetchOrders();
      } else {
        print('Failed to mark as delivered: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  String formatDate(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      String formattedTime = DateFormat('HH:mm:ss').format(dateTime);
      return '$formattedDate\n$formattedTime';
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            'Pickup & Delivery',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(), // Show loading indicator
            )
      : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAssignedSelected = true;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        'Assigned',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isAssignedSelected ? Colors.blue : Colors.grey,
                        ),
                      ),
                      if (isAssignedSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          height: 2,
                          width: 80,
                          color: Colors.blue,
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAssignedSelected = false;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        'Completed',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: !isAssignedSelected ? Colors.blue : Colors.grey,
                        ),
                      ),
                      if (!isAssignedSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          height: 2,
                          width: 80,
                          color: Colors.blue,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: isAssignedSelected ? assignedOrders.length : completedOrders.length,
              itemBuilder: (context, index) {
                final order = isAssignedSelected ? assignedOrders[index] : completedOrders[index];
                return GestureDetector(
                  onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Orderinfo(order : order), 
                          ),
                        );
                      },
                child: SizedBox(
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0), // Adjust the padding as needed
                              decoration: BoxDecoration(
                                color: Colors.blue, // Background color of the circle
                                shape: BoxShape.circle, // Makes the container a circle
                              ),
                              child: Icon(
                                Icons.local_shipping,
                                color: Colors.white, // Icon color inside the blue circle
                                size: 30,
                              ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isAssignedSelected? 'Ready to Deliver' : 'Delivered', style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),),
                                  SizedBox(height: 5,),
                                  RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.normal, // Default style for the text
                                      color: Colors.black, // Text color
                                      fontSize: 16, // Font size
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Order ID: ',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15 // Bold style for the label
                                        ),
                                      ),
                                      TextSpan(
                                          text: order['id'].toString(), // Convert the int to a String
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.normal, 
                                            fontSize: 13// Normal style for the ID
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5,),
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.normal, // Default style for the text
                                      color: Colors.black, // Text color
                                      fontSize: 16, // Font size
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Date & Time: ',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15 // Bold style for the label
                                        ),
                                      ),
                                      TextSpan(
                                        text: formatDate(order['order_date']),
                                        style: GoogleFonts.nunito(
                                          fontSize: 13,
                                          fontWeight: FontWeight.normal, // Normal style for the date
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            SizedBox(height: 5,),
                            RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.normal, // Default style for the text
                                      color: Colors.black, // Text color
                                      fontSize: 15, // Font size
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Status: ',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold, // Bold style for the label
                                        ),
                                      ),
                                      TextSpan(
                                        text: order['order_status'],
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13 // Normal style for the date
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: isAssignedSelected
                                    ? () {
                                        markAsDelivered(order['id']);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAssignedSelected ? Colors.blue : Colors.grey, // Background color
                                  foregroundColor: Colors.white, // Text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                  elevation: 5,
                                ),
                                child: Text(
                                  isAssignedSelected ? 'Mark Delivered' : 'Delivered',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.0), // Space between button and price
                              Text(
                                'Total Price: \₹ ${order['total_price']}',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 13),
                                height: 50,
                                width: 150,
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Payment Mode: ',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold, // Bold style for the label
                                        ),
                                      ),
                                      TextSpan(
                                        text: order['order_payment_mode'] ?? "N/A", // Payment mode value or fallback
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13 // Normal style for the payment mode value
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
