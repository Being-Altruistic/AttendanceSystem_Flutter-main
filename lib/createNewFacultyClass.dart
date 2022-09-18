import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:attendancesystem/facultyDashboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateClassFaculty extends StatefulWidget {
  const CreateClassFaculty({super.key});

  @override
  State<CreateClassFaculty> createState() => _CreateClassFacultyState();
}

class _CreateClassFacultyState extends State<CreateClassFaculty> {
  static String user_id_saved_session_value = "";
  static String user_name_saved_session_value = "";
  TextEditingController subject_name = TextEditingController();
  TextEditingController subject_code = TextEditingController();

  String class_code = "";
  generateRandomString() {
    setState(() {
      int length = 6;
      final random = Random();
      const availableChars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      final randomString = List.generate(length,
              (index) => availableChars[random.nextInt(availableChars.length)])
          .join();

      class_code = randomString;
    });
  }

  Future getUserName() async {
    SharedPreferences preferences_name = await SharedPreferences.getInstance();
    setState(() {
      user_name_saved_session_value = preferences_name.getString('user_name')!;
    });
  }

  Future getUserId() async {
    SharedPreferences preferences_id = await SharedPreferences.getInstance();
    setState(() {
      user_id_saved_session_value = preferences_id.getString('user_id')!;
    });
  }

  Future createClass() async {
    SharedPreferences preferences_name = await SharedPreferences.getInstance();
    user_name_saved_session_value = preferences_name.getString('user_name')!;

    if (subject_code.text.isNotEmpty && subject_name.text.isNotEmpty) {
      var url =
          "https://gopunchin.000webhostapp.com/create_new_subject_classroom_faculty.php";
      var response = await http.post(Uri.parse(url), body: {
        'user_id': user_id_saved_session_value,
        'user_name': user_name_saved_session_value,
        'subject_name': subject_name.text,
        'subject_code': subject_code.text,
        'class_code': class_code
      });
      var data = json.decode(response.body);
      if (data == 'Error') {
        Fluttertoast.showToast(
            msg: "Class Already Created",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Class Created Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please fill required details",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(' Create New Class '),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text('user_name $user_id_saved_session_value'),
              // Text('user_name $user_name_saved_session_value'),
              Text(
                'Generated Code: $class_code',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25.0),
              ),
              TextFormField(
                controller: subject_name,
                style: const TextStyle(fontSize: 20.0),
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter Subject Name: '),
              ),
              TextFormField(
                controller: subject_code,
                style: const TextStyle(fontSize: 20.0),
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter Subject Code: '),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black)),
                  onPressed: (() {
                    generateRandomString();
                  }),
                  child: Text('Generate One Time Code')),
              ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black)),
                  onPressed: (() {
                    createClass();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FacultyDashboard()),
                    );
                  }),
                  child: Text('Create Class')),
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    getUserName();
    getUserId();
  }
}
