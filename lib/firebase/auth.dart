import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:myapp/signup.dart';

class FirebaseAuthentication {
  String phoneNumber = "";

  sendOTP(String phoneNumber) async {
    this.phoneNumber = phoneNumber;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      ConfirmationResult confirmationResult = await auth.signInWithPhoneNumber(
        '+$phoneNumber',
      );
      printMessage("OTP Sent to +256 $phoneNumber");

      return confirmationResult;
    } catch (e) {
      print(e);
      print('login failed in otp');
    }
  }

  authenticateMe(ConfirmationResult confirmationResult, String otp,
      BuildContext context, String facilityId, String menuId) async {
    try {
      UserCredential userCredential = await confirmationResult.confirm(otp);
      await FirebaseAnalytics.instance.logLogin(loginMethod: "phone");
      userCredential.additionalUserInfo!.isNewUser
          ? await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                // 引数からユーザー情報を渡す
                return SignupPage(userCredential, facilityId, menuId);
              }),
            )
          : await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                // 引数からユーザー情報を渡す
                return SignupPage(userCredential, facilityId, menuId);
              }),
            );
    } catch (e) {
      print('login failed');
    }
  }

  printMessage(String msg) {
    debugPrint(msg);
  }
}
