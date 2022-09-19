import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FeedbackForm extends StatefulWidget {
  final String value;

  const FeedbackForm({
    Key? key,
    required this.value,
  }) : super(key: key);
  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  String user_name = "";
  String user_id = "";
  Future getUserName() async {
    SharedPreferences preferences_name = await SharedPreferences.getInstance();
    setState(() {
      user_name = preferences_name.getString('user_name')!;
    });
  }

  Future getUserId() async {
    SharedPreferences preferences_id = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences_id.getString('user_id')!;
    });
  }

  Future insertFeedback() async {
    if (feedback.text.isNotEmpty) {
      var url = "https://gopunchin.000webhostapp.com/feedback.php";
      var respone = await http.post(Uri.parse(url), body: {
        'user_id': user_id,
        'user_name': user_name,
        'feedback': feedback.text,
        'subject_name': subject_name
      });

      var data = json.decode(respone.body);
      if (data == 'Error') {
        Fluttertoast.showToast(
            msg: "ERROR",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Feedback Submitted",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  late String subject_name = widget.value;

  TextEditingController feedback = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Give your feedback'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Feedback for $subject_name",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            TextFormField(
              minLines: 1,
              maxLines: 5, // allow user to enter 5 line in textfield
              keyboardType: TextInputType
                  .multiline, // user keyboard will have a button to move cursor to next line
              controller: feedback,
              decoration: InputDecoration(
                hintText: 'Enter your feedback Here',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  insertFeedback();
                },
                child: Text('Submit Feedback'))
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserName();
    getUserId();
  }
}
