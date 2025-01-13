import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String? databaseId; // ID specifico del documento MongoDB
  String title;
  String description;
  String list;
  Color markerColor;
  List<Member> members;
  List<Label> labels;
  String dueDate;
  String estimatedTime;
  String attachments;

  Task({
    String? id,
    this.databaseId,
    required this.title,
    required this.description,
    required this.list,
    required this.markerColor,
    this.members = const [],
    this.labels = const [],
    this.dueDate = '',
    this.estimatedTime = '',
    this.attachments = '',
  }) : id = id ?? Uuid().v4(); // Genera un ID univoco se non viene fornito.

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'list': list,
      'markerColor': markerColor.value,
      'members': members.map((m) => {'name': m.name}).toList(),
      'labels': labels.map((l) => {'name': l.name, 'color': l.color.value}).toList(),
      'dueDate': dueDate,
      'estimatedTime': estimatedTime,
      'attachments': attachments,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      databaseId: json['_id'], // Carica l'ID specifico del documento MongoDB
      title: json['title'],
      description: json['description'],
      list: json['list'],
      markerColor: Color(json['markerColor']),
      members: (json['members'] as List).map((m) => Member(name: m['name'])).toList(),
      labels: (json['labels'] as List).map((l) => Label(name: l['name'], color: Color(l['color']))).toList(),
      dueDate: json['dueDate'] ?? '',
      estimatedTime: json['estimatedTime'] ?? '',
      attachments: json['attachments'] ?? '',
    );
  }
}


class Member {
  String name;

  Member({required this.name});
}

class Label {
  String name;
  Color color;

  Label({required this.name, required this.color});
}