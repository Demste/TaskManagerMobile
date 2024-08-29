import 'dart:convert';
import 'package:todolist/global.dart';
import 'package:todolist/models/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/models/active_user.dart';
import 'package:todolist/models/task_item.dart';
import 'package:todolist/models/user.dart';
import 'package:todolist/pages/history_page.dart';
import 'package:todolist/services/log_service.dart';
import 'package:http/http.dart' as http;


class TaskProvider extends ChangeNotifier {

  List<TaskItem> taskitems = [];
  List<TaskItem> allTaskItems = [];
  List<TaskItem> donetaskitems =[];
  List<TaskItem> postponedtaskitems = [];
  List<User> allUsers=[];
  List<Category>allCategories=[];

  Future<void>  _fetchCategories() async {
    try {
      String url;
      url = '$baseUrl/Categories'; 
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Category> fetchedCategories = data.map((json) {
          return Category.fromJson(json);
        }).toList();

        allCategories = fetchedCategories;  // Assign to taskitems
        notifyListeners();  // Notify listeners that taskitems has been updated
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> updateAllCatagories() async{
    await _fetchCategories();
    notifyListeners();
  }
  Future<void>  _fetcUsers() async {
    try {
      String url;
      url = '$baseUrl/Users'; // Endpoint for role 2
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<User> fetchedUsers = data.map((json) {
          return User.fromJson(json);
        }).toList();

        allUsers = fetchedUsers;  // Assign to taskitems
        notifyListeners();  // Notify listeners that taskitems has been updated
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> updateAllUsers()async{
    await _fetcUsers();
    notifyListeners();
  }
  Future<void> _fetchAllTasks() async {
    allTaskItems.clear();
    try {
      String url;
        url = '$baseUrl/TaskItems'; // Use the base URL for role 1


      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<TaskItem> fetchedTasks = data.map((json) {
          return TaskItem.fromJson(json);
        }).toList();

        // Güncellenmiş taskları taskitems listesine ata
        allTaskItems = fetchedTasks;




        notifyListeners(); // Liste güncellendiğinde dinleyicilere bildirim yap
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }
  Future<void> updaAllTasks() async {
  await _fetchAllTasks(); // Await the completion of fetching tasks
  notifyListeners(); // Notify listeners after tasks are updated
}
  Future<void> _fetchTasks() async {
    taskitems.clear();
    donetaskitems.clear();
    postponedtaskitems.clear();

    try {
      String url;
      // Role 1: admin ve tüm tasklar çekilecek
      if (ActiveUser.instance.role == 1) {
        url = '$baseUrl/TaskItems'; // Use the base URL for role 1
      } else {
        url = '$baseUrl/TaskItems/ByUserId/${ActiveUser.instance.id}'; // Use the base URL for other roles
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<TaskItem> fetchedTasks = data.map((json) {
          return TaskItem.fromJson(json);
        }).toList();

        // Güncellenmiş taskları taskitems listesine ata
        taskitems = fetchedTasks;

        // Listeyi dönerken taşınacak görevleri topla
        List<TaskItem> tasksToMoveToDone = [];
        List<TaskItem> tasksToMoveToPostponed = [];

        for (var taskItem in taskitems) {
          if (taskItem.task.progress >= 100 || taskItem.task.status == 4) {
            tasksToMoveToDone.add(taskItem);
          }
          if (taskItem.task.status == 1) {
            tasksToMoveToPostponed.add(taskItem);
          }
        }

        // Toplanan görevleri taşı
        for (var taskItem in tasksToMoveToDone) {
          moveTaskItemToDone(taskItem);
        }
        
        for (var taskItem in tasksToMoveToPostponed) {
          moveTaskItemToPostponed(taskItem);
        }

        notifyListeners(); // Liste güncellendiğinde dinleyicilere bildirim yap
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      throw e;
    }
  }
  Future<void> updateAssignedTasks() async{
    await _fetchTasks();
    notifyListeners();
  }

  void _deleteTaskItem(TaskItem taskItem) async {
    final String url = '$baseUrl/TaskItems/${taskItem.task.id}';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        },
    );
    if (response.statusCode == 200||response.statusCode == 204) {
      print('TaskItem silindi.');
      } else {
        print('TaskItem silinirken bir hata oluştu: ${response.statusCode}');
    }
}
  void deleteTaskItem(TaskItem taskItem) {
    // Find the index of the TaskItem with the matching Task id

      _deleteTaskItem(taskItem);
      removeTask(taskItem);
      notifyListeners(); // Notify listeners about the change
    
  }

 

  void removeTask(TaskItem taskitem) {
    taskitems.remove(taskitem);
    notifyListeners(); // Liste elemanı kaldırıldığında bildirim yap
  }
  void addTask(TaskItem taskitem) {
    taskitems.add(taskitem);
    notifyListeners(); // Listeye görev eklendiğinde bildirim yap
  }

  void controlStatusProgress(TaskItem taskitem, BuildContext context) {
    final logService = Provider.of<LogService>(context, listen: false);
    
    bool ischange = false;
    
    if (taskitem.task.status == 4 || taskitem.task.progress >= 100) {
      taskitem.updateProgress(100);
      taskitem.updateStatus(4);
      logService.addLog("(Görev Adı: ${taskitem.task.title}) Status ${taskitem.task.status}");

      moveTaskItemToDone(taskitem);
      taskitem.task.completeDate=DateTime.now();
      ischange = true;
    } else if (taskitem.task.status == 1) {
      moveTaskItemToPostponed(taskitem);
      ischange = true;
    }
    
    if (ischange) {
      notifyListeners(); // Güncelleme yapıldıktan sonra dinleyicilere bildirim yap
    }
  }





  void moveTaskItemToDone(TaskItem taskItem) {
    final taskIndex = taskitems.indexWhere((taski) => taski.task.id == taskItem.task.id);
    if (taskIndex != -1) {
      final task = taskitems.removeAt(taskIndex);
      donetaskitems.add(task);
      doneBadgeCount = 1;
      notifyListeners(); // Liste güncellendiğinde dinleyicilere bildirim yap
    }
  }

  void moveTaskItemToPostponed(TaskItem taskItem) {
    final taskIndex = taskitems.indexWhere((taski) => taski.task.id == taskItem.task.id);
    if (taskIndex != -1) {
      final task = taskitems.removeAt(taskIndex);
      postponedtaskitems.add(task);
      postponedBadgeCount = 1;
      notifyListeners(); // Liste güncellendiğinde dinleyicilere bildirim yap
    }
  }



}
