// Get JSON Data & Convert into String type for Classroom Object
//Serializing JSON inside model classes | Less Error Prone | No Typos or mis-formating my compiler
//https://docs.flutter.dev/development/data-and-backend/json

class Classrooms {
  final String classroom;
  final String faculty_name;
  final String course_code;

  Classrooms({
    required this.classroom,
    required this.faculty_name,
    required this.course_code,
  });

  static Classrooms fromJson(json) =>Classrooms(
      classroom: json['classrooms'],
        faculty_name:json['faculty_name'],
    course_code:json['course_code']

        );
  }
