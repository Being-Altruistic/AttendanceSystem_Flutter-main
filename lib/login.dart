// ignore_for_file: constant_identifier_names

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:attendancesystem/otpform.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';


enum UserRole { Faculty, Student }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();
  // var role = ;


  Future login()async{
    var url ="https://gopunchin.000webhostapp.com/LoginUser.php";
    var response = await http.post(Uri.parse(url),body:
    {
      'username': user.text, 'password' : pass.text,
    });
    var data = json.decode(response.body);
    if(data == 'DoneLogIn'){
      Fluttertoast.showToast(
        msg: "Authenticated",
        toastLength: Toast.LENGTH_SHORT,
        gravity:ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }else{
      Fluttertoast.showToast(
          msg: "Not Auth",
          toastLength: Toast.LENGTH_SHORT,
          gravity:ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    UserRole? _role = UserRole.Faculty;
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
                // ListTile(
                //   title: const Text('Faculty'),
                //   leading: Radio<UserRole>(
                //     value: UserRole.Faculty,
                //     groupValue: _role,
                //     onChanged: (UserRole? value) {
                //       setState(() {
                //         _role = value;
                //       });
                //     },
                //   ),
                // ),
                // ListTile(
                //   title: const Text('Student'),
                //   leading: Radio<UserRole>(
                //     value: UserRole.Student,
                //     groupValue: _role,
                //     onChanged: (UserRole? value) {
                //       setState(() {
                //         _role = value;
                //       });
                //     },
                //   ),
                // ),
                ElevatedButton(
                    style: ButtonStyle(
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black)),
                    onPressed: () {
                      login();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const OtpForm()),
                      // );
                    },
                    child: const Text('Login'))
              ],
            )));
    }
}
