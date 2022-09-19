class Subjects {
  final String subject_code;
  final String subject_name;

  Subjects({
    required this.subject_code,
    required this.subject_name,
  });

  static Subjects fromJson(json) => Subjects(
    subject_code: json['subject_code'],
    subject_name: json['subject_name'],
  );
}