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

class ReviewPage extends StatefulWidget{
  const ReviewPage(this.appointmentId);

  final String appointmentId;
  @override

  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage>{
  String temp = "";
  double rate = 3;
  String description = "";
  @override

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Review Page')),      
      body: 
      Center(child:Container(width: 400,child: Column(
        children: [
        Container(padding: EdgeInsets.all(8), child: Text('Please review the service')),
        Expanded(child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('appointments').doc(widget.appointmentId).get(),
          builder: (context, snapshot){
            if (snapshot.hasData){
              final  document = snapshot.data!.data();
              return Column(children: [
                Container(padding: EdgeInsets.all(8),child: Text('rating')),
                RatingBar.builder(
                initialRating: 3,
                minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
                itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                Icons.star,
                  color: Colors.amber,
                 ),
              onRatingUpdate: (rating) {
                rate = rating;
                },
                  ),
              TextField(
                  decoration: InputDecoration(labelText: 'Discribe your rating'),
                  keyboardType: TextInputType.multiline,
                    minLines: 1, 
                    maxLines: 10, 
                    onChanged: (value) {
                      description = value;
                    },
              ),
              ElevatedButton(onPressed: ()async{
                var document;
                document = FirebaseFirestore.instance.collection('reviews').doc();
                await document.set({
                  'appointment_id': widget.appointmentId,
                  'ratings': rate,
                  'comments': description,
                  'created_at': Timestamp.now(),
                });
                print('upload completed');
                await FirebaseAnalytics.instance.logSelectContent(contentType: 'menu', itemId: document.id);
                _ratingNotification();
              }, child: Text('submit'))


              ],);
            }
            return Center(child: Text('Loading...'),);
          },
        ),)



      ],)) ,)
      

    );
  }
  _ratingNotification() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Thank you for rating!"),
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