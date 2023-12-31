import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


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
      appBar: AppBar(title: Text('Please review the service')),
      body: 
      Center(child:Container(width: 400,child: Column(
        children: [
        Expanded(child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('appointments').doc(widget.appointmentId).get(),
          builder: (context, snapshot) {
            if (snapshot.hasData){
              final document = snapshot.data!.data();
              return Column(children: [
                Container(
                    padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
                    child: Text('Your rating', style: TextStyle(fontSize: 18))
                ),
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
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 12),
                child: TextField(
                    decoration: InputDecoration(labelText: 'Discribe your rating'),
                    keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 10,
                      onChanged: (value) {
                        description = value;
                      },
                ),
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
              }, child: Text('Submit'))


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
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        )
      ],
    ),
  );
}

}