import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/models/task_item.dart';
import 'package:todolist/models/user.dart';
import 'package:todolist/services/task_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late List<User> allUsers;
  late List<TaskItem> allTasks;
  late Map<String, int> categoryCounts;
  late Map<User, Map<String, int>> tasksCount;

  @override
  void initState() {
    super.initState();
    _fetchStatsData();
  }

  Future<void> _fetchStatsData() async {

    final taskProvider = Provider.of<TaskProvider>(context,listen: false);

    
    // Tüm kullanıcılar
    allUsers = taskProvider.allUsers;

    // Tüm görevler
    allTasks = taskProvider.allTaskItems;

    // Bugünün tarihi
    final today = DateTime.now();

    // Create a map to hold the counts for each category
    categoryCounts = {};

    // Iterate through all tasks and count active tasks per category
    for (var taskItem in allTasks) {
      if (taskItem.task.status != 4) { // Check if the task is active
        for (var category in taskItem.categories) {
          final categoryName = category.name;
          if (categoryCounts.containsKey(categoryName)) {
            categoryCounts[categoryName] = categoryCounts[categoryName]! + 1;
          } else {
            categoryCounts[categoryName] = 1;
          }
        }
      }
    }

    // Initialize tasksCount
    tasksCount = {};

    // Her kullanıcı için tamamlanan, aktif ve süresi geçmiş görev sayısını hesapla
    for (var user in allUsers) {
      int completedCount = 0;
      int activeCount = 0;
      int overdueCount = 0;
      int ontimeComplete = 0; // New counter for on-time completions
      int delayedComplete = 0; // New counter for delayed completions

      for (var taskItem in allTasks) {
        if (taskItem.assignedUsers.any((assignedUser) => assignedUser.id == user.id)) {
          if (taskItem.task.status == 4) {
            // Eğer görev tamamlanmışsa
            completedCount++;
            // Check if the task was completed on time or delayed
            if (taskItem.task.completeDate != null &&
                taskItem.task.estimatedCompleteDate != null) {
              if (taskItem.task.completeDate!.isBefore(taskItem.task.estimatedCompleteDate!) ||
                  taskItem.task.completeDate!.isAtSameMomentAs(taskItem.task.estimatedCompleteDate!)) {
                ontimeComplete++;
              } else {
                delayedComplete++;
              }
            }
          } else {
            // Eğer görev aktifse (status 4 değil)
            activeCount++;
            if (taskItem.task.estimatedCompleteDate != null &&
                taskItem.task.estimatedCompleteDate!.isBefore(today)) {
              // Eğer tahmini bitiş tarihi geçmişse
              overdueCount++;
            }
          }
        }
      }

      tasksCount[user] = {
        'completed': completedCount,
        'active': activeCount,
        'overdue': overdueCount,
        'ontimeComplete': ontimeComplete,
        'delayedComplete': delayedComplete,
      };
    }

    setState(() {}); // Trigger a rebuild with updated data
  }

  @override
  Widget build(BuildContext context) {
    // Prepare pie chart data
    final pieChartSections = categoryCounts.entries.map((entry) {
      final categoryName = entry.key;
      final count = entry.value;

      return PieChartSectionData(
        color: _getRandomColor(), // Use random color here
        value: count.toDouble(),
        title: '$categoryName\n$count',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white),
      );
    }).toList();

    // Bar chart verilerini hazırlama
    final barChartData = tasksCount.entries.map((entry) {
      final user = entry.key;
      final counts = entry.value;

      final completedHeight = counts['completed']!.toDouble();
      final activeHeight = counts['active']!.toDouble();
      final overdueHeight = counts['overdue']!.toDouble();
      final ontimeCompleteHeight = counts['ontimeComplete']!.toDouble();

      return BarChartGroupData(
        x: user.id, // Kullanıcı ID'sini x ekseninde göstermek için
        barRods: [
          BarChartRodData(
            toY: overdueHeight,
            color: Colors.red,
            width: 15,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: activeHeight,
              color: Colors.blue,
            ),
          ),
          BarChartRodData(
            toY: ontimeCompleteHeight,
            color: Colors.green,
            width: 15,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: completedHeight,
              color: Colors.green.withOpacity(0.3),
            ),
          ),
        ],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
      onRefresh: () async {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        
        // Wait for updates to complete
        await taskProvider.updaAllTasks();
        await taskProvider.updateAllUsers();
        
        // Then fetch the data
        await _fetchStatsData(); // Re-fetch data after updating
      },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: SizedBox(
                height: 300, // Adjust height as needed
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            final userId = value.toInt();
                            final userName = tasksCount.keys
                                .firstWhere((user) => user.id == userId)
                                .name;
                            final initials = userName?.substring(0, 3).toUpperCase() ?? '';
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                initials,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                value.toString(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Hide top titles
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Hide top titles
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barChartData,
                    gridData: const FlGridData(show: true),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildLegendItem(color: Colors.red, text: 'Süresi Geçmiş Görevler'),
                  _buildLegendItem(color: Colors.blue, text: 'Aktif Görevler'),
                  _buildLegendItem(color: Colors.green, text: 'Zamanında Tamamlanan Görevler'),
                  _buildLegendItem(color: Colors.green.withOpacity(0.3), text: 'Tamamlanan Görevler'),
                ],
              ),
            ),
            _buildPieChart("Kategorilere Göre Görev Sayısı", pieChartSections),


            ...tasksCount.entries.map((entry) {
              final user = entry.key;
              final counts = entry.value;

              return ListTile(
                title: Text(user.name!),
                subtitle: Text(
                  'Tamamlanan Görevler: ${counts['completed']}\n'
                  'Aktif Görevler: ${counts['active']}\n'
                  'Süresi Geçmiş Görevler: ${counts['overdue']}',
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  Widget _buildPieChart(String title, List<PieChartSectionData> sections) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Space between title and chart
          SizedBox(
            height: 300, // Adjust height as needed
            child: PieChart(
              PieChartData(
                sections: sections,
                borderData: FlBorderData(show: false),
                centerSpaceRadius: 50, // Adjust as needed
                sectionsSpace: 2, // Space between sections
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
  
}
