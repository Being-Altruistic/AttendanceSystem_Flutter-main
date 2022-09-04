import 'dart:convert';

import 'package:attendancesystem/homepage.dart';
import 'package:attendancesystem/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String username = "";
  Future getUsername()async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString('username')!;
    });
    getClassrooms();
  }

  Future getClassrooms()async {
    var url = "https://gopunchin.000webhostapp.com/get_classrooms_student.php";
    var response = await http.post(Uri.parse(url), body:
    {
      'user_id': username
    });

    var data = json.decode(response.body);
    if (data == 'Error') {
      print('ERROR OCCURED');
    }else{
      print('RESPONSE DATA $data');
    }
  }




  Future logOut(BuildContext context)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('username');

    Fluttertoast.showToast(
        msg: "LogOut Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity:ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.amber,
        textColor: Colors.white,
        fontSize: 16.0
    );
    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage(),),); // Navigation back to HomePage
  }
    @override
    void initState(){
      super.initState();
      getUsername();
    }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard'),),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: username == '' ? Text(''): Text(username,textAlign: TextAlign.center,)),
            SizedBox(height: 20,),
            MaterialButton(color:Colors.purple,
              onPressed: (){
                logOut(context);
              },child: Text("Log Out",style: TextStyle(color: Colors.white),),)
          ],
        )
    );
  }
  }
