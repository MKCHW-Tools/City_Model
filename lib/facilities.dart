import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:myapp/menu.dart';

class FacilityPage extends StatefulWidget {
  const FacilityPage();
  // final String userName;
  // final String uid;
  @override
  State<FacilityPage> createState() => _FacilityPageState();
}

class _FacilityPageState extends State<FacilityPage> {
  String temp = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('MobiKlinic City Model Demo')),
        body: Column(
          children: [
            Container(
                margin: EdgeInsets.fromLTRB(min(100, MediaQuery.of(context).size.width * 0.05), 10,
                                            min(100, MediaQuery.of(context).size.width * 0.05), 0),
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(maxWidth: 800),
                child: FutureBuilder<String>(
                    future: FirebaseStorage.instance
                        .refFromURL(
                            "gs://mobiklinic-city-demo.appspot.com/top.png")
                        .getDownloadURL(),
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.network(snapshot.data!);
                      } else {
                        return SizedBox();
                      }
                    }))),
            Expanded(
              // FutureBuilder
              // 非同期処理の結果を元にWidgetを作れる
              child: FutureBuilder<QuerySnapshot>(
                // 投稿メッセージ一覧を取得（非同期処理）
                // 投稿日時でソート
                future:
                    FirebaseFirestore.instance.collection('facilities').get(),
                builder: (context, snapshot) {
                  // データが取得できた場合
                  if (snapshot.hasData) {
                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
                    // 取得した投稿メッセージ一覧を元にリスト表示
                    return ResponsiveGridView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: documents.length,
                        // shrinkWrap: false,
                        gridDelegate: const ResponsiveGridDelegate(
                            crossAxisSpacing: 50,
                            mainAxisSpacing: 50,
                            minCrossAxisExtent: 250,),
                        itemBuilder: (BuildContext context, int index) {
                          final document = documents[index];
                          return Container(
                              child: GestureDetector(
                                  onTap: () async {
                                    await FirebaseAnalytics.instance
                                        .logSelectContent(
                                            contentType: 'facility',
                                            itemId: document.id);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                        // 引数からユーザー情報を渡す
                                        return MenuPage(document);
                                      }),
                                    );
                                    // _reserveNotification();
                                  },
                                  child: Card(
                                      child: Column(
                                    children: [
                                      Container(
                                          padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                                          child: FutureBuilder<String>(
                                        future: FirebaseStorage.instance
                                            .refFromURL(document['image'])
                                            .getDownloadURL(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Image.network(
                                                snapshot.data!);
                                          } else {
                                            return SizedBox(
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text('Loading...')
                                                ));
                                          }
                                        },
                                      )),
                                      Container(
                                          child: Text(document['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ))),
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                        child: Wrap(
                                          children: <Widget>[
                                                Container(
                                                    child: Text('Speciality: '),
                                                    padding:
                                                        const EdgeInsets.symmetric(vertical: 2, horizontal: 4))
                                              ] +
                                              document['services']
                                                  .entries
                                                  .map<Widget>((e) {
                                                if (e.value) {
                                                  return Container(
                                                    child: Text(e.key),
                                                    padding:
                                                    const EdgeInsets.symmetric(vertical: 2, horizontal: 4)
                                                  );
                                                } else {
                                                  return SizedBox();
                                                }
                                              }).toList())),
                                    ],
                                  ))));
                        });
                  }
                  // データが読込中の場合
                  return Center(
                    child: Text('Loading...'),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
