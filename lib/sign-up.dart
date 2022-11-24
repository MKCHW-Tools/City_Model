import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'main.dart';
import 'facilities.dart';

class SignupPage extends StatefulWidget {
  const SignupPage(this.userCredential, this.facilityId, this.menuId);
  final UserCredential userCredential;
  final String facilityId;
  final String menuId;
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('city model demo')),
        body: Center(
            child: Container(
          width: 400,
          height: 300,
          child: Column(
            children: [
              Text('register'),
              buildTxtField('name', _name, context),
              buildRegisterButton('Reserve')
            ],
          ),
        )));
  }

  Widget buildRegisterButton(String text) => ElevatedButton(
      onPressed: () async {
        print(widget.userCredential.user!);
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userCredential.user!.uid)
            .set({
          "name": _name.text,
          "updated_at": Timestamp.now(),
        }).onError((e, _) => print("Error writing document: $e"));

        await FirebaseFirestore.instance.collection('appointments').doc().set({
          "patient_id": widget.userCredential.user!.uid,
          "datetime": DateTime.now().add(new Duration(minutes: 3)),
          "facility_id": widget.facilityId,
          "menu_id": widget.menuId,
          "status": "Pending",
          "created_at": Timestamp.now(),
        }).onError((e, _) => print("Error writing document: $e"));
        final itemQuantity = AnalyticsEventItem(
          itemId: widget.menuId,
        );
        await FirebaseAnalytics.instance.logPurchase(items: [itemQuantity]);
        _reserveNotification();
      },
      child: Text(text));
  _reserveNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thank you!"),
        content: const Text("You will be contacted by WhatsApp soon!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("close"),
          )
        ],
      ),
    );
  }
}

Widget buildTxtField(String labelText,
        TextEditingController textEditingController, BuildContext context) =>
    Padding(
      padding: const EdgeInsets.all(10.00),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        child: TextFormField(
          obscureText: labelText == "OTP" ? true : false,
          controller: textEditingController,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(5.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(5.5),
            ),
            hintText: labelText,
            hintStyle: const TextStyle(color: Colors.blue),
            filled: true,
            fillColor: Colors.blue[50],
          ),
        ),
      ),
    );
