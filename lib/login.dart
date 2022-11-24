import 'dart:html';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:myapp/firebase/auth.dart';


class LoginPage extends StatefulWidget {
  const LoginPage(this.menuId, this.facilityId);
  final String menuId;
  final String facilityId;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _phone = TextEditingController();
  TextEditingController _otp = TextEditingController();
  bool login = false;
  bool proper_phone = true;
  bool proper_otp = true;

  var temp;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign-in for call')),
      body: Center(
          child: Container(
            width: 400,
            height: 300,
            child: Column(
              children: [
                Text('Sign-in'),
                // const SizedBox(height: 8),
                // Text('phone number'),
                buildTextField('phone number', _phone, Icons.phone, context),
                login
                    ? buildTextField('password', _otp, Icons.timer, context)
                    : const SizedBox(),
                login
                    ? buildSubmitButton('Login')
                    : buildPhoneButton('Send Password'),
              ],
            ),
          )),
    );
  }

  Widget buildPhoneButton(String text) =>
      ElevatedButton(
        onPressed: () async {
          setState(() {
            login = !login;
          });
          temp = await FirebaseAuthentication().sendOTP(_phone.text);
        },
        child: Text(text),
      );

  Widget buildSubmitButton(String text) =>
      ElevatedButton(
        onPressed: () {
          FirebaseAuthentication().authenticateMe(
              temp, _otp.text, context, widget.facilityId, widget.menuId);
        },
        child: Text(text),
      );

  Widget buildTextField(String labelText,
      TextEditingController textEditingController,
      IconData prefixIcons,
      BuildContext context) =>
      Padding(
        padding: const EdgeInsets.all(10.00),
        child: SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width / 1.5,
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
              prefixIcon: Icon(prefixIcons, color: Colors.blue),
              hintText: labelText,
              hintStyle: const TextStyle(color: Colors.blue),
              filled: true,
              fillColor: Colors.blue[50],
            ),
          ),
        ),
      );
}