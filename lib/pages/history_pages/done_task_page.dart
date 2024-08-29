import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/models/task.dart';
import 'package:todolist/models/task_item.dart';
import 'package:todolist/services/task_provider.dart';
import 'package:todolist/widgets.dart';


class DoneTaskPage extends StatefulWidget {
  final VoidCallback onPageVisible;

  const DoneTaskPage({super.key, required this.onPageVisible});

  @override
  State<DoneTaskPage> createState() => _DoneTaskPageState();
}

class _DoneTaskPageState extends State<DoneTaskPage> {


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPageVisible();
      
    });

    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: taskProvider.donetaskitems.length,
        itemBuilder: (context, index) {
          final taskItem = taskProvider.donetaskitems.reversed.toList()[index];
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

 /* void _showTaskDetails(BuildContext context, TaskItem taskItem) {

    final task = taskItem.task;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: Text(task.title),
                  centerTitle: true,
                  backgroundColor: Task.getColorForPriority(task.priority),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: <Widget>[
                    _buildText(label: 'İsim:', text: task.title),
                    const SizedBox(height: 8.0),
                    _buildText(label: 'Açıklama:', text: task.description),
                    const SizedBox(height: 8.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildText(
                            label: 'Başlangıç:',
                            text: task.startDate?.toLocal().toString().split(' ')[0] ?? '',
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: _buildText(
                            label: 'Bitiş:',
                            text: task.estimatedCompleteDate?.toLocal().toString().split(' ')[0] ?? '',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildText(
                            label: 'Öncelik:',
                            text: Task.getPriorityText(task.priority),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildText(
                        label: 'Kategori:',
                        text: taskItem.categories.isNotEmpty
                            ? taskItem.categories.map((category) => category.name).join(', ')
                            : 'No categories',
                      ),
                    ),

                      ],
                    ),
                    const SizedBox(height: 8.0),
                    _buildText(
                      label: 'Kişiler:',
                      text: taskItem.assignedUsers.map(toElement).join(', '), // Format and join users
                    ),
                    const SizedBox(height: 8.0),
                    _buildText(
                      label: 'Notlar:',
                      notes: taskItem.notes,
                    ),

                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

Widget _buildText({
  required String label,
  List<Note>? notes, // Nullable list of notes
  String? text, // Nullable string
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: Colors.grey, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        if (notes != null && notes.isNotEmpty) // Check for null and not empty
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: notes.map((note) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0), // Customize spacing here
              child: Text(
                note.content,
                style: const TextStyle(fontSize: 14),
              ),
            )).toList(),
          )
        else // If notes is null or empty
          Text(
            text ?? '', // Display provided text or an empty string
            style: const TextStyle(fontSize: 14),
          ),
      ],
    ),
  );
}*/

}