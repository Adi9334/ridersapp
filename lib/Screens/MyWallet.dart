import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ridersapp/Screens/Transaction.dart'; // Import the Transaction page
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Mywallet extends StatefulWidget {
  const Mywallet({Key? key}) : super(key: key);

  @override
  State<Mywallet> createState() => _MywalletState();
}

class _MywalletState extends State<Mywallet> {
  bool _isPressed = false;
  double _ridersMoney = 0.0;
  double _ridersCoins = 0.0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRidersMoney(); 
  }

  Future<void> _fetchRidersMoney() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userid');

    if (id == null) {
      setState(() {
        _errorMessage = 'User ID not found';
        _isLoading = false;
      });
      return;
    }

    final url = 'http://192.168.1.53:8081/laundry/apis/rider_wallet/riderWallet/$id'; // Use id parameter

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _ridersMoney = double.tryParse(data['total_balance']) ?? 0.0;
          _ridersCoins = double.tryParse(data['coins']?.toString() ?? '0.0') ?? 0.0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load data';
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

  void _togglePaymentMethod() {
    setState(() {
      _isPressed = !_isPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.orange,
              child: Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        'Total Earned\n ₹ ${_ridersMoney.toStringAsFixed(2)}',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.white),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Colors.black,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Riders Money',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              '₹ ${_ridersMoney.toStringAsFixed(2)}',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(
                          color: Colors.grey,
                          thickness: 2,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: Colors.black,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Riders Coins',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              '₹ ${_ridersCoins.toStringAsFixed(2)}',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Transaction(),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(25),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'View all transactions',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          '>',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.all(15),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.white),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Your default payment method',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: IconButton(
                          icon: Icon(
                            _isPressed ? Icons.toggle_on : Icons.toggle_off,
                            color: _isPressed ? Colors.black : Colors.grey,
                            size: 45,
                          ),
                          onPressed: _togglePaymentMethod,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                // Define your onPressed logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.orange,
                padding: EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Withdraw Money',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
