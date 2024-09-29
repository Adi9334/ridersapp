import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Transaction extends StatefulWidget {

  const Transaction({Key? key}) : super(key: key);

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  Map<String, String>? transaction; // Single transaction instead of list
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTransaction(); 
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

  
  Future<void> _fetchTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userid');

    final url = 'http://192.168.1.53:8081/laundry/apis/rider_wallet_transactions/riderWalletTransaction/$id';

    try {
      final response = await http.get(Uri.parse(url));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Debug: Print parsed data
        print('Parsed data: $data');

        setState(() {
          transaction = {
            'date': data['created_at']?.toString() ?? 'N/A',
            'description': data['description']?.toString() ?? 'No description',
            'amount': '₹ ${data['amount']?.toString() ?? '0.00'}',
            'type': data['transaction_type']?.toString() ?? 'Unknown',
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load transaction';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "Transaction History",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Container(
        color: Colors.grey[300],
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage)) // Show error message if any
                : transaction == null || transaction!.isEmpty
                    ? Center(child: Text('No transaction found')) // Handle case where transaction is null
                    : Card(
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        elevation: 2,
                        child: ListTile(
                          tileColor: Colors.white,
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            transaction!['description']!,
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Date: ${formatDate(transaction?['date'] ?? '')}', 
                            style: GoogleFonts.nunito(
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                transaction!['amount']!,
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                transaction!['type']!,
                                style: GoogleFonts.nunito(
                                  color: transaction!['type'] == 'deposit' ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }
}
