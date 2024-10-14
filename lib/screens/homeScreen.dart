import 'package:flutter/material.dart';
import 'package:jazzcash/jazzcash/jazz_cash.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(title: Text('Payments'),backgroundColor: Colors.transparent,),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Row(
                    children: [
                       Image.asset("assets/images/jazz-cash-logo.png"),
                    const SizedBox(width: 20,),
                    Text("Payment With JazzCash", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
                    ],
                   ),
                   IconButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> JazzCash()));
                   }, icon: Icon(Icons.arrow_forward))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}