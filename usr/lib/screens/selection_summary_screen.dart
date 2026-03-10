import 'package:flutter/material.dart';

class SelectionSummaryScreen extends StatelessWidget {
  const SelectionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the JSON object passed from the previous screen
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selection Summary'),
      ),
      body: data.isEmpty
          ? const Center(
              child: Text(
                'No data available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final key = data.keys.elementAt(index);
                final value = data[key];
                
                // Format the key to be more readable (e.g., 'user_handicap' -> 'User Handicap')
                final formattedKey = key
                    .split('_')
                    .map((word) => word.isNotEmpty 
                        ? '${word[0].toUpperCase()}${word.substring(1)}' 
                        : '')
                    .join(' ');

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.info_outline, color: Colors.white),
                    ),
                    title: Text(
                      formattedKey,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 20, 
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/active_round');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Start Round',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
