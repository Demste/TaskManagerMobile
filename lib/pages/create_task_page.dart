import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:todolist/global.dart';
import 'package:todolist/models/active_user.dart';
import 'package:todolist/models/category.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/models/task_item.dart';
import 'package:todolist/models/user.dart';
import 'package:todolist/services/task_provider.dart';
import 'package:http/http.dart' as http;
import 'package:todolist/widgets.dart';


class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  CreateTaskPageState createState() => CreateTaskPageState();
}

class CreateTaskPageState extends State<CreateTaskPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController estimatedCompleteController = TextEditingController();


  double progressValue=0;

  int? selectedStatus;
  int? selectedPriority;

  List<User> selectedUsers = [];
  List<Category> selectedCategories = [];
Future<void> _createTask(TaskItem taskitem) async {
    final url = '$baseUrl/TaskItems'; // Endpoint to create a new task

  try {
    // Create a new task
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json', // Indicate that we're sending JSON data
      },
      body: jsonEncode(taskitem.task.toJson()), // Convert the task object to JSON format
      
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final taskId = responseData['id']; // Extract the task ID from the response

      print('Task created successfully');

      // Update the task categories and users with the new task ID
      await _createTaskCategories(taskId, taskitem.categories);
      await _createTaskUsers(taskId, taskitem.assignedUsers);
    } else {
      throw Exception('Failed to create task: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error creating task: $e');
  }
}
Future<void> _createTaskCategories(int taskId, List<Category> categories) async {
  final categoryIds = categories.map((category) => category.id).toList();
  final url = '$baseUrl/TaskCategories?taskId=$taskId&categorieIds=${categoryIds.join(',')}';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Task categories updated successfully');
    } else {
      throw Exception('Failed to update task categories: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error updating task categories: $e');
  }
}

Future<void> _createTaskUsers(int taskId, List<User> users) async {
  final url = '$baseUrl/TaskUsers';
  final userIds = users.map((user) => user.id).toList();

  try {
    final response = await http.post(
      Uri.parse('$url?taskId=$taskId&userIds=${userIds.join(",")}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Task users updated successfully');
    } else {
      throw Exception('Failed to update task users: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error updating task users: $e');
  }
}





 @override
Widget build(BuildContext context) {

  final allUsers = Provider.of<TaskProvider>(context).allUsers;
  final allCategories = Provider.of<TaskProvider>(context).allCategories;
  if(ActiveUser.instance.role != 1 ){
    selectedUsers=[ActiveUser.instance];
  }



  return Scaffold(
    backgroundColor:  Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: const Text('Görev Ekle'),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save_sharp),
          onPressed: () async {
            // Gather the input values
            final taskName = nameController.text;
            final hasSelectedUsers = selectedUsers.isNotEmpty;
            final hasSelectedCategories = selectedCategories.isNotEmpty;

            if (taskName.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'HATA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text('Task ismi boş olamaz.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              return;
            }

            if (!hasSelectedUsers) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('HATA'),
                    content: const Text('En az bir kullanıcı seçilmeli.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              return;
            }
            if (!hasSelectedCategories) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: const Text('En az bir kategori seçilmeli.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
              });
              return;
            }

            // Gather the input values
            final task = Task(
              id: 0, // Set a default ID or handle it based on your logic
              title: nameController.text,
              description: descriptionController.text,
              priority: selectedPriority ?? 1,
              status: selectedStatus ?? 2,
              progress: progressValue,
              startDate: startDateController.text.isNotEmpty
                  ? DateTime.parse(startDateController.text)
                  : null,
              addedDate: DateTime.now(),
              estimatedCompleteDate: estimatedCompleteController.text.isNotEmpty
                  ? DateTime.parse(estimatedCompleteController.text)
                  : null,
              updateDate: DateTime.now(),
              createdByUserId: ActiveUser.instance.id, // Ensure ActiveUser is properly set
            );

            final taskItem = TaskItem(
              task: task,
              creator: ActiveUser.instance, // ActiveUser'ın doğru şekilde ayarlandığından emin olun
              assignedUsers:selectedUsers,
              notes: [], // Gerekirse notları yönetmek için mantık ekleyebilirsiniz
              categories: selectedCategories,
            );
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const AlertDialog(
                  title: Text('Creating Task'),
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Please wait...'),
                    ],
                  ),
                );
              },
            );

            try {
              // Clear the input controllers
              nameController.clear();
              descriptionController.clear();
              startDateController.clear();
              estimatedCompleteController.clear();

              
              // Call the createTask method and await its completion
              await _createTask(taskItem);

              // Dismiss the loading dialog and show success SnackBar
              Navigator.of(context).pop(); // Dismiss the progress dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task Created Successfully'),
                  duration: Duration(seconds: 1),
                ),
              );

              setState(() {
                selectedPriority = null;
                selectedStatus = null;
                progressValue = 0; // or any default value you need
                selectedUsers.clear();
                selectedCategories.clear();
              });
              await Provider.of<TaskProvider>(context, listen: false).updateAssignedTasks();
              await Provider.of<TaskProvider>(context, listen: false).updaAllTasks();
              await Provider.of<TaskProvider>(context, listen: false).updateAllUsers();
            } catch (e) {
              print('Error creating task: $e');
              // Dismiss the loading dialog and show error SnackBar
              Navigator.of(context).pop(); // Dismiss the progress dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error creating task. Please try again.'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },


        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        buildTextField(
          label: 'Task ismi',
          controller: nameController,
          hintText: 'Görev ismini giriniz',
        ),
        buildTextField(
          label: 'Task açıklaması',
          controller: descriptionController,
          hintText: 'Görev açıklamasını giriniz',
          maxLines: 3,
        ),
        // Add other UI elements here
        Row(
          children: <Widget>[
            Expanded(
              child: _buildDropdown<int>(
                label: 'Durum',
                value: selectedStatus ?? 0,
                items: [1, 2, 3, 4],
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
                getText: Task.getStatusText,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _buildDropdown<int>(
                label: 'Öncelik',
                value: selectedPriority ?? 0,
                items: [1, 2, 3],
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value;
                  });
                },
                getText: Task.getPriorityText,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildDateField(
                label: 'Başlangç Date',
                context: context,
                controller: startDateController,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _buildDateField(
                label: 'Tahmini Bitiş',
                context: context,
                controller: estimatedCompleteController,
              ),
            ),
          ],
        ),

        if (ActiveUser.instance.role == 1) ...[
          const Divider(color: Colors.black, thickness: 1),
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return buildUserSelection(
                title: "Kullanıcılar",
                allUsers: allUsers,
                selectedUsers: selectedUsers,
                onUserAdded: (User user) {
                  setState(() {
                    selectedUsers.add(user);
                  });
                },
                onUserRemoved: (User user) {
                  setState(() {
                    selectedUsers.remove(user);
                  });
                },
              );
            },
          ),
        ],
        const Divider(color: Colors.black,thickness: 1,),
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return buildCategorySelection(
              title: "Kategoriler",
              allCategories: allCategories,
              selectedCategories: selectedCategories,
              onCategoryAdded: (Category category) {
                setState(() {
                  selectedCategories.add(category);
                });
              },
              onCategoryRemoved: (Category category) {
                setState(() {
                  selectedCategories.remove(category);
                });
              },
            );
          },
        ),

      ],
    ),
  );
}

Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required BuildContext context,
    DateTime? initialDate,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.transparent,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          TextField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              hintText: initialDate != null ? DateFormat('yyyy-MM-dd').format(initialDate) : 'Select date',
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onTap: () async {
              final DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: initialDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (selectedDate != null) {
                controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
              }
            },
          ),
        ],
      ),
    );
  }

Widget _buildDropdown<T>({
  required String label,
  required T? value,
  required List<T> items,
  required ValueChanged<T?> onChanged,
  required String Function(T) getText,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: const [
        BoxShadow(
          color: Colors.transparent,
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        DropdownButtonFormField<T>(
          value: items.contains(value) ? value : null,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(getText(item)),
            );
          }).toList(),
        ),
      ],
    ),
  );
}




}
