import 'package:flutter/material.dart';

class ActiveRoundScreen extends StatelessWidget {
  const ActiveRoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the JSON object passed from the summary screen
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Round'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_golf, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Your round has started!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Good luck and have fun!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            // Display a small summary of the passed data to verify it was received
            if (data.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Round Parameters',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(),
                        ...data.entries.map((entry) {
                          final formattedKey = entry.key
                              .split('_')
                              .map((word) => word.isNotEmpty 
                                  ? '${word[0].toUpperCase()}${word.substring(1)}' 
                                  : '')
                              .join(' ');
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formattedKey, style: const TextStyle(color: Colors.grey)),
                                Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
