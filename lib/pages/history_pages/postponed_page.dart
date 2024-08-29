import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/models/task_item.dart';
import 'package:todolist/services/task_provider.dart';
import 'package:todolist/widgets.dart';

class PostponedPage extends StatefulWidget {
    final VoidCallback onPageVisible;
      const PostponedPage({super.key, required this.onPageVisible});



  @override
  State<PostponedPage> createState() => _PostponedPageState();
}

class _PostponedPageState extends State<PostponedPage> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPageVisible();
      
    });

    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: taskProvider.postponedtaskitems.length,
        itemBuilder: (context, index) {
          final taskItem = taskProvider.postponedtaskitems.reversed.toList()[index];
          return ChangeNotifierProvider.value(
            value: taskItem,
            child: Consumer<TaskItem>(
              builder: (context, taskItem, child) {
                return GestureDetector(
                  onTap: () {
                    showTaskDetails(context,taskItem);
                    },
                  child: Card(
                    color: Task.getColorForPriority(taskItem.task.priority),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal:8),
                          title: Text(
                            taskItem.task.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Progress: ${taskItem.task.progress}%',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8.0),
                              LinearProgressIndicator(
                                value: taskItem.task.progress / 100.0,
                                color: Task.getColorForStatus(taskItem.task.status),
                                backgroundColor: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
