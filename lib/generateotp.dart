import 'dart:async';
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

  // int otp_exp_time = 2; // Timmer Limit

  static const maxSeconds = 59;
  int seconds = maxSeconds;


  // Here, this represents when will OTP expire
  int minutes = 5;  // Display 2 for 3 min timer | 1 decr


  // Import dart.async Library
  Timer? timer;

  // FOR DropDown
  List<String> sessions = ['Theory','Practicals'];
  String? currSelectedItem = 'Theory';

  // To manage tabs based on certain activity with custom controller
  // To declare variables that will be initialized later
  // Enforce this variable’s constraints at runtime instead of at compile time
  late TabController tab_controller;


  /*** TIMER LOGIC , DISPLAY LIVE TIMER ***/

  @override

  void startTimer() async{
    // Exec callback every seconds
    timer = Timer.periodic(Duration(seconds: 1),
            (_)       // Callback func which repeatedly calls seconds decrement
        // Callback can be named anything, like (timer) (name) etc.
        {
          seconds--;
          // Callback function visits this section every 1 sec
          // the following conditions are checked.
          if(seconds == 0 && minutes>0){
            minutes--;    // If seconds = 0 , then decrement minutes by 1
            seconds=maxSeconds; // reset seconds to 59 sec
          }else if(minutes ==0 && seconds ==1){ // Trigger Stop at 1th second
            minutes=0;
            seconds=0;
            /** Declared a callback function "(_)" above,
                So using that function's object "_.cancel()" to cancel/stop
                the callback being performed continuously every 1 sec.
             **/
            _.cancel();                     // Stopped at 0th second

            // if(timer?.isActive == false){
            //   /** LOGIC **/
            // }

            /** CallBack by (_) is now stopped **/
          }

          // Set the variables to stateful to update the realtime values.
          setState(()=>{
            seconds,
            minutes
          });

        });
  }




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


  Future endSession() async{
    var url = "https://gopunchin.000webhostapp.com/end_lec.php";

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var response = await http.post(Uri.parse(url), body: {
        'f_id': preferences.getString('user_id')!,
        'f_course': widget.value.toString(),
        'today': DateTime
            .now()
            .day
            .toString(),
        'end': DateTime.now().toString()
      });
      var data = json.decode(response.body);

      print("DATA ::>>${data}");

      if (data == "updated") {
        Fluttertoast.showToast(
            msg: "SESSION ENDED",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (data == "error") {
        Fluttertoast.showToast(
            msg: "Some Error Occurred",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }catch(e){
      Fluttertoast.showToast(
          msg: "NETWORK ERROR",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

  }


  Future submitOtp() async {
    var url = "https://gopunchin.000webhostapp.com/pushOtp_and_data.php";

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var response = await http.post(Uri.parse(url), body: {
        'f_id': preferences.getString('user_id')!,
        'f_name': preferences.getString('user_name')!,
        'f_course': widget.value.toString(),
        'lec_type': currSelectedItem,
        'lec_start': DateTime.now().toString(),             /**FOR Database col type DATETIME, convert to string & compare in DB **/
        'otp': textHolder,
        'otp_expiry': DateTime.now().add(Duration(minutes: minutes+1)).toString()
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


  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          title: Text('${widget.value.toString()}'),
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
                Text('$minutes:'+'$seconds', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,
                  fontSize: 80,
                ),),

                // Within SizedBox
                SizedBox(
                  width: 300,

                  /** DropdownButton<String> :: FOr NON Decorative style **/

                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Passing list to DRopDownButton  // Iterate ove passed list & pick each value

                    // This is needed to display the current selected value onto the screen
                    // Whenever the screen is created newly.

                    value: currSelectedItem,
                    items: sessions.map(
                      // Map every item in the list to DropdownMenuItem object

                            (item)=> DropdownMenuItem<String>(

                          // Setting value for each item & displaying each element as TextWidget.
                          value: item,
                          child: Text(item,style: TextStyle(fontSize: 20),),)

                      // Sp ultimate return result to above map is a List of DropdownMenuItem
                    ).toList(),

                    // The moment onCHANGE is detected, set currSelectedItem=item
                    // use setState to
                    // update the screen value.
                    onChanged:
                        (item)=> setState(() => currSelectedItem = item),
                  ),
                ),

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
                      // startTimer(); // MAking CAll to Start Timer
                    },
                    child: const Text('Generate OTP')),
                ElevatedButton(
                    style: ButtonStyle(
                        alignment: Alignment.center,
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent)),
                    onPressed: () {
                      endSession();
                    },
                    child: const Text('END SESSION')),
              ],
            ),
            Center(child: Text("Could not LOAD DATA"),
            ),
          ],
        ),
      );
}

