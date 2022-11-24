import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:myapp/login.dart';

class MenuPage extends StatefulWidget {
  const MenuPage(this.facilityDocument);
  final DocumentSnapshot facilityDocument;
  // final String uid;
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String temp = "";

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.facilityDocument['name']}'s Page")),
      body: Center(
        child: Column(
          children: [
            Container(height: 10),
            Container(
              child: FutureBuilder<String>(
                  future: FirebaseStorage.instance
                      .refFromURL(widget.facilityDocument['image'])
                      .getDownloadURL(),
                  builder: (((context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.network(snapshot.data!);
                    } else {
                      return SizedBox(child: Text('Loading...'));
                    }
                  }))),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                widget.facilityDocument['description'],
                style: TextStyle(fontSize: 25),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
                child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('menus')
                  .where('facility_id', isEqualTo: widget.facilityDocument.id)
                  .orderBy('price')
                  .get(),
              // future: FirebaseFirestore.instance.collection('menus').get(),
              builder: (context, snapshot) {
                print(snapshot);
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView(
                    children: documents.map((document) {
                      return Container(
                          width: 400,
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 100, vertical: 10),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.assignment),
                                    title: Text(document['title']),
                                    subtitle: Text(document['description']),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          child: Row(
                                        children: [
                                          Text('price: ${document['price']}UGX')
                                        ],
                                      )),
                                      TextButton(
                                        child: Text('Call Now'),
                                        onPressed: () async {
                                          await FirebaseAnalytics.instance
                                              .logSelectContent(
                                                  contentType: 'menu',
                                                  itemId: document.id);

                                          // await FirebaseFirestore.instance.collection('appointments').doc().set({
                                          //   "patient_id": 'skPcbnA1eodQIX5OxEBQ1ZD35aq2',
                                          //   "datetime": Timestamp.now(),
                                          //   "facility_id": widget.facilityDocument.id,
                                          //   "menu_id": document.id,
                                          //   "status": "Pending",
                                          //   "created_at": Timestamp.now(),
                                          // }).onError((e, _) => print("Error writing document: $e"));
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                              // 引数からユーザー情報を渡す
                                              return LoginPage(document.id,
                                                  widget.facilityDocument.id);
                                            }),
                                          );

                                          // FirebaseFirestore.instance.collection('appointments').doc().set({
                                          //   "patiend_id": widget.uid,
                                          //   "datetime": Timestamp.now(),
                                          //   "facility_id": widget.facilityDocument.id,
                                          //   "menu_id": document.id,
                                          //   "status": "Pending",
                                          // }).onError((e, _) => print("Error writing document: $e"));
                                          // await FirebaseAnalytics.instance.logSelectContent(contentType: 'menu', itemId: document.id);
                                          // _reserveNotification();
                                        },
                                      ),
                                    ],
                                  )
                                ]),
                          ));
                    }).toList(),
                  );
                }
                return Center(
                  child: Text('Loading...'),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

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
