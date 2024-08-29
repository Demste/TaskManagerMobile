import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todolist/global.dart';
import 'package:todolist/models/active_user.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/models/user.dart';
import 'package:todolist/models/note.dart';
import 'package:todolist/models/category.dart';
import 'package:http/http.dart' as http;


class TaskItem extends ChangeNotifier {
  Task task;
  User creator;
  List<User> assignedUsers;
  List<Note> notes;
  List<Category> categories; // Update to use List<Category>

  TaskItem({
    required this.task,
    required this.creator,
    required this.assignedUsers,
    required this.notes,
    required this.categories,
  });

  void updateName(String newName) {
    if (task.title != newName) {
      task.title = newName;
      notifyListeners();
      updateTaskItem(task,categories,assignedUsers);

    }
  }

  void updateDescription(String newDescription) {
    if (task.description != newDescription) {
      task.description = newDescription;
      notifyListeners();
      updateTaskItem(task,categories,assignedUsers);

    }
  }

  void updatePriority(int newPriority) {
    if (task.priority != newPriority) {
      task.priority = newPriority;
      notifyListeners();
      updateTaskItem(task,categories,assignedUsers);

    }
  }

  void updateStatus(int newStatus) {
    if (task.status != newStatus) {
      task.status = newStatus;
      notifyListeners();
      updateTaskItem(task,categories,assignedUsers);

    }
  }

  void updateProgress(double newProgress) {
    if (task.progress != newProgress) {
      task.progress = newProgress;
      notifyListeners();
      updateTaskItem(task,categories,assignedUsers);
    }
  }

  void updateStartDate(DateTime newStartDate) {
    if (task.startDate != newStartDate) {
      task.startDate = newStartDate;
      notifyListeners();
      updateTaskItem(task,categories,assignedUsers);
    }
  }

  void updateAddedDate(DateTime newAddedDate) {
    if (task.addedDate != newAddedDate) {
      task.addedDate = newAddedDate;
      notifyListeners();
      updateTaskItem(task,categories,assignedUsers);
    }
  }

  void updateEstimatedCompleteDate(DateTime newEstimateDate) {
    if (task.estimatedCompleteDate != newEstimateDate) {
      task.estimatedCompleteDate = newEstimateDate;
      notifyListeners();
      updateTaskItem(task,categories,assignedUsers);
    }
  }

  void updateUpdateDate(DateTime newDate) {
    if (task.updateDate != newDate) {
      task.updateDate = newDate;
      notifyListeners();
      updateTaskItem(task,categories,assignedUsers);
    }
  }
  void updateAssignedUsers( List<User> newUsers) {
    assignedUsers = newUsers;
    notifyListeners(); // Notify listeners to update UI
    updateTaskItem(task,categories,assignedUsers);

  }
  void updateCatagories(List<Category> newCategories) {
    categories = newCategories;
    notifyListeners(); // Notify listeners to update UI
    updateTaskItem(task,categories,assignedUsers);

  }
  void updateNotes(List<Note> newNotes) {
    final List<Note> addedNotes = [];
    final List<Note> removedNotes = [];

    // Bul ve eklenen notları belirle
    for (var newNote in newNotes) {
      if (!notes.any((note) => note.id == newNote.id)) {
        addedNotes.add(newNote);
      }
    }

    // Bul ve silinen notları belirle
    for (var oldNote in notes) {
      if (!newNotes.any((note) => note.id == oldNote.id)) {
        removedNotes.add(oldNote);
      }
    }

    // Notları güncelle
    notes = newNotes;

    // UI'yi güncelle
    notifyListeners();

    // Eklenen notları API'ye gönder
    _addNotes(task.id,addedNotes);
    

    // Silinen notları API'den kaldır
    for (var note in removedNotes) {
      _deleteNoteFromTask(note.id);
    }
  }
  



  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      task: Task.fromJson(json['task']),
      creator: User.fromJson(json['creator']),
      assignedUsers: (json['assignedUsers'] as List)
          .map((user) => User.fromJson(user))
          .toList(),
      notes: (json['notes'] as List)
          .map((note) => Note.fromJson(note))
          .toList(),
      categories: (json['categories'] as List)
          .map((category) => Category.fromJson(category))
          .toList(),
    );
  }
  /*
  Map<String, dynamic> toJson() {
    return {
      'task': task.toJson(),
      'creator': creator.toJson(),
      'assignedUsers': assignedUsers.map((user) => user.toJson()).toList(),
      'notes': notes.map((note) => note.toJson()).toList(),
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }*/
  Future<void> updateTaskItem(Task task, List<Category> categories, List<User> users,) async {
    final url = '$baseUrl/TaskItems'; // Endpoint to update task

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // JSON veri göndereceğimizi belirtir
        },
        body: jsonEncode(task.toJson()), // Map'i JSON formatına dönüştürür
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Task item updated successfully: ${response.body}');
        // Send additional POST requests with categories, users, and notes
        await _updateTaskCategories(task.id, categories);
        await _updateTaskUsers(task.id, users);
      } else {
        throw Exception('Failed to update task item: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating task item: $e');
    }
  }

  Future<void> _updateTaskCategories(int taskId, List<Category> categories) async {
    final categoryIds = categories.map((category) => category.id).toList();
    final url = '$baseUrl/TaskCategories?taskId=$taskId&categorieIds=${categoryIds.join(',')}';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // JSON veri göndereceğimizi belirtir
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Task categories updated successfully: ${response.body}');
      } else {
        throw Exception('Failed to update task categories: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating task categories: $e');
    }
  }
  Future<void> _updateTaskUsers(int taskId, List<User> users) async {
    final url = '$baseUrl/TaskUsers';
    final userIds = users.map((user) => user.id).toList();

    try {
      final response = await http.post(
        Uri.parse('$url?taskId=$taskId&userIds=${userIds.join(",")}'),
        headers: {
          'Content-Type': 'application/json', // JSON veri göndereceğimizi belirtir
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Task users updated successfully: ${response.body}');
      } else {
        throw Exception('Failed to update task users: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating task users: $e');
    }
  }
  Future<void> _deleteNoteFromTask(int noteId) async {
    final url = '$baseUrl/Notes/$noteId';

  try {
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Not başarıyla silindi.');
    } else {
      throw Exception('Not silinirken hata oluştu: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Not silinirken hata oluştu: $e');
  }
}
  Future<void> _addNotes(int taskId, List<Note> notes) async {
    final url = '$baseUrl/Notes';

    for (var note in notes) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json', // JSON veri göndereceğimizi belirtir
          },
          body: jsonEncode({
            'taskId': taskId,
            'userId': ActiveUser.instance.id, // Assuming Note has a userId field
            'date': note.date.toUtc().toIso8601String(),
            'content': note.content,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Note updated successfully');
        } else {
          throw Exception('Failed to update note: ${response.statusCode} ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error updating note: $e');
      }
    }
  }
    @override
  String toString() {
    return 'TaskItem(task: ${task.toString()}, creator: ${creator.toString()}, '
           'assignedUsers: ${assignedUsers.map((user) => user.toString()).toList()}, '
           'notes: ${notes.map((note) => note.toString()).toList()}, '
           'categories: ${categories.map((category) => category.toString()).toList()})';
  }
}


