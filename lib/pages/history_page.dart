import 'package:flutter/material.dart';
import 'package:todolist/pages/history_pages/postponed_page.dart';
import 'package:todolist/pages/history_pages/done_task_page.dart';
import 'package:todolist/pages/history_pages/log_page.dart';

// Global değişkenler
int logBadgeCount = 0;
int doneBadgeCount = 0;
int postponedBadgeCount = 0;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController=TabController(length: 3, vsync: this);
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Geçmiş'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Stack(
                children: [
                  const Tab(icon: Icon(Icons.history)),
                  if (logBadgeCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$logBadgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              Stack(
                children: [
                  const Tab(icon: Icon(Icons.done)),
                  if (doneBadgeCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$doneBadgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              Stack(
                children: [
                  const Tab(icon: Icon(Icons.delete_forever)),
                  if (postponedBadgeCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$postponedBadgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            LogPage(
              onPageVisible: () {
                setState(() {
                  logBadgeCount = 0;
                });
              },
            ),
            DoneTaskPage(
              onPageVisible: () {
                setState(() {
                  doneBadgeCount = 0;
                });
              },
            ),
            PostponedPage(
              onPageVisible: () {
                setState(() {
                  postponedBadgeCount = 0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
