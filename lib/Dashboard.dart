// Importing Packages

import 'dart:convert';
// import 'dart:js_util/js_util_wasm.dart';
import 'package:attendancesystem/homepage.dart';
import 'package:attendancesystem/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Classrooms.dart';
import 'otpform.dart';


// Main Program Logic

class Dashboard extends StatefulWidget {

  @override
  _DashboardState createState() => _DashboardState();
}

// Dashboard for Classroom Lists Nav Page
class _DashboardState extends State<Dashboard> {
  static String user_name_saved_session_value = "";    // To access the stored user name session value to display in on DRAWER welcome message.
  static String user_id_saved_session_value = "";      // To access the stored user ID session value to retrieve that user's respective classrooms
  late TextEditingController controller;
  String class_CODE_GLOBAL="";
  String u_name ="";
  String f_name ="";
  String f_course ="";
  String u_email ="";
  String f_course_code ="";


  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }




  // Session Management
  Future getUsername()async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_name_saved_session_value = preferences.getString('user_name')!;
    });
  }

  // Getting Classrooms from the DB

  Future<List<Classrooms>> classFuture = getClasses();

  static Future<List<Classrooms>> getClasses() async{

    // Getting the user_session value

    SharedPreferences preferences = await SharedPreferences.getInstance();
    user_id_saved_session_value = preferences.getString('user_id')!;


    var url = "https://gopunchin.000webhostapp.com/get_classrooms_student.php";
    var response = await http.post(Uri.parse(url), body:
    {
      'user_id': user_id_saved_session_value
    });
    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.map<Classrooms>(Classrooms.fromJson).toList();
    }else
    {
      throw Exception('Failed to load post');
    }
  }




  // joinClassDBLogic Logic
  Future joinClassFunc(String code)async{
    try{

      SharedPreferences preferences = await SharedPreferences.getInstance();

      /** Getting user session data to fetch results **/

      user_id_saved_session_value = preferences.getString('user_id')!;

      var url = "https://gopunchin.000webhostapp.com/retrieveUserDetails.php";
      var response = await http.post(Uri.parse(url), body:
      {
        'user_id': user_id_saved_session_value
      });

      /** Fetched user details from USERS table **/

      if(response.statusCode == 200) {
        final data_retrieved = json.decode(response.body);
        u_name = data_retrieved[0]['user_name'];
        u_email = data_retrieved[0]['user_email_id'];
      }else
      {
        throw Exception('Failed to load post');
      }


      var url1 = "https://gopunchin.000webhostapp.com/retrieveClassDetails.php";
      var response1 = await http.post(Uri.parse(url1), body:
      {
        'class_code': class_CODE_GLOBAL.toString()
      });

      /** Fetched faculty name & Launched Course from CLASS_CODES tables if class code is  valid **/

      if(response1.statusCode == 200) {
        final retrieved_by_code = json.decode(response1.body);
        f_name = retrieved_by_code[0]['user_name'];
        f_course = retrieved_by_code[0]['subject_name'];
        f_course_code = retrieved_by_code[0]['subject_code'];
      }else
      {
        throw Exception('Failed to load post');
      }


      /** PUSHING all values into USER_CLASSROOMS table from which LIST VIEW data is fetched **/

      var final_post_url1 = "https://gopunchin.000webhostapp.com/create_new_student_classroom_entry.php";
      var response2 = await http.post(Uri.parse(final_post_url1), body:
      {
        'user_id': user_id_saved_session_value,
        'user_name': u_name,
        'user_email_id': u_email,
        'classrooms': f_course,
        'course_code': f_course_code,
        'faculty_name': f_name
      });

      if(response2.statusCode == 200) {
        if(jsonDecode(response2.body)=="Error"){
          Fluttertoast.showToast(
              msg: "Sorry,you were already registered?",
              toastLength: Toast.LENGTH_SHORT,
              gravity:ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }else{
          Fluttertoast.showToast(
              msg: "Class Joined for $f_name",
              toastLength: Toast.LENGTH_SHORT,
              gravity:ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    }catch(e){
      print("ERROR OCCURED");
      Fluttertoast.showToast(
          msg: "ERROR",
          toastLength: Toast.LENGTH_SHORT,
          gravity:ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

    /** AFTER CLASS CREATION, COME BACK TO DASHBOARD SCREEN TO SEE THE UPDATED LIST VIEW **/

    Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard(),),); // Navigation back to HomePage
  }


  // LogOut Logic
  Future logOut(BuildContext context)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('user_type');


    Fluttertoast.showToast(
        msg: "LogOut Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity:ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.purple,
        textColor: Colors.white,
        fontSize: 16.0
    );
    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage(),),); // Navigation back to HomePage()
  }

  // Base Widget
  Widget build(BuildContext context) {

    void submit(){
      Navigator.of(context).pop(controller.text); // TO Disable the openned alert window.
    }


    // Return String Value since we passed a String in pop()
    // And access this string
    Future<String?> joinClass() => showDialog<String>(
        context: context,
        builder: (context)=>AlertDialog(
          title: Text('Enter Code'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter class code'),
            controller: controller,),
          actions: [
            TextButton(child: Text('Join'),
              onPressed: submit,
            )
          ],
        )
    );


    // Widget For ListView

    Widget buildClasses(List<Classrooms> classes) => ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index){
        final my_class = classes[index];

        return Card(
          child: ListTile(
            title: Text(my_class.classroom),
            subtitle: Text(my_class.faculty_name),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(

                // Passing CLASSROOM NAME to the OtpForm.dart file.
                builder: (context) => OtpForm(value: my_class.course_code.toString()),
              ));
            },
          ),
        );
      },);

    // Base Widget Properties

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(decoration: BoxDecoration(
              color: Colors.cyan,
            ),
              child: Text('Hello, $user_name_saved_session_value',style:TextStyle(fontSize: 20),),
            ),
            ListTile(
              title:  const Text('Log Out',style:TextStyle(color: Colors.red,fontSize: 25),),
              onTap: (){
                logOut(context);
              },
            )
          ],
        ),
      ),
      appBar: AppBar(title: Text(' Find Your Class '),),
      body: Center(
        child: FutureBuilder<List<Classrooms>>(
          future:classFuture,
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const CircularProgressIndicator();
            }else if(snapshot.hasData) {
              final classes = snapshot.data!;
              return buildClasses(classes);
            }else{
              return const Text('No user Data');
            }
          },
        ),
      ),

      // FOR JOIN CLASS FUNCTION

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,size: 45,color: Colors.white,),

        /** A value will be returned & getting into final var **/
        /** async & await for using FUTURE functions since event happen async**/

        onPressed: () async {
          final classCODE = await joinClass();
          if (classCODE == null || classCODE.isEmpty) return;


          // // Accessing the global variable to set local value
          class_CODE_GLOBAL = classCODE;
          joinClassFunc(class_CODE_GLOBAL);

        },
      ),
      // backgroundColor: Colors.cyan,

    );
  }

  // First Call Goes to this via super.initState()
  @override
  void initState(){
    super.initState();
    getUsername();

    // Initializing the controller
    controller = TextEditingController();

  }
}