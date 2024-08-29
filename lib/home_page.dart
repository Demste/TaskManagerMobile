import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:todolist/pages/calendar_page.dart';
import 'package:todolist/pages/create_task_page.dart';
import 'package:todolist/pages/history_page.dart';
import 'package:todolist/pages/profil_page.dart';
import 'package:todolist/pages/stats_page.dart';
import 'package:todolist/pages/task_page.dart';
import 'package:todolist/services/task_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TaskPage(),
    const CalendarPage(),
    const HistoryPage(),
    const ProfilPage(),
    const StatsPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
    @override
  void initState() {
    super.initState();
    
    // Yapılacak işlemleri build işlemi tamamlandıktan sonra başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).updateAssignedTasks();
      Provider.of<TaskProvider>(context, listen: false).updateAllCatagories();
      Provider.of<TaskProvider>(context, listen: false).updateAllUsers();
      Provider.of<TaskProvider>(context, listen: false).updaAllTasks();
    });
  }


  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.black, // Background color of the button
          shape: BoxShape.circle, // Make the button circular
        ),
        child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTaskPage(), // Replace NewPage with your desired page
            ),
          );
        },
          backgroundColor: Colors.black, // Background color of the FAB
          child: const Icon(
            Icons.add,
            color: Colors.amber,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: GNav(
        rippleColor: Colors.white.withOpacity(0.1),
        hoverColor: Colors.white.withOpacity(0.8),
        gap: 3,
        activeColor: Colors.amber[800],
        iconSize: 40,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        duration: const Duration(milliseconds: 300),
        tabBackgroundColor: Colors.black,
        color: Colors.white,
        tabs: const [
          GButton(
            //apps iconuda güzel
            icon: Icons.fact_check_sharp,
            text: 'Görevler',
          ),
          GButton(
            icon: Icons.calendar_month,
            text: 'Takvim',
          ),/*

          GButton(
            icon: Icons.add,
            text: 'Ekle',
          ),*/
          GButton(
            icon: Icons.history,
            text: 'Geçmiş',
          ),
          GButton(
            icon: Icons.account_circle_sharp,
            text: 'Profil',
          ),
          GButton(
            icon: Icons.bar_chart_sharp,
            text: 'Stat',
          ),

        ],
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped, // Only use this callback
      ),
    );
  }
}
