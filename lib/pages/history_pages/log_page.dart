import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/services/log_service.dart';

class LogPage extends StatelessWidget {
  final VoidCallback onPageVisible;
  const LogPage({super.key, required this.onPageVisible});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onPageVisible();
    });
    return Scaffold(
      body: Consumer<LogService>(
        builder: (context, logService, child) {
          final logEntries = logService.logEntries.reversed.toList();
          return ListView.builder(
            reverse: false, // Listeyi ters çeviriyoruz, en son eklenen en üstte
            itemCount: logEntries.length,
            itemBuilder: (context, index) {
              final logEntry = logEntries[index];
              return ListTile(
                title: Text(logEntry.message),
                subtitle: Text(logEntry.formattedTimestamp), // Formatlanmış timestamp
              );
            },
          );
        },
      ),
    );
  }

}

