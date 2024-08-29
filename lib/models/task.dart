import 'package:flutter/material.dart';


class Task {
  final int id;
  String title;
  String description;
  int priority;
  int status;
  double progress;
  DateTime? addedDate;
  DateTime? startDate;
  DateTime? estimatedCompleteDate;
  DateTime? updateDate;
  DateTime? completeDate;
  int createdByUserId;



  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.progress,
    this.addedDate,
    this.startDate,
    this.estimatedCompleteDate,
    this.updateDate,
    this.completeDate,
    required this.createdByUserId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0, // Default value if null
      title: json['title'] ?? '', // Default empty string if null
      description: json['description'] ?? '', // Default empty string if null
      priority: json['priority'] ?? 0, // Default value if null
      status: json['status'] ?? 0, // Default value if null
      progress: (json['progress'] ?? 0.0).toDouble(), // Default value if null
      addedDate: json['addedDate'] != null ? DateTime.parse(json['addedDate']) : null,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      estimatedCompleteDate: json['estimatedCompleteDate'] != null ? DateTime.parse(json['estimatedCompleteDate']) : null,
      updateDate: json['updateDate'] != null ? DateTime.parse(json['updateDate']) : null,
      completeDate: json['completeDate'] != null ? DateTime.parse(json['completeDate']) : null,
      createdByUserId: json['createdByUserId'],

    );
  }
    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'progress': progress.toInt(),
      'addedDate': addedDate?.toUtc().toIso8601String(), // DateTime'ı string'e dönüştür
      'startDate': startDate?.toUtc().toIso8601String(),
      'estimatedCompleteDate': estimatedCompleteDate?.toUtc().toIso8601String(),
      'completeDate': completeDate?.toUtc().toIso8601String(),
      'updateDate': DateTime.now().toUtc().toIso8601String(),
      'createdByUserId':createdByUserId,
    };
  }
  int get remainingDays {
    if (estimatedCompleteDate == null) {
      return 0; // or another appropriate value if no due date
    }
    final now = DateTime.now();
    return estimatedCompleteDate!.difference(now).inDays;
  }
  




  static String getPriorityText(int priority) {
    switch (priority) {
      case 3:
        return 'Yüksek';
      case 2:
        return 'Normal';
      case 1:
        return 'Düşük';
      default:
        return 'Bilinmiyor';
    }
  }
    static getColorForPriority(int priority) {
        switch (priority) {
      case 3:
        return const Color.fromRGBO(212, 56, 13, 1);
      case 2:
        return Colors.amber;
      case 1:
        return  Colors.cyan;
      default:
        return Colors.pink;
    }
  }

  static getColorForStatus(int status) {
    switch (status) {
      case 1:
        return const Color.fromRGBO(249, 74, 41, 1);
      case 2:
        return const Color.fromRGBO(0, 141, 218, 1);
      case 3:
        return const Color.fromRGBO(255, 234, 32, 1);
      case 4:
        return const Color.fromRGBO(136, 214, 108, 1);
      default:
        return Colors.pink;
    }
  }
    static String getStatusText(int priority) {
    switch (priority) {
      case 1:
        return 'Ertelendi';
      case 2:
        return 'İşlemde';
      case 3:
        return 'Beklemede';
      case 4:
        return 'Tamamlandı';
      default:
        return 'Bilinmiyor';
    }
  }
    @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, priority: $priority, '
           'status: $status, progress: $progress, startDate: $startDate, '
           'addedDate: $addedDate, estimatedCompleteDate: $estimatedCompleteDate, '
           'updateDate: $updateDate, createdByUserId: $createdByUserId)';
  }


}



