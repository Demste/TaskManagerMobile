import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/pages/login_page.dart';
import 'package:todolist/services/log_service.dart';
import 'package:todolist/services/task_provider.dart';
import 'package:todolist/theme/theme_provider.dart';


void main() {
  runApp(const MyApp(
    
  ));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});  // `key` parametresini ekleyin
  

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskProvider>(create: (context) => TaskProvider(),),
        ChangeNotifierProvider(create: (context) => LogService()),
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()), // Add ThemeProvider here

      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return const MaterialApp(
            //theme: themeProvider.currentTheme, // Use the theme from ThemeProvider
            debugShowCheckedModeBanner: false,
            home: LoginPage(),
          );
        },
      ),
    );
  }
}