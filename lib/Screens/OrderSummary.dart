import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // To handle JSON decoding.
import 'package:http/http.dart' as http; // For making HTTP requests.

class OrderSummary extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderSummary({Key? key, required this.order}) : super(key: key);

  Future<Map<String, dynamic>> fetchAddress(int addressId) async {
    final response = await http.get(Uri.parse('http://192.168.1.4:8081/laundry/apis/Address/address/$addressId'));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load address');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> orderItems = order['order_items'] ?? [];
    final String orderDate = order['order_date'] ?? '';
    final int addressId = order['address_id'] ?? 0;

    DateTime dateTime = DateTime.parse(orderDate);
    final DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    String formattedDate = outputFormat.format(dateTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Center(child: Text('Order Summary')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order['id']}', style: GoogleFonts.lora()),
            Text('Service Name: ${order['service_name']}', style: GoogleFonts.lora()),
            Text('Username: ${order['username']}', style: GoogleFonts.lora()),
            Text('Email: ${order['email']}', style: GoogleFonts.lora()),
            Text('Order Date: $formattedDate', style: GoogleFonts.lora()),
            Text('Total Price: \$${order['total_price']}', style: GoogleFonts.lora()),
            Text('Order Status: ${order['order_status']}', style: GoogleFonts.lora()),
            const SizedBox(height: 16),
            Text('Address', style: GoogleFonts.lora().copyWith(fontSize: 20)),
            FutureBuilder<Map<String, dynamic>>(
              future: fetchAddress(addressId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Failed to load address');
                } else if (!snapshot.hasData) {
                  return const Text('No Address Found');
                } else {
                  final address = snapshot.data!;
                  return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                  color: Colors.grey[300]!, width: 2.0),
                            ),
                            surfaceTintColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        '${address['full_name']}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Expanded(
                                        child: Text(
                                          'Arriving at ${order['order_delivery_slot']}',
                                          style: TextStyle(
                                              color: Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '${address['street']} ${address['area']}${address['city']}, ${address['state']} - ${address['pincode']}\nPhone: ${address['phone_number']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Divider(),
                                  
          ])));
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Order Items:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: orderItems.length,
                itemBuilder: (context, index) {
                  final item = orderItems[index];
                  final imageUrl = 'http://192.168.1.4:8081/laundry/apis${item['order_item_imageURL']}';
                  
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      leading: Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      title: Text(item['order_item_name'] ?? 'No Name'),
                      subtitle: Text('Quantity: ${item['order_item_quantity']}'),
                      trailing: Text('\$${item['order_item_price']}'),
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
}
