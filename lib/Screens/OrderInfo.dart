import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ridersapp/Screens/OrderSummary.dart';
import 'package:ridersapp/Screens/PickupDelivery.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ridersapp/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Orderinfo extends StatefulWidget {
  final Map<String, dynamic> order;

  const Orderinfo({Key? key, required this.order}) : super(key: key);

  @override
  State<Orderinfo> createState() => _OrderinfoState();
}

class _OrderinfoState extends State<Orderinfo> {
  bool isOrderinfoSelected = true;
  Map<String, dynamic>? address;

  @override
  void initState() {
    super.initState();
    _fetchAddress(widget.order['address_id']);
  }


  int selectedTab = 0;

  // Function to update the selected tab
  void _selectTab(int index) {
    setState(() {
      selectedTab = index;
    });
  }


  Future<void> _fetchAddress(int id) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.53:8081/laundry/apis/Address/address/$id'));

      if (response.statusCode == 200) {
        print(response.body); 
        setState(() {
          address = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load address');
      }
    } catch (e) {
      print(e);
    }
  }


  double calculateTotalPrice() {
  if (widget.order['order_items'] == null) return 0;

  double total = 0.0;
  for (var item in widget.order['order_items']) {
    double quantity = item['order_item_quantity']?.toDouble() ?? 0;
    double price = item['order_item_price']?.toDouble() ?? 0;
    total += quantity * price;
  }
  return total;
}



  Future<void> navigateToGoogleMap() async {
    // Address for demonstration
    String address = _fetchAddress(widget.order['address_id']) as String;

    // Encode the address to be URL-friendly
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';

    final Uri url = Uri.parse(googleMapsUrl);

    // Attempt to launch the URL
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  

  String formatDate(String dateTimeStr) {
  try {
    DateTime dateTime = DateTime.parse(dateTimeStr);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  } catch (e) {
    print('Error parsing date: $e');
    return 'Invalid date';
  }
}

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch $callUri';
    }
  }

  Future<void> openGoogleMap() async {
  String aaddress = ' ${address!['area']} ${address!['street']} ${address!['city']}, ${address!['state']} - ${address!['pincode']}';
  print(aaddress);
  String googleMapsUrl =
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(aaddress)}';

  final Uri url = Uri.parse(googleMapsUrl);
  
  // Use the updated methods from url_launcher package
  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication, // Use this mode to launch in an external browser
    );
  } else {
    throw 'Could not launch $url';
  }
}

Container myStackContainer(){
  return Container(
    child: Stack(
      children: [
        
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final String fullName = address?['full_name'] ?? 'Unknown'; 
  final String phoneNumber = address?['phone_number'] ?? ''; 
    final int addressId = widget.order['address_id'] ?? 0;
    final String? orderDate = widget.order['order_date'];
    final String? orderDeliveredAt = widget.order['order_delivered_at'];
    final String formattedOrderDate = formatDate(orderDate ?? '');
    final String formattedOrderDeliveredAt = orderDeliveredAt != null ? formatDate(orderDeliveredAt) : 'N/A';


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'OrderID 205',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              
            );
          },
        ),
      ),
      body: Container(
  padding: EdgeInsets.only(top: 10),
  child: Column(
    children: [
      Container(
        width: double.infinity,
        height: 150,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            // Add decoration here if needed
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Ordered By\n',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextSpan(
                            text: ' $fullName',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(0.5), // Adjust the padding as needed
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color of the circle
                        border: Border.all(
                          color: Colors.blue, // Border color
                          width: 2, // Border width
                        ),
                        shape: BoxShape.circle, // Makes the container a circle
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.call,
                          color: Colors.blue, // Icon color
                        ),
                        onPressed: phoneNumber.isNotEmpty
                            ? () => _makePhoneCall(phoneNumber)
                            : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Ordered Status\n',
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextSpan(
                              text: 'Ready to Deliver',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(0.5), // Adjust the padding as needed
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color of the circle
                        border: Border.all(
                          color: Colors.blue, // Border color
                          width: 2, // Border width
                        ),
                        shape: BoxShape.circle, // Makes the container a circle
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.local_shipping,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          // Implement delivery functionality here
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(height: 20),
      Container(
        height: 65,
        width: double.infinity,
        padding: EdgeInsets.only(top: 15),
        color: Colors.grey[300],
        child: Stack(
          children: [
            // Background cover for selected button
            Positioned(
              left: isOrderinfoSelected ? 0 : MediaQuery.of(context).size.width / 2,
              right: isOrderinfoSelected ? MediaQuery.of(context).size.width / 2 : 0,
              child: Container(
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isOrderinfoSelected = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isOrderinfoSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Order Info',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isOrderinfoSelected ? Colors.blue : Colors.grey,
                            ),
                          ),
                          if (isOrderinfoSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 4.0),
                              height: 2,
                              width: 80,
                              color: Colors.blue,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isOrderinfoSelected = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: !isOrderinfoSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Cloth List',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: !isOrderinfoSelected ? Colors.blue : Colors.grey,
                            ),
                          ),
                          if (!isOrderinfoSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 4.0),
                              height: 2,
                              width: 80,
                              color: Colors.blue,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Conditionally displaying order information or blank container
       

    Expanded(
      child: isOrderinfoSelected == true 
        ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Container(
              height: 80,
              width: double.infinity,
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          child: Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Pickup Date\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey, // Style for the "Pickup Date" text
                                      ),
                                    ),
                                    TextSpan(
                                      text: formattedOrderDate,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 13 // Style for the date text
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: !isOrderinfoSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          child: Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Delivery\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey, // Style for the "Pickup Date" text
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Within 2 or 3 Days',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 13 // Style for the date text
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
            Container(
              color: Colors.grey[300], // Background color
              child: SizedBox(
                width: double.infinity,
                height: 5,
              ),
            ),

              Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup Address and Order Date
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'Pick up Address',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey, 
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      address == null
                          ? const CircularProgressIndicator()
                          : Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      //const Spacer(),
                                      Expanded(
                                        child: Text(
                                          'Arriving at ${widget.order['order_delivery_slot']}',
                                          style: const TextStyle(color: Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    ' ${address!['area']} ${address!['street']} ${address!['city']}, ${address!['state']} - ${address!['pincode']}\nPhone: ${address!['phone_number']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.map, color: Colors.blue), // Map icon or any other icon
                      onPressed: () {
                        // Define the navigation action here
                        // For example, open a map application
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => openGoogleMap()), // Replace with your target screen
                        // );
                        openGoogleMap();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey[300], 
              child: SizedBox(
                width: double.infinity,
                height: 5,
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Container(
                  alignment: Alignment.centerLeft, 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, 
                    children: [
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.left, 
                          text: TextSpan(
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              height: 1.5, 
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Payment\n ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextSpan(
                                text: '₹ ${calculateTotalPrice().toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: '\n${widget.order['order_payment_mode'] ?? "N/A"}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10), 
                      ElevatedButton(
                        onPressed: () {
                          // Define your onPressed logic here for viewing billing
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, 
                          foregroundColor: Colors.blue, 
                          side: BorderSide(
                            color: Colors.blue, 
                            width: 1.0, 
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), 
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
                          textStyle: TextStyle(
                            color: Colors.blue, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          "View Billing",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
             Container(
              height: 60,
              padding: EdgeInsets.only(right: 16.0, left: 16.0, top: 8, bottom: 4),
              child: SizedBox.expand(
                child: ElevatedButton(
                  onPressed: () {
                    // Define your onPressed logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color (blue)
                    foregroundColor: Colors.white, // Foreground color (white)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Border radius (optional)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjust padding for size
                  ),
                  child: Text(
                    'Mark Delivered', // Button text
                  style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                  ),
                ),
              ),
            )

              ],
            )
            : Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Container(
  padding: EdgeInsets.all(16.0),
  child: Column(
    children: [
      // Mapping order items to display
      ...widget.order['order_items']?.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Image.network(
                'http://192.168.1.53:8081/laundry/apis${item['order_item_imageURL']}',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '${item['order_item_quantity']} X ${item['order_item_name']}',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 15), // Space between item and service
                        Expanded(
                          child: Text(
                            '${widget.order['service_name']}',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 15), // Space between service and price
                        Expanded(
                          child: Text(
                            '          ₹${(item['order_item_quantity'] ?? 0) * (item['order_item_price'] ?? 0)}',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2), // Space between rows if needed
                  ],
                ),
              ),
            ],
          ),
        );
      })?.toList() ?? [],

      // Display the total price
      Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out children
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${widget.order['order_payment_mode'] ?? "N/A"}',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '₹ ${calculateTotalPrice().toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),





      Container(
        height: 60,
        padding: EdgeInsets.only(right: 16.0, left: 16.0, top: 8, bottom: 4),
        child: SizedBox.expand(
          child: ElevatedButton(
            onPressed: () {
              // Define your onPressed logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Background color (blue)
              foregroundColor: Colors.white, // Foreground color (white)
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Border radius (optional)
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjust padding for size
            ),
            child: Text(
              'Mark Delivered', // Button text
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ),
      )

      ],
    ),
    
    ),

    
    
    ],
  ),
),

   );
  }
}