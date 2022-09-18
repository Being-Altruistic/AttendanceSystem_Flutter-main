import 'dart:convert';
import 'dart:math';

import 'package:attendancesystem/createNewFacultyClass.dart';
import 'package:attendancesystem/homepage.dart';
import 'package:attendancesystem/subjects.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:attendancesystem/generateotp.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  String class_code_global = "";
  generateRandomString() {
    setState(() {
      int length = 6;
      final random = Random();
      const availableChars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      final randomString = List.generate(length,
              (index) => availableChars[random.nextInt(availableChars.length)])
          .join();

      class_code_global = randomString;
    });
  }

  late TextEditingController subject_code;
  late TextEditingController subject_name;

  static String user_name_saved_session_value =
      ""; // To access the stored user name session value to display in on DRAWER welcome message.
  static String user_id_saved_session_value =
      ""; // To access the stored user ID session value to retrieve that user's respective classrooms
  String u_name = "";
  String s_name = "";
  String s_code = "";

  @override
  void dispose() {
    subject_code.dispose();
    subject_name.dispose();
    super.dispose();
  }

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

  Future createClass() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      // Getting user session data

      user_id_saved_session_value = preferences.getString('user_id')!;
      var url =
          "https://gopunchin.000webhostapp.com/retrieveFacultyDetails.php";
      var response = await http
          .post(Uri.parse(url), body: {'user_id': user_id_saved_session_value});

      // Fetched user details from USERS table

      if (response.statusCode == 200) {
        final data_retrieved = json.decode(response.body);
        u_name = data_retrieved[0]['user_name'];
      } else {
        throw Exception('Failed to load');
      }

      var final_url =
          "https://gopunchin.000webhostapp.com/create_new_subject_classroom_faculty.php";

      var response_final = await http.post(Uri.parse(final_url), body: {
        'user_id': user_id_saved_session_value,
        'user_name': u_name,
        'subject_name': subject_name.text,
        'subject_code': subject_code.text,
        'class_code': class_code_global
      });

      if (response_final.statusCode == 200) {
        if (jsonDecode(response_final.body) == "Error") {
          Fluttertoast.showToast(
              msg: "Class already created",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: "Class Joined for $subject_name",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } catch (e) {
      print(e);
      print(subject_code);
      print(subject_name);
      print(class_code_global);
      Fluttertoast.showToast(
          msg: "ERROR",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacultyDashboard(),
      ),
    );
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
    void submit() {
      Navigator.of(context).pop(subject_code);
      Navigator.of(context).pop(subject_name);
      Navigator.of(context).pop(class_code_global);
    }

    Future<List<String?>?> insertClass() => showDialog<List<String>>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Create Class'),
              content: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(hintText: 'Enter Subject Name'),
                    controller: subject_name,
                  ),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(hintText: 'Enter Subject Code'),
                    controller: subject_code,
                  ),
                  Text('One Time Code $class_code_global')
                ],
              ),
              actions: [
                TextButton(onPressed: createClass, child: Text('Create'))
              ],
            ));

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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateClassFaculty()),
            );
          },
          child: Icon(Icons.add),
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
