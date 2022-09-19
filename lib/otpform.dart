import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OtpForm extends StatefulWidget {

  //Getting the NAME OF CLASSROOM from previous screen i.e. DASHBOARD, for which the OTP needs to be entered.
  final String value;

  const OtpForm({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  TextEditingController variable = TextEditingController();
  String user_id_saved_session_value = "";
  String user_name_saved_session_value = "";
  String curr_time =  DateTime.now().toString();



  Future pushStudentData() async {
    final String curr_classroom = widget.value;

    /** ENTERING VALID STUDENT DATA **/
    var url = "https://gopunchin.000webhostapp.com/push_studentdata_valid_otp.php";

    // var response = await http.post(Uri.parse(url), body: {'verifyOTP': variable.text});
    var response = await http.post(Uri.parse(url), body: {
      'student_id':user_id_saved_session_value,
      'student_name':user_name_saved_session_value,
      'student_punch_timestamp':curr_time,
      'status':"WAIT",
      'f_course': curr_classroom
    });

    // var data = json.decode(response.body);

  }


  Future verifyOtp() async {

    final String curr_classroom = widget.value;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    user_id_saved_session_value = preferences.getString('user_id')!;
    user_name_saved_session_value = preferences.getString('user_name')!;


    try {
      var url = "https://gopunchin.000webhostapp.com/otpVerification.php";
      var response = await http.post(Uri.parse(url), body: {
        'curr_time': curr_time
      });
      var data = json.decode(response.body);

      if (data[0]['otp'] == variable.text && data[0]['f_course'] == curr_classroom) {
        Fluttertoast.showToast(
            msg: "OTP is Valid",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);

        pushStudentData();

      } else {
        Fluttertoast.showToast(
            msg: "InValid",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }catch(e){
      Fluttertoast.showToast(
          msg: "InValid",
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
        title: const Text('Enter OTP | Mark Attendance'),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // To Access values into WIDGET use WIDGET.value
              Text("Welcome to ${widget.value}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900)),
              TextFormField(
                controller: variable,
                style: const TextStyle(fontSize: 20.0),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(), labelText: 'Enter OTP here',labelStyle: TextStyle(letterSpacing: 1,fontSize: 30,fontStyle: FontStyle.normal)),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),backgroundColor:MaterialStateProperty.all<Color>(Colors.greenAccent)),
                  onPressed: () {
                    verifyOtp();
                  },
                  child: Text('PunchIn',style: TextStyle(fontSize: 25)))
            ],
          )),
    );
  }
}