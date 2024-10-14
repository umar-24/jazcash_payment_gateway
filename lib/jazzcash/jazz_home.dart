import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:jazzcash_flutter/jazzcash_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ProductModel productModel = ProductModel("Product 1", "100");
  String integritySalt = "fwh30a4c39"; // Verify this is correct
  String merchantID = "MC130142"; // Verify this is correct
  String merchantPassword = "3xz2wba429"; // Verify this is correct
  String transactionUrl = "https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JazzCash Flutter Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Product Name : ${productModel.productName}"),
            Text("Product Price : ${productModel.productPrice}"),
            ElevatedButton(
              onPressed: () {
                _payViaJazzCash(productModel, context);
              },
              child: const Text("Purchase Now !"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payViaJazzCash(ProductModel element, BuildContext context) async {
    try {
      JazzCashFlutter jazzCashFlutter = JazzCashFlutter(
        merchantId: merchantID,
        merchantPassword: merchantPassword,
        integritySalt: integritySalt,
        isSandbox: true,
      );

      DateTime date = DateTime.now();

      JazzCashPaymentDataModelV1 paymentDataModelV1 = JazzCashPaymentDataModelV1(
        ppAmount: '${element.productPrice}',
        ppBillReference: 'refbill${date.year}${date.month}${date.day}${date.hour}${date.millisecond}',
        ppDescription: 'Product details ${element.productName} - ${element.productPrice}',
        ppMerchantID: merchantID,
        ppPassword: merchantPassword, // Ensure this is correct
        ppReturnURL: transactionUrl,
      );

      // Log the payment data model for debugging
      print("Payment Data Model: ${jsonEncode(paymentDataModelV1)}");

      // Start the payment
      final response = await jazzCashFlutter.startPayment(
        paymentDataModelV1: paymentDataModelV1,
        context: context,
      );

      // Log the response for debugging
      print("Response from JazzCash: $response"); 

      // Parse the response from JazzCash
      final jazzCashResponse = _parseJazzCashResponse(response);

      if (jazzCashResponse != null) {
        if (jazzCashResponse.status == "Success") {
          // Handle successful payment
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentStatusScreen(
                status: jazzCashResponse.status,
                message: jazzCashResponse.message,
              ),
            ),
          );
        } else {
          // Handle payment failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment failed: ${jazzCashResponse.message}")),
          );
        }
      } else {
        // Handle unexpected response type
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unexpected response from JazzCash. Please try again.")),
        );
      }
    } catch (err) {
      print("Error in payment: $err");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error in payment: $err")),
      );
    }
  }

  JazzCashResponse? _parseJazzCashResponse(dynamic response) {
    if (response is String) {
      if (response.isNotEmpty) {
        try {
          final jsonData = jsonDecode(response);
          return JazzCashResponse.fromJson(jsonData);
        } catch (e) {
          print("Error parsing JSON response: $e");
          return null;
        }
      } else {
        print("Empty response from JazzCash");
        return null;
      }
    } else if (response is Map<String, dynamic>) {
      return JazzCashResponse.fromJson(response);
    } else {
      print("Unexpected response type: ${response.runtimeType}");
      return null;
    }
  }
}

class ProductModel {
  String? productName;
  String? productPrice;

  ProductModel(this.productName, this.productPrice);
}

class JazzCashResponse {
  final String status; // Ensure these fields match the actual response
  final String message;

  JazzCashResponse({required this.status, required this.message});

  factory JazzCashResponse.fromJson(Map<String, dynamic> json) {
    return JazzCashResponse(
      status: json['pp_ResponseCode'] == "110" ? "Failed" : "Success", // Adjust as per your logic
      message: json['pp_ResponseMessage'] ?? 'No message available',
    );
  }
}

// Sample PaymentStatusScreen to display the payment result
class PaymentStatusScreen extends StatelessWidget {
  final String status;
  final String message;

  const PaymentStatusScreen({super.key, required this.status, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Status')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Payment Status: $status'),
            Text('Message: $message'),
          ],
        ),
      ),
    );
  }
}
