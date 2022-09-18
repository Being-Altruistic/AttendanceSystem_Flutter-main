import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackForm extends StatefulWidget {
  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  String value = "";
  Future getSubjectName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getString('subject_name')!;
    });
  }

  TextEditingController feedback = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Feedback Form  $value",
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
            ElevatedButton(onPressed: () {}, child: Text('Submit Feedback'))
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
