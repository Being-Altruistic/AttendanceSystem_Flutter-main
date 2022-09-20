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

class _OtpFormState extends State<OtpForm> with SingleTickerProviderStateMixin {
  TextEditingController variable = TextEditingController();
  TextEditingController variable_for_rate = TextEditingController();
  String user_id_saved_session_value = "";
  String user_name_saved_session_value = "";
  String curr_time =  '';
  late TabController tab_controller;





  // Initializing the TAB controller
  @override
  void initState(){
    super.initState();
    tab_controller = TabController(length: 2, vsync: this);
    tab_controller.addListener(() {
      if(tab_controller.indexIsChanging && tab_controller.index==1){
        setState(() {

        });
      }

    });
  }

  @override
  void dispose(){
    tab_controller.dispose();
    super.dispose();
  }



  Future pushStudentData() async {
    final String curr_classroom = widget.value;

    /** ENTERING VALID STUDENT DATA **/
    var url = "https://gopunchin.000webhostapp.com/push_studentdata_valid_otp.php";

    // var response = await http.post(Uri.parse(url), body: {'verifyOTP': variable.text});
    var response = await http.post(Uri.parse(url), body: {
      'student_id':user_id_saved_session_value,
      'student_name':user_name_saved_session_value,
      'student_punch_timestamp':curr_time,
      'f_course': curr_classroom      // Course Code
    });

  }


  Future rate_feedback() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    user_id_saved_session_value = preferences.getString("user_id")!;

    final String curr_classroom = widget.value;
    var url = "https://gopunchin.000webhostapp.com/check_if_lec_end.php";
    var response = await http.post(Uri.parse(url), body: {
      'student_id':user_id_saved_session_value,
      'f_course': curr_classroom,      // Course Code
      'today':DateTime.now().day.toString()
    });

    var data = json.decode(response.body);
    // print("DEBUG ::: END?? >> ${data[0]}");

    if(data[0]['lec_end']!=null){
      final String curr_classroom = widget.value;

      var url = "https://gopunchin.000webhostapp.com/take_feedback_lec_ended.php";

      var response1 = await http.post(Uri.parse(url), body: {
        'student_id':user_id_saved_session_value,
        'f_course': curr_classroom,      // Course Code
        'today':DateTime.now().day.toString(),
        'feedback': variable_for_rate.text
      });

      var data1 = json.decode(response1.body);


      if(data1=='updated_rate'){
        Fluttertoast.showToast(
            msg: "FEEDBACK registered",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      else if(data1=='not'){
        Fluttertoast.showToast(
            msg: "FEEDBACK not registered",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }

    }else if(data[0]['lec_end']==null){
      Fluttertoast.showToast(
          msg: "Rate Once Lecture ENDS",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }


  Future verifyOtp() async {

    curr_time =  DateTime.now().toString();
    String curr_classroom = widget.value;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    user_id_saved_session_value = preferences.getString('user_id')!;
    user_name_saved_session_value = preferences.getString('user_name')!;


    try {
      var url = "https://gopunchin.000webhostapp.com/otpVerification.php";
      var response = await http.post(Uri.parse(url), body: {
        'curr_time': curr_time,
        'course_code':curr_classroom
      });

      var data = json.decode(response.body);

      if (data[0]['otp'] == variable.text) {
        Fluttertoast.showToast(
            msg: "OTP is Valid",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);

        pushStudentData();

      } else if(data=="Not Found"){
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
        centerTitle: true,
        title: Text('${widget.value.toString()}'),
        bottom: TabBar(
          controller: tab_controller,
          tabs: [
            Tab(text: 'OTP', icon: Icon(Icons.arrow_circle_up_rounded)),
            Tab(text: 'FEEDBACK', icon: Icon(Icons.assignment_ind_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: tab_controller,
        children: [
          Column(
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
                  child: Text('PunchIn',style: TextStyle(fontSize: 25))),
            ],
          ),
          Column(
            children: [
              // To Access values into WIDGET use WIDGET.value
              Text("Feedback ${widget.value}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900)),
              TextFormField(
                controller: variable_for_rate,
                style: const TextStyle(fontSize: 20.0),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),backgroundColor:MaterialStateProperty.all<Color>(Colors.greenAccent)),
                  onPressed: () {
                    rate_feedback();
                  },
                  child: Text('RATE',style: TextStyle(fontSize: 25)))
            ],
          ),
        ],
      ),
    );

  }
}