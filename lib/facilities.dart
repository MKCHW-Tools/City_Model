import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'main.dart';
import 'menu.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FacilityPage extends StatefulWidget{
  const FacilityPage();
  // final String userName;
  // final String uid;
  @override

  State<FacilityPage> createState() => _FacilityaPageState();
}

class _FacilityaPageState extends State<FacilityPage>{
  String temp = "";
  // FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('MobiKlinic City Model Demo')),
      body:
      Column(children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text('Facilities'),
          ),
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: FutureBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              future: FirebaseFirestore.instance
                  .collection('facilities')
                  .get(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      print(document['services']);
                       print(document['ratings']['average']);
                      return Card(
                        child: 
                        Column(mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                          leading: Icon(Icons.local_hospital),
                          title: Text(document['name']),
                          subtitle: Text(document['description']),
                          trailing: 
                          RatingBarIndicator(
                                rating:  document['ratings']['average'] ,
                                itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 30.0,
                                direction: Axis.horizontal,
                            ),
                        ),
                        Row (mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Container(
                            child: Row(children:
                            <Widget>[Container(child:Text('Speciality: '), padding: const EdgeInsets.all(8.0))] + document['services'].entries.map<Widget>((e){ 
                              if (e.value) {return Container(child: Text(e.key), padding: const EdgeInsets.all(8.0),);}else{return SizedBox();}
                            }).toList()),
                          ),
                          TextButton(
                          child: const Text('Look Menu'),
                          onPressed: () async {
                          await FirebaseAnalytics.instance.logSelectContent(contentType: 'facility', itemId: document.id);
                          print('switch to menu page');
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
              // 引数からユーザー情報を渡す
                          return MenuPage(document);
                            }),);
                            // _reserveNotification();
                            },
                          ),
                        ],)
                        ],)
                      );
                    }).toList(),
                  );
                }
                // データが読込中の場合
                return Center(
                  child: Text('Loading...'),
                );
              },
            ),
          ),

      ],)

    );

  }
  


}
