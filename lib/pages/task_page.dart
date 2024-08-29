import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/models/task_item.dart';
import 'package:todolist/services/task_provider.dart';
import 'package:intl/intl.dart';
import 'package:todolist/widgets.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _sortOptions = {
    'Öncelik (Önce en önemsizler)': false,
    'Öncelik (Önce en önemliler)': false,
    'Kalan Gün Sayısına Göre': true,
    'Güncellenme Tarihi (En Yeni)': false, // Yeni eklenen seçenek
    'Güncellenme Tarihi (En Eski)': false, // Yeni eklenen seçenek
  };

  List<TaskItem> filterTasks(List<TaskItem> taskItems) {
    List<TaskItem> filteredTasks = List.from(taskItems);

    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks.where((taskItem) {
        final task = taskItem.task;
        bool matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            task.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesSearch;
      }).toList();
    }
    
    for (var option in _sortOptions.entries) {
      if (option.value) {
        switch (option.key) {
          case 'Öncelik (Önce en önemsizler)':
            filteredTasks.sort((a, b) => a.task.priority.compareTo(b.task.priority));
            break;
          case 'Öncelik (Önce en önemliler)':
            filteredTasks.sort((a, b) => b.task.priority.compareTo(a.task.priority));
            break;
          case 'Kalan Gün Sayısına Göre':
            filteredTasks.sort((a, b) => a.task.remainingDays.compareTo(b.task.remainingDays));
            break;
          case 'Güncellenme Tarihi (En Yeni)':
            filteredTasks.sort((a, b) => b.task.updateDate?.compareTo(a.task.updateDate ?? DateTime(1970)) ?? 0);
            break;
          case 'Güncellenme Tarihi (En Eski)':
            filteredTasks.sort((a, b) => a.task.updateDate?.compareTo(b.task.updateDate ?? DateTime(1970)) ?? 0);
            break;
        }

      }
    }

    return filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevler'),
        centerTitle: true,
        
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.white), // Doğru kullanım
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: InputBorder.none,
                      ),
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 100,
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Sıralama Seçenekleri',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            ..._sortOptions.keys.map((option) => CheckboxListTile(
              title: Text(option),
              value: _sortOptions[option],
              onChanged: (selected) => _onSortOptionChanged(option, selected),
            )),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Call the updateTasks method and wait for it to complete
          await Provider.of<TaskProvider>(context, listen: false).updateAllCatagories();
          await Provider.of<TaskProvider>(context, listen: false).updateAllUsers();
          await Provider.of<TaskProvider>(context, listen: false).updateAssignedTasks();
        },
        color: Colors.white,
        backgroundColor: Colors.black,
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            if (taskProvider.taskitems.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
                
              );
            }

            final filteredTasks = filterTasks(taskProvider.taskitems);

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final taskItem = filteredTasks[index];
                return ChangeNotifierProvider.value(
                  value: taskItem,
                  child: Consumer<TaskItem>(
                    builder: (context, taskItem, child) {
                      return GestureDetector(
                        onTap: () {
                          showTaskDetails(context, taskItem);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Card(
                              color: Task.getColorForPriority(taskItem.task.priority),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ListTile(
                                    contentPadding: const EdgeInsets.all(5.0),
                                    title: Text(
                                      taskItem.task.title,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      taskItem.task.description,
                                      maxLines: 2,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        if (taskItem.task.estimatedCompleteDate != null)
                                          Text(
                                            '${taskItem.task.remainingDays} Gün',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        const SizedBox(width: 5,),
                                        Flexible(
                                          child: LinearProgressIndicator(
                                            value: taskItem.task.progress / 100.0,
                                            color: Task.getColorForStatus(taskItem.task.status),
                                            backgroundColor: Colors.grey[300],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${taskItem.task.progress.toInt()}%',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /*if (allUsers.firstWhere((user) => user.id == taskItem.task.createdByUserId).role == 1)                             
                            Positioned(
                              top: -7,
                              left: -7,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2), // Yatay ve dikey offset
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.workspace_premium, // Replace with your desired icon
                                  color: Color.fromARGB(255, 109, 255, 114),
                                  size: 22.0, // Adjust size as needed
                                ),
                              ),
                            ),*/


                            if (taskItem.task.updateDate != null)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12.0),
                                    topRight: Radius.circular(12.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2), // Yatay ve dikey offset
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Güncellendi: ${DateFormat('dd-MM-yyyy HH:mm').format(taskItem.task.updateDate!.toLocal())}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );

  }
void _onSortOptionChanged(String option, bool? selected) {
    setState(() {
      _sortOptions[option] = selected ?? false;
    });
  }
}



  