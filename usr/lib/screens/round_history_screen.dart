import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoundHistoryScreen extends StatefulWidget {
  const RoundHistoryScreen({super.key});

  @override
  State<RoundHistoryScreen> createState() => _RoundHistoryScreenState();
}

class _RoundHistoryScreenState extends State<RoundHistoryScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _rounds = [];

  @override
  void initState() {
    super.initState();
    _fetchRounds();
  }

  Future<void> _fetchRounds() async {
    try {
      // Fetch data from the existing round_summary table
      // We select all fields to ensure we capture name, course_name, and the date field
      final response = await _supabase
          .from('round_summary')
          .select()
          .order('created_at', ascending: false);
          
      if (mounted) {
        setState(() {
          _rounds = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching rounds: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading round history: $e')),
        );
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Round History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rounds.isEmpty
              ? const Center(
                  child: Text(
                    'No rounds found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _rounds.length,
                  itemBuilder: (context, index) {
                    final round = _rounds[index];
                    
                    // Extract fields with fallbacks
                    final name = round['name']?.toString() ?? 'Unknown Player';
                    final courseName = round['course_name']?.toString() ?? 'Unknown Course';
                    
                    // Handle standard created_at or custom created_date column names
                    final createdDate = round['created_at']?.toString() ?? round['created_date']?.toString();

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.sports_golf, color: Colors.white),
                        ),
                        title: Text(
                          courseName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Player: $name'),
                            const SizedBox(height: 2),
                            Text(
                              'Date: ${_formatDate(createdDate)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
