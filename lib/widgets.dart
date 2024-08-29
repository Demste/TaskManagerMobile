import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todolist/models/active_user.dart';
import 'package:todolist/models/category.dart';
import 'package:todolist/models/note.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/models/task_item.dart';
import 'package:todolist/models/user.dart';
import 'package:todolist/services/log_service.dart';
import 'package:todolist/services/task_provider.dart';

void showTaskDetails(BuildContext context, TaskItem taskitem) {
  final TextEditingController nameController = TextEditingController(text: taskitem.task.title);
  final TextEditingController descriptionController = TextEditingController(text: taskitem.task.description);
  final TextEditingController startDateController = TextEditingController(
    text: taskitem.task.startDate != null
      ? DateFormat('yyyy-MM-dd').format(taskitem.task.startDate!)
      : null, // Provide your default text here
    );
  final TextEditingController estimatedCompleteController = TextEditingController(
    text: taskitem.task.estimatedCompleteDate != null
      ? DateFormat('yyyy-MM-dd').format(taskitem.task.estimatedCompleteDate!)
      : null, // Provide your default text here
    );


  double progressValue = taskitem.task.progress.toDouble();
  final List<Note> notes = List.from(taskitem.notes); // Clone the list to prevent modification issues
  final TextEditingController extraTextController = TextEditingController();

  int? selectedStatus = taskitem.task.status;
  int? selectedPriority = taskitem.task.priority;

  final List<Category> selectedCategories= List.from(taskitem.categories); // Ensure this list is accurate
  final List<Category> allCategories = Provider.of<TaskProvider>(context, listen: false).allCategories;


  final List<User> selectedUsers = List.from(taskitem.assignedUsers); // Ensure this list is accurate
  final List<User> allUsers = Provider.of<TaskProvider>(context, listen: false).allUsers;



  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.95,
        minChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (BuildContext context, ScrollController scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {

              return Scaffold(
                appBar: AppBar(
                  title: Text(taskitem.task.title),
                  centerTitle: true,
                  backgroundColor: Task.getColorForPriority(taskitem.task.priority),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(
                        Icons.save_sharp,
                      ),
                      onPressed: () {
                        final logService = Provider.of<LogService>(context, listen: false);
                        // Değişikliklerin kontrolü
                        bool localHasChanges = false;

                        if (nameController.text != taskitem.task.title) {
                          logService.addLog("(Görev Adı:${taskitem.task.title}) Name ${taskitem.task.title} => ${nameController.text}");
                          taskitem.updateName(nameController.text);
                          localHasChanges = true;
                        }
                        if (descriptionController.text != taskitem.task.description) {
                          logService.addLog("(Görev Adı:${taskitem.task.title}) Description ${taskitem.task.description} => ${descriptionController.text}");
                          taskitem.updateDescription(descriptionController.text);
                          localHasChanges = true;

                        }
                        if (startDateController.text.isNotEmpty) {
                          final newDeadline = DateTime.parse(startDateController.text).toLocal();
                          final normalizedNewDeadline = DateTime(newDeadline.year, newDeadline.month, newDeadline.day);

                          if (taskitem.task.startDate != null) {
                            final normalizedTaskDeadline = DateTime(
                              taskitem.task.startDate!.year, // Use the null-aware operator `!`
                              taskitem.task.startDate!.month,
                              taskitem.task.startDate!.day,
                            );

                            if (normalizedNewDeadline != normalizedTaskDeadline) {
                              logService.addLog(
                                "(Görev Adı:${taskitem.task.title}) Deadline ${taskitem.task.startDate} => ${normalizedNewDeadline.toString()}",
                              );
                              taskitem.updateStartDate(newDeadline);
                              localHasChanges = true;
                            }
                          } else {

                            logService.addLog(
                              "(Görev Adı:${taskitem.task.title}) New Deadline set to ${normalizedNewDeadline.toString()}",
                            );
                            taskitem.updateStartDate(newDeadline);
                            localHasChanges = true;
                          }
                        }
                        if (estimatedCompleteController.text.isNotEmpty) {
                          final newDeadline = DateTime.parse(estimatedCompleteController.text).toLocal();
                          final normalizedNewDeadline = DateTime(newDeadline.year, newDeadline.month, newDeadline.day);

                          if (taskitem.task.estimatedCompleteDate != null) {
                            final normalizedTaskDeadline = DateTime(
                              taskitem.task.estimatedCompleteDate!.year, // Use the null-aware operator `!`
                              taskitem.task.estimatedCompleteDate!.month,
                              taskitem.task.estimatedCompleteDate!.day,
                            );

                            if (normalizedNewDeadline != normalizedTaskDeadline) {
                              logService.addLog(
                                "(Görev Adı:${taskitem.task.title}) Deadline ${taskitem.task.estimatedCompleteDate} => ${normalizedNewDeadline.toString()}",
                              );
                              taskitem.updateEstimatedCompleteDate(newDeadline);
                              localHasChanges = true;
                            }
                          } else {

                              logService.addLog(
                                "(Görev Adı:${taskitem.task.title}) Deadline ${taskitem.task.estimatedCompleteDate} => ${normalizedNewDeadline.toString()}",
                              );
                              taskitem.updateEstimatedCompleteDate(newDeadline);
                              localHasChanges = true;
                          }
                        }

                        if (progressValue != taskitem.task.progress) {
                          logService.addLog("(Görev Adı:${taskitem.task.title}) Progress Value ${taskitem.task.progress} => ${progressValue.toInt()}");
                          taskitem.updateProgress(progressValue);

                          localHasChanges = true;

                          
                        }
                        if (selectedStatus != taskitem.task.status) {
                          logService.addLog("(Görev Adı:${taskitem.task.title}) Status ${taskitem.task.status} => ${selectedStatus!}");
                          taskitem.updateStatus(selectedStatus!);
                          localHasChanges = true;

                        }
                        if (!const ListEquality().equals(selectedCategories, taskitem.categories)) {
                          logService.addLog("(Görev Adı:${taskitem.task.title}) Users ${taskitem.categories} => $selectedCategories");
                          taskitem.updateCatagories(selectedCategories);
                          localHasChanges = true;
                        }
                        if (selectedPriority != taskitem.task.priority) {
                          logService.addLog("(Görev Adı:${taskitem.task.title}) Priority ${taskitem.task.priority} => ${selectedPriority!}");
                          taskitem.updatePriority(selectedPriority!);
                          localHasChanges = true;
                          
                        }
                        if (!listEquals(taskitem.notes, notes)) {
                          logService.addLog("(Görev Adı:${taskitem.task.title}) Notes ${taskitem.notes.map((note) => note.content).toList()} => ${notes.map((note) => note.content).toList()}");
                          taskitem.updateNotes(notes);
                          localHasChanges = true;
                        }
                        if (!const ListEquality().equals(selectedUsers, taskitem.assignedUsers)) {
                          // Map the list of User objects to their names
                          final assignedUserNames = taskitem.assignedUsers.map((user) => user.name).toList();
                          final selectedUserNames = selectedUsers.map((user) => user.name).toList();

                          logService.addLog("(Görev Adı:${taskitem.task.title}) Users $assignedUserNames => $selectedUserNames");
                          taskitem.updateAssignedUsers(selectedUsers);
                          localHasChanges = true;
                        }

                        if (localHasChanges) {
                          
                          // Güncellemeleri kontrol et
                          final taskProvider = context.read<TaskProvider>();
                          taskProvider.controlStatusProgress(taskitem,context);

                          // Snackbar göster
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task updated'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          //veriler kaydedildikten sonra karşıdakiler indiirlsin mi?? evetse alt aşağıdakini await ile tavsiye edilir
                          //normalde refresh indicator ile de yneiliyosrsun
                          //Provider.of<TaskProvider>(context, listen: false).updateAssignedTasks();
                        } else {
                          // Değişiklik yoksa bilgi ver
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No changes to save'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                body: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  children: <Widget>[
                    buildTextField(
                      label: 'Task ismi',
                      controller: nameController,
                      hintText: 'Enter task name',
                    ),
                    buildTextField(
                      label: 'Task açıklaması',
                      controller: descriptionController,
                      hintText: 'Enter task description',
                      maxLines: 3,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: 'Başlangıç Tarihi',
                            controller: startDateController,
                            context: context,
                            initialDate: taskitem.task.startDate,
                          ),
                        ),
                        const SizedBox(width: 8), // Aralarına boşluk eklemek için
                        Expanded(
                          child: _buildDateField(
                            label: 'Bitiş Tarihi',
                            controller: estimatedCompleteController,
                            context: context,
                            initialDate: taskitem.task.estimatedCompleteDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: buildDropdown<int>(
                            label: 'Durum',
                            value: selectedStatus!,
                            items: [1, 2, 3, 4], // Replace with your status values
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value;
                              });
                            },
                            getText: Task.getStatusText, // Use the status text function
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: buildDropdown<int>(
                            label: 'Öncelik',
                            value: selectedPriority!,
                            items: [1, 2, 3], // Replace with your priority values
                            onChanged: (value) {
                              setState(() {
                                selectedPriority = value;
                              });
                            },
                            getText: Task.getPriorityText, // Use the priority text function
                          ),
                        ),
                      ],
                    ),
                    if(ActiveUser.instance.role==1)...[
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
                    const SizedBox(height: 10),
                    ],
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
                    
                    const SizedBox(height: 10),

                    _buildExtraTexts(
                      context: context,
                      extraNotes: notes,
                      onRemove: (note) {
                        setState(() {
                          final index = notes.indexOf(note);
                          if (index != -1) {
                            notes.removeAt(index);
                          }
                        });
                      },
                      onAdd: (text) {
                        setState(() {
                          final newNote = Note(
                            id: DateTime.now().millisecondsSinceEpoch,
                            taskId: taskitem.task.id,
                            userId:ActiveUser.instance.id,
                            date: DateTime.now(),
                            content: text,
                          );
                          notes.add(newNote);
                        });
                      },
                      controller: extraTextController,
                    ),

                    if (ActiveUser.instance.role == 1||taskitem.creator.id==ActiveUser.instance.id) // Check if the role is 1
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red, // Buton arka plan rengi
                          borderRadius: BorderRadius.circular(8), // Köşeleri yuvarlatmak için
                        ),
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Görevi Sil"),
                                  content: const Text("Silmek istediğinizden emin misiniz? Bu işlem geri alınamaz."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Provider.of<TaskProvider>(context, listen: false).deleteTaskItem(taskitem);
                                        Navigator.of(context).pop(); // Uyarıyı kapat
                                        Navigator.of(context).pop(); // Bottom sheet kapat

                                        
                                      },
                                      child: const Text("Evet"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Uyarıyı kapat
                                      },
                                      child: const Text("İptal"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            "Görevi Sil",
                            style: TextStyle(color: Colors.white), // Buton yazı rengi
                          ),
                        ),
                      ),
                  ],
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Progress: ${progressValue.toInt()}%',
                          style: const TextStyle(color:Colors.white),
                        ),
                        Slider(
                          value: progressValue,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          activeColor: Colors.white,
                          inactiveColor: Colors.grey,
                          onChanged: (double newValue) {
                            setState(() {
                              progressValue = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
Widget _buildSelection<T>({
  required String title,
  required List<T> allItems,
  required List<T> selectedItems,
  required ValueChanged<T> onItemAdded,
  required ValueChanged<T> onItemRemoved,
  required String Function(T) getItemName, // Öğelerin isimlerini almak için
  required dynamic Function(T) getItemId,  // Öğelerin ID'lerini almak için
}) {
  T? selectedItem;

  // selectedItems içinde olmayan allItems öğelerini filtreleyin
  List<T> filteredItems = allItems.where((item) {
    final itemId = getItemId(item);
    return !selectedItems.any((selectedItem) => getItemId(selectedItem) == itemId);
  }).toList();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        DropdownButton<T>(
          hint: const Text('Seçiniz'),
          value: selectedItem,
          onChanged: (T? newValue) {
            if (newValue != null && !selectedItems.contains(newValue)) {
              onItemAdded(newValue);
            }
          },
          items: filteredItems.map<DropdownMenuItem<T>>((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(getItemName(item)),
            );
          }).toList(),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: selectedItems.map((T item) {
            return Chip(
              label: Text(getItemName(item)),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () {
                onItemRemoved(item);
              },
            );
          }).toList(),
        ),
      ],
    ),
  );
}


// Kullanıcı ekleme ve çıkarma işlemi için örnek kullanım
Widget buildUserSelection({
  required String title,
  required List<User> allUsers,
  required List<User> selectedUsers,
  required ValueChanged<User> onUserAdded,
  required ValueChanged<User> onUserRemoved,
}) {
  return _buildSelection<User>(
    title: title,
    allItems: allUsers,
    selectedItems: selectedUsers,
    onItemAdded: onUserAdded,
    onItemRemoved: onUserRemoved,
    getItemName: (User user) => user.name!,
    getItemId: (User user)=>user.id,
  );
}

// Kategori ekleme ve çıkarma işlemi için örnek kullanım
Widget buildCategorySelection({
  required String title,
  required List<Category> allCategories,
  required List<Category> selectedCategories,
  required ValueChanged<Category> onCategoryAdded,
  required ValueChanged<Category> onCategoryRemoved,
}) {
  return _buildSelection<Category>(
    title: title,
    allItems: allCategories,
    selectedItems: selectedCategories,
    onItemAdded: onCategoryAdded,
    onItemRemoved: onCategoryRemoved,
    getItemName: (Category category) => category.name,
    getItemId: (Category category)=>category.id,
  );
}

Widget buildTextField({
  required String label,
  required TextEditingController controller,
  required String hintText,
  int maxLines = 1,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
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
          style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none, // Odaklanılmamış durumdaki sınır (none - yok)
            focusedBorder: OutlineInputBorder( // Odaklanılmış durumdaki sınır
              borderSide: const BorderSide(color: Colors.black, width: 2.0), // Sınırın rengi ve kalınlığı
              borderRadius: BorderRadius.circular(8.0), // Köşe yuvarlaklığı
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _buildDateField({
  required String label,
  required TextEditingController controller,
  required BuildContext context,
  DateTime? initialDate, // Made initialDate nullable
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
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
        GestureDetector(
          onTap: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(), // Use initialDate if not null, otherwise use current date
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              // Format the date as yyyy-MM-dd and set it to the controller
              controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                border: InputBorder.none,
                hintText: 'Select Date',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildDropdown<T>({
  required String label,
  required T value,
  required List<T> items,
  required ValueChanged<T?> onChanged,
  required String Function(T) getText,
}) {
  // Ensure the value is in the items list or default to the first item
  final T? displayValue = items.contains(value) ? value : items.isNotEmpty ? items.first : null;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        DropdownButtonFormField<T>(
          value: displayValue,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                getText(item),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0),
            ),
            border: InputBorder.none,
          ),
        ),
      ],
    ),
  );
}

Widget _buildExtraTexts({
  required BuildContext context,
  required List<Note> extraNotes,
  required Function(Note) onRemove,
  required Function(String) onAdd,
  required TextEditingController controller,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Not ekle',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final newText = controller.text;
                if (newText.isNotEmpty) {
                  onAdd(newText);
                  controller.clear();
                }
              },
            ),
          ],
        ),
      ),
      for (Note note in extraNotes)
      ListTile(
        leading: SizedBox(
          width: 50, // Set a fixed width for the leading widget
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensures the Column takes only as much height as needed
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16, // Adjust the radius as needed
                backgroundImage: note.getUrl(context) != null &&
                                  Uri.tryParse(note.getUrl(context) ?? '')?.isAbsolute == true
                                ? NetworkImage(note.getUrl(context)!)
                                : null,
                backgroundColor: Colors.grey[200],
                child: note.getUrl(context) == null ||
                      Uri.tryParse(note.getUrl(context) ?? '')?.isAbsolute != true
                    ? const Icon(
                        Icons.account_circle,
                        size: 32, // Match the CircleAvatar radius
                        color: Colors.grey,
                      )
                    : null,
              ),
              const SizedBox(height: 4), // Space between avatar and name
              Flexible(
                child: Text(
                  note.toName(context),
                  style: const TextStyle(fontSize: 12), // Adjust font size as needed
                  overflow: TextOverflow.ellipsis, // Handle overflow gracefully
                  maxLines: 1, // Limit to one line
                ),
              ),
            ],
          ),
        ),
        title: Text(note.content),
        trailing: IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => onRemove(note),
        ),
      )

    ],
  );
}