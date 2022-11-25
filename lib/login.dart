import 'dart:html';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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
  String dialCode = "256";
  String phone_number = "";
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
      appBar: AppBar(title: Text('Sign in')),
      body: Center(
          child: Container(
        width: 400,
        height: 300,
        child: Column(
          children: [
            Container(
              child: Text('Please sign in to make an appointment'),
              padding: EdgeInsets.all(12),
            ),
            // const SizedBox(height: 8),
            // Text('phone number'),
            IntlPhoneField(
              decoration: const InputDecoration(
                // TextFieldの見た目を整える
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                // borderSide: BorderSide(),
              ),
              initialCountryCode: 'UG',
              onCountryChanged: (country) {
                //　国を変更したときに発火
                dialCode = country.dialCode;
                print(country);
              },
              onChanged: (phone) {
                // 番号の入力・削除で発火
                phone_number = phone.number;
                print(phone);
              },
              invalidNumberMessage: 'Invalid Phone Number',
            ),
            // buildTextField('Phone number', _phone, Icons.phone, context),
            login
                ? buildTextField('Password', _otp, Icons.timer, context)
                : const SizedBox(),
            login
                ? buildSubmitButton('Login')
                : buildPhoneButton('Send Password'),
          ],
        ),
      )),
    );
  }

  Widget buildPhoneButton(String text) => ElevatedButton(
        onPressed: () async {
          setState(() {
            login = !login;
          });
          temp =
              await FirebaseAuthentication().sendOTP('+$dialCode$phone_number');
        },
        child: Text(text),
      );

  Widget buildSubmitButton(String text) => ElevatedButton(
        onPressed: () {
          FirebaseAuthentication().authenticateMe(
              temp, _otp.text, context, widget.facilityId, widget.menuId);
        },
        child: Text(text),
      );

  Widget buildTextField(
          String labelText,
          TextEditingController textEditingController,
          IconData prefixIcons,
          BuildContext context) =>
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
              prefixIcon: Icon(prefixIcons, color: Colors.black),
              hintText: labelText,
              hintStyle: const TextStyle(color: Colors.black),
              filled: true,

              // fillColor: Colors.blue[50],
            ),
          ),
        ),
      );
}
