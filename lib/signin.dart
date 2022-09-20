// ignore_for_file: constant_identifier_names

import 'package:attendancesystem/otpform.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'login.dart';

enum UserRole { faculty, student }

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  TextEditingController user_id = TextEditingController();
  TextEditingController user_email_id = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController conf_password = TextEditingController();
  TextEditingController user_name = TextEditingController();
  String selected_radio="faculty";

  Future register()async{


    if(password.text.isNotEmpty && user_id.text.isNotEmpty && user_name.text.isNotEmpty && user_email_id.text.isNotEmpty && conf_password.text.isNotEmpty){
      if(password.text == conf_password.text) {
        var url = "https://gopunchin.000webhostapp.com/RegisterUser.php";
        var response = await http.post(Uri.parse(url), body:
        {
          'user_id': user_id.text,
          'user_name': user_name.text,
          'user_email': user_email_id.text,
          'password': password.text,
          'user_type': selected_radio,

        });
        var data = json.decode(response.body);
        if (data == 'Error') {
          Fluttertoast.showToast(
              msg: "User Already Registered",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        } else {
          Fluttertoast.showToast(
              msg: "Registration Done | Pls Login",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),),); // Nav to Dashboard
        }
      }else{
        Fluttertoast.showToast(
            msg: "Confirm Password Didn't Match!",
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Register Here",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0),
            ),
            TextFormField(
              controller: user_id,
              style: const TextStyle(fontSize: 15.0),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your user ID:'),
            ),
            TextFormField(
              controller: user_name,
              style: const TextStyle(fontSize: 15.0),
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your NAME :'),
            ),
            TextFormField(
              controller: user_email_id,
              style: const TextStyle(fontSize: 15.0),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your email ID:'),
            ),
            TextFormField(
              controller: password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              style: const TextStyle(fontSize: 15.0),
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your password:'),
            ),
            TextFormField(
              controller: conf_password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              style: const TextStyle(fontSize: 15.0),
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'confirm password:'),
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
                  register();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const OtpForm()),
                  // );
                },
                child: const Text('Register'))
          ],
        ),
      ),
    );
  }
}
