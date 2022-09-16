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


  // LogOut Logic
  Future logOut(BuildContext context)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('user_name');


    Fluttertoast.showToast(
        msg: "LogOut Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity:ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.purple,
        textColor: Colors.white,
        fontSize: 16.0
    );
    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage(),),); // Navigation back to HomePage
  }

  // Base Widget
  Widget build(BuildContext context) {

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
                  builder: (context) => OtpForm(value: my_class.classroom.toString()),
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
      )
    );


  }

  // First Call Goes to this via super.initState()
    @override
    void initState(){
      super.initState();
      getUsername();
    }
  }
