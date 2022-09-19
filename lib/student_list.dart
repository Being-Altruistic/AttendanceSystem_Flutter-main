import 'package:flutter/material.dart';

class Students {
  final String id;
  final String name;

  const Students({
    required this.id,
    required this.name,
  });

  static Students fromJson(json) => Students(
    id: json['id'],
    name: json['name'],
  );
}