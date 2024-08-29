

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/services/task_provider.dart';

class Note {
  final int id;
  final int taskId;
  final int userId;
  final DateTime date;
  final String content;

  Note({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.date,
    required this.content,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      taskId: json['taskId'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      content: json['content'],
    );
  }
  // Function to get the user name by ID using the Provider
  String toName(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final user = taskProvider.allUsers.firstWhere((user) => user.id == userId);
    return user.name!;
  }
String? getUrl(BuildContext context) {
  final taskProvider = Provider.of<TaskProvider>(context, listen: false);
  
  // Find the user or return a default value if not found
  final user = taskProvider.allUsers.firstWhere(
    (user) => user.id == userId,
  
  );
  
  return user.url; // Return the URL, which can be null
}


}
