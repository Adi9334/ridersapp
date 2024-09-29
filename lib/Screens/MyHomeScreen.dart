import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridersapp/Screens/global.dart';
import 'OrderSummary.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  String _selectedFilter = '';
  bool _showServiceButtons = false;
  String _selectedServiceFilter = ''; // State to control selected service button

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Home Screen',
          style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 25,
            ),
        ),
      ),
      body: Container(
        color: Colors.grey[350],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'Active';
                            _showServiceButtons = true;
                            _selectedServiceFilter = ''; // Reset service filter
                          });
                          filterActiveOrders();
                        },
                        child: const Text('Active'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedFilter == 'Active' ? Colors.blue : Colors.white,
                          foregroundColor: _selectedFilter == 'Active' ? Colors.white : Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'Completed';
                            _showServiceButtons = false;
                            _selectedServiceFilter = ''; // Reset service filter
                          });
                          filterCompletedOrders();
                        },
                        child: const Text('Completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedFilter == 'Completed' ? Colors.blue : Colors.white,
                          foregroundColor: _selectedFilter == 'Completed' ? Colors.white : Colors.black,
                          shape: const RoundedRectangleBorder(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'Cancelled';
                            _showServiceButtons = false;
                            _selectedServiceFilter = ''; // Reset service filter
                          });
                          filterCancelledOrders();
                        },
                        child: const Text('Cancelled'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedFilter == 'Cancelled' ? Colors.blue : Colors.white,
                          foregroundColor: _selectedFilter == 'Cancelled' ? Colors.white : Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_showServiceButtons)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedServiceFilter = 'Pickup';
                              });
                              filterPickupOrders();
                            },
                            child: const Text('Pickup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedServiceFilter == 'Pickup' ? Colors.blue : Colors.white,
                              foregroundColor: _selectedServiceFilter == 'Pickup' ? Colors.white : Colors.black,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedServiceFilter = 'Delivery';
                              });
                              filterDeliverOrders();
                            },
                            child: const Text('Delivery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedServiceFilter == 'Delivery' ? Colors.blue : Colors.white,
                              foregroundColor: _selectedServiceFilter == 'Delivery' ? Colors.white : Colors.black,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final name = user['username'] ?? 'No name provided';
                  final serviceName = user['service_name'] ?? 'No service available';
                  final orderStatus = user['order_status'] ?? 'Status not available';
                  final orderId = user['id']?.toString() ?? 'No Order ID';
                  final orderDate = user['order_date'] ?? '';

                  DateTime dateTime = DateTime.parse(orderDate);
                  final DateFormat outputFormat = DateFormat('yyyy-MM-dd');
                  String formattedDate = outputFormat.format(dateTime);

                  return Container(
                    child: Card(
                      elevation: 10,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            orderId.isNotEmpty ? orderId : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          name.isNotEmpty ? name : 'No name provided',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(serviceName.isNotEmpty ? serviceName : 'No service available'),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                text: 'Order Status: ',
                                style: const TextStyle(color: Colors.black, fontSize: 16),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: orderStatus,
                                    style: TextStyle(
                                      color: orderStatus == 'active'
                                          ? Colors.green
                                          : orderStatus == 'cancelled'
                                              ? Colors.red
                                              : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Order Date: $formattedDate',
                              style: const TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blueAccent,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderSummary(order: user.cast<String, dynamic>()),
                              ),
                            );
                          },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchOrders() async {
    print('fetchOrders called !!');
    const url = '${APIservice.address}/Orders/allOrders';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = response.body;
      final json = jsonDecode(body);
      if (json is Map<String, dynamic> && json['data'] is List) {
        setState(() {
          users = json['data'];
          filteredUsers = users;
        });
        print('fetchOrders completed !!');
      } else {
        print('Unexpected JSON structure: $json');
      }
    } else {
      print('Failed to load orders. Status code: ${response.statusCode}');
    }
  }

  void filterCompletedOrders() {
    setState(() {
      filteredUsers = users.where((user) {
        final orderStatus = user['order_status']?.toLowerCase();
        return orderStatus == 'delivered';
      }).toList();
    });
    print('Filtered to completed orders only');
  }

  void filterActiveOrders() {
    setState(() {
      filteredUsers = users.where((user) {
        final orderStatus = user['order_status']?.toLowerCase();
        return orderStatus == 'pickup' || orderStatus == 'delivery';
      }).map((user) {
        return {
          ...user,
          'order_status': 'active',
        };
      }).toList();
    });
    print('Filtered to active orders only');
  }

  void filterCancelledOrders() {
    setState(() {
      filteredUsers = users.where((user) {
        final orderStatus = user['order_status']?.toLowerCase();
        return orderStatus == 'cancelled';
      }).toList();
    });
    print('Filtered to cancelled orders only');
  }

  void filterPickupOrders() {
    setState(() {
      filteredUsers = users.where((user) {
        final orderStatus = user['order_status']?.toLowerCase();
        return orderStatus == 'pickup';
      }).toList();
    });
    print('Filtered to pickup orders only');
  }

  void filterDeliverOrders() {
    setState(() {
      filteredUsers = users.where((user) {
        final orderStatus = user['order_status']?.toLowerCase();
        return orderStatus == 'delivery';
      }).toList();
    });
    print('Filtered to delivery orders only');
  }
}
