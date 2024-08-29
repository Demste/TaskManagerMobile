import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todolist/models/task_item.dart';
import 'package:todolist/services/task_provider.dart';
import 'package:todolist/models/task.dart';
import "package:todolist/widgets.dart"; // Import the file where `showTaskDetails` is defined


class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _selectedTaskStartDate;
  DateTime? _selectedTaskEndDate;
  Set<DateTime> _disabledDates = {};
  bool _showTaskCount = true; // Show or hide task count
  CalendarFormat _calendarFormat=CalendarFormat.month; // Default to month format
  Map<DateTime, List<TaskItem>> _tasks = {};
  void refreshCalendar(){
    setState(() {
      _loadTasks();
      
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    setState(() {
      _tasks = _groupTasksByDate(taskProvider.taskitems);
    });
  }

  Map<DateTime, List<TaskItem>> _groupTasksByDate(List<TaskItem> taskItems) {
    Map<DateTime, List<TaskItem>> tasksByDate = {};
    final today = DateTime.now().toUtc(); // Get today's date in UTC

    for (var taskItem in taskItems) {
      DateTime? startDate = taskItem.task.startDate;
      DateTime? endDate = taskItem.task.estimatedCompleteDate;

      if (startDate != null) {
        endDate = (endDate == null || endDate.isBefore(today)) ? today : endDate;
        endDate = DateTime(endDate.year, endDate.month, endDate.day);

        for (DateTime date = startDate; date.isBefore(endDate.add(Duration(days: 1))); date = date.add(const Duration(days: 1))) {
          final dateKey = DateTime(date.year, date.month, date.day);

          if (tasksByDate[dateKey] == null) {
            tasksByDate[dateKey] = [];
          }
          tasksByDate[dateKey]!.add(taskItem);
        }
      }
    }

    return tasksByDate;
  }

  List<TaskItem> _getTasksForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _tasks[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Takvim'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                // Toggle task count visibility on task selection
                _showTaskCount = !(_selectedTaskStartDate != null && _selectedTaskEndDate != null);
              });
            },
            eventLoader: _getTasksForDay,
            calendarFormat: _calendarFormat, // Apply selected format
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format; // Update the calendar format when changed
              });
            },

            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, tasks) {
                if (_showTaskCount && tasks.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: _buildTaskIndicator(tasks as List<TaskItem>),
                  );
                }
                return const SizedBox();
              },
              defaultBuilder: (context, date, focusedDay) {
                bool isHighlighted = false;
                if (_selectedTaskStartDate != null && _selectedTaskEndDate != null) {
                  final currentDate = DateTime(date.year, date.month, date.day);
                  isHighlighted = currentDate.isAfter(_selectedTaskStartDate!) && currentDate.isBefore(_selectedTaskEndDate!.add(const Duration(days: 1)));
                }

                return Container(
                  decoration: BoxDecoration(
                    color: isHighlighted ? Colors.blue.withOpacity(0.5) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isHighlighted ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskIndicator(List<TaskItem> tasks) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue, // Background color for the indicator
          ),
          child: Center(
            child: Text(
              '${tasks.length}', // Display the number of tasks
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
  

  Widget _buildTaskList() {
    final tasks = _selectedDay != null ? _getTasksForDay(_selectedDay!) : [];

    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks for this day.'),
      );
    }

    // Sort tasks so that those with endDate in the past come first
    tasks.sort((a, b) {
      final endDateA = a.task.estimatedCompleteDate ?? DateTime.now().add(const Duration(days: 1)); // Default to future date if null
      final endDateB = b.task.estimatedCompleteDate ?? DateTime.now().add(const Duration(days: 1)); // Default to future date if null
      return endDateA.isBefore(endDateB) ? -1 : 1; // Sort in ascending order (past dates first)
    });

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final taskItem = tasks[index];
        return GestureDetector(
          onLongPress: () {
            showTaskDetails(context, taskItem);
          },
          child: ListTile(
            title: Text(taskItem.task.title),
            subtitle: Text(
              taskItem.task.startDate != null
                ? DateFormat('yyyy-MM-dd').format(taskItem.task.startDate!)
                : 'No start date',
            ),
            leading: Icon(
              taskItem.task.estimatedCompleteDate != null && 
              taskItem.task.estimatedCompleteDate!.isBefore(DateTime.now())
                ? Icons.priority_high_sharp // Ünlem simgesi (endDate geçmişse)
                : Icons.hourglass_empty, // Kum saati simgesi (endDate geçmemişse)
              color: Task.getColorForPriority(taskItem.task.priority),
            ),
            onTap: () {
              setState(() {
                if (_selectedTaskStartDate != taskItem.task.startDate || _selectedTaskEndDate != taskItem.task.estimatedCompleteDate) {
                  // Update dates and disable dates
                  _selectedTaskStartDate = taskItem.task.startDate;
                  _selectedTaskEndDate = taskItem.task.estimatedCompleteDate;
                  _disabledDates = _generateDisabledDates(_selectedTaskStartDate, _selectedTaskEndDate);
                  _showTaskCount = false; // Hide task count when a task is selected
                } else {
                  // Clear selection and enable dates
                  _selectedTaskStartDate = null;
                  _selectedTaskEndDate = null;
                  _disabledDates.clear();
                  _showTaskCount = true; // Show task count again
                }
                _focusedDay = _selectedDay!;
              });
            },
          ),
        );
      },
    );
  }


  Set<DateTime> _generateDisabledDates(DateTime? startDate, DateTime? endDate) {
    Set<DateTime> disabledDates = {};
    if (startDate != null && endDate != null) {
      for (DateTime date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        disabledDates.add(DateTime(date.year, date.month, date.day));
      }
    }
    return disabledDates;
  }

}
