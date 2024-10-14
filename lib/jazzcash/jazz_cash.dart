import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JazzCash extends StatefulWidget {
  JazzCash({Key, key}) : super(key: key);

  @override
  _JazzCashState createState() => _JazzCashState();
}

class _JazzCashState extends State<JazzCash> {

  var responcePrice;
  bool isLoading = false;

  payment() async {
  setState(() {
    isLoading = true;
  });

  // JazzCash transaction details
  String dateandtime = DateFormat("yyyyMMddHHmmss").format(DateTime.now());
  String dexpiredate = DateFormat("yyyyMMddHHmmss").format(DateTime.now().add(const Duration(days: 1)));
  String tre = "T" + dateandtime;
  String pp_Amount = "50000"; // Amount in paisa
  String pp_BillReference = "billRef";
  String pp_Description = "Description for transaction";
  String pp_Language = "EN";
  String pp_MerchantID = "MC130142";
  String pp_Password = "3xz2wba429";
  String pp_ReturnURL = "https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction";
  String pp_ver = "1.1";
  String pp_TxnCurrency = "PKR";
  String pp_TxnDateTime = dateandtime.toString();
  String pp_TxnExpiryDateTime = dexpiredate.toString();
  String pp_TxnRefNo = tre.toString();
  String pp_TxnType = "MWALLET";
  String ppmpf_1 = "03005594509";
  String IntegritySalt = "fwh30a4c39";

  // Data concatenation for SecureHash
  String and = '&';
  String superdata = IntegritySalt + and +
      pp_Amount + and +
      pp_BillReference + and +
      pp_Description + and +
      pp_Language + and +
      pp_MerchantID + and +
      pp_Password + and +
      pp_ReturnURL + and +
      pp_TxnCurrency + and +
      pp_TxnDateTime + and +
      pp_TxnExpiryDateTime + and +
      pp_TxnRefNo + and +
      pp_TxnType + and +
      pp_ver + and +
      ppmpf_1;

  // SecureHash calculation using HMAC-SHA256
  var key = utf8.encode(IntegritySalt);
  var bytes = utf8.encode(superdata);
  var hmacSha256 = Hmac(sha256, key);
  Digest sha256Result = hmacSha256.convert(bytes);

  // Debugging: Print SecureHash and data being sent
  print("Data before hashing: $superdata");
  print("Generated SecureHash: $sha256Result");

  // Send the request to JazzCash API
  String url = 'https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction';
  var response = await http.post(Uri.parse(url),
      body: {
        "pp_Version": pp_ver,
        "pp_TxnType": pp_TxnType,
        "pp_Language": pp_Language,
        "pp_MerchantID": pp_MerchantID,
        "pp_Password": pp_Password,
        "pp_TxnRefNo": tre,
        "pp_Amount": pp_Amount,
        "pp_TxnCurrency": pp_TxnCurrency,
        "pp_TxnDateTime": dateandtime,
        "pp_BillReference": pp_BillReference,
        "pp_Description": pp_Description,
        "pp_TxnExpiryDateTime": dexpiredate,
        "pp_ReturnURL": pp_ReturnURL,
        "pp_SecureHash": sha256Result.toString(),
        "ppmpf_1": ppmpf_1
      });

  // Logging the response details
  print("Response Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  if (response.statusCode == 200) {
    var res = jsonDecode(response.body);
    var responseCode = res['pp_ResponseCode'];
    var responseMessage = res['pp_ResponseMessage'];

    if (responseCode == "000") {
      // Successful transaction
      responcePrice = res['pp_Amount'];
      Fluttertoast.showToast(msg: "Payment successful: $responcePrice");
    } else {
      // Transaction failed with error code and message
      Fluttertoast.showToast(msg: "Error: $responseMessage (Code: $responseCode)");
      print("Error Code: $responseCode, Message: $responseMessage");
    }
  } else {
    Fluttertoast.showToast(msg: "Request failed with status: ${response.statusCode}");
  }

  setState(() {
    isLoading = false;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                child: Center(
                    child: ElevatedButton(
                        onPressed: () {
                          payment();
                        },
                        child: Text("Payment With Jazz Cash"))),
              ));
  }
}
