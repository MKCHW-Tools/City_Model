import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/facilities.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'sign-up.dart';
import 'facilities.dart';
import 'review.dart';
// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyB_UUWyxoEd8nsB2KxzaVIMu9Dd3U_mDSY",
          authDomain: "mobiklinic-city-demo.firebaseapp.com",
          projectId: "mobiklinic-city-demo",
          storageBucket: "mobiklinic-city-demo.appspot.com",
          messagingSenderId: "538665673190",
          appId: "1:538665673190:web:83d9c6b082ec2c4c833627",
          measurementId: "G-L68QP00B22"));
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // String myurl = Uri.base.toString();
  // print(myurl);
  // final String para1 = Uri.base.queryParameters["appointmentId"] ?? 'null';
  // print(para1);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FacilityPage(),
        // '/review': (context) =>ReviewPage(),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);
        print(uri.path);
        if (uri.path == "/review") {
          final appointmentId = uri.queryParameters['appointmentId'];
          print(appointmentId);
          return MaterialPageRoute(builder: (context) {
            return ReviewPage(appointmentId!);
          });
        }
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // home: LoginPage()
      // home: FacilityPage('test', 'XrG4VDhpD9jHwdZRGW5b')
    );
  }
}

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

  Widget buildPhoneButton(String text) => ElevatedButton(
        onPressed: () async {
          setState(() {
            login = !login;
          });
          temp = await FirebaseAuthentication().sendOTP(_phone.text);
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
}

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
            prefixIcon: Icon(prefixIcons, color: Colors.blue),
            hintText: labelText,
            hintStyle: const TextStyle(color: Colors.blue),
            filled: true,
            fillColor: Colors.blue[50],
          ),
        ),
      ),
    );

class FirebaseAuthentication {
  String phoneNumber = "";

  sendOTP(String phoneNumber) async {
    this.phoneNumber = phoneNumber;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      ConfirmationResult confirmationResult = await auth.signInWithPhoneNumber(
        '+256 $phoneNumber',
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

// class SignupPage extends StatefulWidget{
//   const SignupPage({super.key});
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage>{
//   @override
//   String _email = '';
//   String _password = '';

//    Widget build(BuildContext context){
//     return Scaffold(
//       appBar: AppBar(title: Text('city model demo')),
//       body:
//       Center(child:
//       Container(
//         width: 400,
//         height: 300,
//         child:
//         Column(children: [
//           Text('Sign-up'),
//           const SizedBox(height: 8),
//           Text('email address'),
//           TextField(
//             onChanged: (String value) {
//                 // データが変更したことを知らせる（画面を更新する）
//                 setState(() {
//                   // データを変更
//                   _email = value;
//                 });}
//           ),
//           Text('password'),
//           TextField(obscureText: true,
//             onChanged: (String value) {
//                 // データが変更したことを知らせる（画面を更新する）
//                 setState(() {
//                   // データを変更
//                   _password = value;
//                 });}

//           ),
//                     const SizedBox(height: 8),
//           ElevatedButton(
//           // Within the `FirstScreen` widget
//           onPressed: () {
//             try {
//               final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//               email: emailAddress,
//               password: password,
//               );
//             } on FirebaseAuthException catch (e) {
//               if (e.code == 'weak-password') {
//             print('The password provided is too weak.');
//             } else if (e.code == 'email-already-in-use') {
//             print('The account already exists for that email.');
//               }
//               } catch (e) {
//                 print(e);
//               }

//             Navigator.pop(context);
//           },
//           child: const Text('Sign up'),),
//         ],),
//       )),
//     );
//   }

// }

// class LoginPage extends StatelessWidget{
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: AppBar(title: Text('city model demo')),
//       body:
//       Center(child:
//       Container(
//         width: 400,
//         height: 200,
//         child:
//         Column(children: [
//           Text('Sign-in'),
//           const SizedBox(height: 8),
//           Text('email address'),
//           TextField(),
//           Text('password'),
//           TextField(),
//         ],),
//       )),
//     );
//   }

// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
