import 'dart:convert';

import 'package:attendancesystem/homepage.dart';
import 'package:attendancesystem/subjects.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendancesystem/subjects.dart';
import 'package:http/http.dart' as http;
import 'package:attendancesystem/generateotp.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  static String user_name_saved_session_value =
      ""; // To access the stored user name session value to display in on DRAWER welcome message.
  static String user_id_saved_session_value =
      ""; // To access the stored user ID session value to retrieve that user's respective classrooms

  // Session Management
  Future getUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_name_saved_session_value = preferences.getString('user_name')!;
    });
  }

  // Getting Classrooms from the DB

  Future<List<Subjects>> classFuture = getSubjects();

  static Future<List<Subjects>> getSubjects() async {
    // Getting the user_session value

    SharedPreferences preferences = await SharedPreferences.getInstance();
    user_id_saved_session_value = preferences.getString('user_id')!;

    var url = "https://gopunchin.000webhostapp.com/get_classrooms_faculty.php";
    var response = await http
        .post(Uri.parse(url), body: {'user_id': user_id_saved_session_value});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.map<Subjects>(Subjects.fromJson).toList();
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future logOut(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('user_name');

    Fluttertoast.showToast(
        msg: "LogOut Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.purple,
        textColor: Colors.white,
        fontSize: 16.0);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    ); // Navigation back to HomePage
  }

  @override
  Widget build(BuildContext context) {
    Widget buildClasses(List<Subjects> subjects) => ListView.builder(
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final my_subjects = subjects[index];

            return Card(
              child: ListTile(
                title: Text(my_subjects.subject_code),
                subtitle: Text(my_subjects.subject_name),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    // Passing CLASSROOM NAME to the OtpForm.dart file.
                    builder: (context) => OtpGenerator(
                        value: my_subjects.subject_code.toString()),
                  ));
                },
              ),
            );
          },
        );
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.cyan,
                ),
                child: Text(
                  'Hello, $user_name_saved_session_value',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ListTile(
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red, fontSize: 25),
                ),
                onTap: () {
                  logOut(context);
                },
              )
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(' Find Your Class '),
        ),
        body: Center(
          child: FutureBuilder<List<Subjects>>(
            future: classFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                final classes = snapshot.data!;
                return buildClasses(classes);
              } else {
                return const Text('No user Data');
              }
            },
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    getUsername();
  }
}
