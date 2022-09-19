// ignore_for_file: constant_identifier_names

import 'dart:ffi';

import 'package:flutter/material.dart';
// import 'package:attendancesystem/otpform.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:attendancesystem/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'facultyDashboard.dart';
import 'generateotp.dart';


enum UserRole { faculty, student }


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();
  String selected_radio = "faculty";


  Future login()async{

    if(user.text.isNotEmpty && pass.text.isNotEmpty && selected_radio.isNotEmpty)
    {
      var url ="https://gopunchin.000webhostapp.com/LoginUser.php";
      var response = await http.post(Uri.parse(url),body:
      {
        'username': user.text, 'password' : pass.text, 'user_type': selected_radio,
      });

      // Try Catch to Catch Exceptions

      try {
        var data = json.decode(response.body);

        if (data[0]['user_name'] != null) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString('user_name', data[0]['user_name'].toString()); // For Session Management
          preferences.setString('user_id', user.text); // For Session Management
          preferences.setString('user_type', selected_radio); // For Session Management

          // Different Routes for separate roles.

          if (selected_radio == 'student') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(),),); // Nav to Dashboard
          }
          else if (selected_radio == 'faculty') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FacultyDashboard(),),); // Nav to Dashboard
          }
          Fluttertoast.showToast(
              msg: "Authenticated as $selected_radio",
              // Interpolations
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      }
      catch(e){
        Fluttertoast.showToast(
            msg: "Pls Check Creds & Ur Role",
            toastLength: Toast.LENGTH_SHORT,
            gravity:ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }else{
      Fluttertoast.showToast(
          msg: "Pls Fill All Required Fields!",
          toastLength: Toast.LENGTH_SHORT,
          gravity:ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

  }

  UserRole? _role = UserRole.faculty;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Login Here",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0),
                ),
                TextFormField(
                  controller: user,
                  style: const TextStyle(fontSize: 15.0),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your user ID: '),
                ),
                TextFormField(
                  controller: pass,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  style: const TextStyle(fontSize: 15.0),
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your password: '),
                ),
                ListTile(
                  title: const Text('Faculty'),
                  leading: Radio<UserRole>(
                    value: UserRole.faculty,
                    groupValue: _role,
                    onChanged: (UserRole? value) {
                      setState(() {
                        _role = value;
                        selected_radio = value.toString().split('.').last;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Student'),
                  leading: Radio<UserRole>(
                    value: UserRole.student,
                    groupValue: _role,
                    onChanged: (UserRole? value) {
                      setState(() {
                        _role = value;
                        selected_radio = value.toString().split('.').last;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black)),
                    onPressed: () {
                      login();
                    },
                    child: const Text('Login'))
              ],
            )));
    }
}
