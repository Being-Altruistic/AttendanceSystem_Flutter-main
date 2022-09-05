import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

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

  Future verifyOtp() async {
    var url = "https://gopunchin.000webhostapp.com/otpVerification.php";
    var response = await http.post(Uri.parse(url), body: {'verifyOTP': variable.text});
    var data = json.decode(response.body);
    if (data == "Error") {
      Fluttertoast.showToast(
          msg: "Not Valid",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Valid",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
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