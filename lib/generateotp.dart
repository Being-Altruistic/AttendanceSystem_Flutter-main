import 'dart:convert';
import 'dart:ffi';

import 'package:attendancesystem/student_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:otp/otp.dart';
import 'package:http/http.dart' as http;
import 'package:attendancesystem/facultyDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpGenerator extends StatefulWidget {
  //Getting the NAME OF CLASSROOM from previous screen i.e. DASHBOARD, for which the OTP needs to be entered.
  final String value;

  const OtpGenerator({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  State<OtpGenerator> createState() => _OtpGeneratorState();
}


/** FOR TAB CONTROLLER **/
class _OtpGeneratorState extends State<OtpGenerator> with SingleTickerProviderStateMixin {
  String textHolder = '';
  String fname = '';
  String fid = '';
  String fcourse = '';
  int otp_exp_time = 15;

  // To manage tabs based on certain activity with custom controller
  late TabController tab_controller;


  // Initializing the controller
  @override
  void initState(){
    super.initState();
    tab_controller = TabController(length: 2, vsync: this);
    tab_controller.addListener(() {
      setState(() {
        if(tab_controller.index==1){
          // Call functon
        }

      });
    });
  }

  @override
  void dispose(){
    tab_controller.dispose();
    super.dispose();
  }




  generateOtp() {
    setState(() {
      final code = OTP.generateTOTPCodeString(
          'JBSWY3DPEHPK3PXP', DateTime
          .now()
          .millisecondsSinceEpoch,
          length: 4, interval: 10);
      textHolder = code;
    });
  }

  Future submitOtp() async {
    var url = "https://gopunchin.000webhostapp.com/pushOtp_and_data.php";

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var response = await http.post(Uri.parse(url), body: {
        'f_id': preferences.getString('user_id')!,
        'f_name': preferences.getString('user_name')!,
        'f_course': widget.value.toString(),
        'lec_start': DateTime.now().toString(),             /**FOR Database col type DATETIME, convert to string & compare in DB **/
        'otp': textHolder,
        'otp_expiry': DateTime.now().add(Duration(minutes: otp_exp_time)).toString()
      });

      var data = json.decode(response.body);
      if (data == 'Session Started') {
        Fluttertoast.showToast(
            msg: "Session Started",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        if (data == 'error') {
          Fluttertoast.showToast(
              msg: "Couldnt Load Session",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Some Network Error Occured",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }


  Widget buildStudents(List<Students> users) => ListView.builder(
      itemCount: users.length,
      itemBuilder: (context,index) {
        final user = users[index];
        return Card(
          child: ListTile(
            title: Text(user.name),
            subtitle: Text(user.id),

          ),
        );
      }
  );

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          // title: Text('Manager'),
          centerTitle: true,
          bottom: TabBar(

            //Creating OWN Controller instead of DefaultTabController
            controller: tab_controller,

            tabs: [
              Tab(text: 'OTP', icon: Icon(Icons.arrow_circle_up_rounded)),
              Tab(text: 'STATS',
                  icon: Icon(Icons.assignment_ind_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          controller: tab_controller,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textHolder,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 70.0),
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        alignment: Alignment.center,
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black)),
                    onPressed: () {
                      generateOtp();
                      submitOtp();
                    },
                    child: const Text('Generate OTP'))
              ],
            ),
            Center(child: Text("Could not LOAD DATA"),
            ),
          ],
        ),
      );
}
