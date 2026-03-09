import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClubSelectionScreen extends StatefulWidget {
  const ClubSelectionScreen({super.key});

  @override
  State<ClubSelectionScreen> createState() => _ClubSelectionScreenState();
}

class _ClubSelectionScreenState extends State<ClubSelectionScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _selectedClub;

  Future<List<Map<String, dynamic>>> _searchClubs(String query) async {
    if (query.isEmpty) {
      return [];
    }
    try {
      // Query the 'club' table where the name matches the search query (case-insensitive)
      final response = await _supabase
          .from('club')
          .select('id, name')
          .ilike('name', '%$query%')
          .limit(10);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error searching clubs: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Club'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search for a Golf Club:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                return await _searchClubs(textEditingValue.text);
              },
              displayStringForOption: (Map<String, dynamic> option) => option['name'] as String,
              onSelected: (Map<String, dynamic> selection) {
                setState(() {
                  _selectedClub = selection;
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Club Name',
                    hintText: 'Start typing a club name...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 350),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            leading: const Icon(Icons.sports_golf, color: Colors.green),
                            title: Text(option['name'] as String),
                            onTap: () {
                              onSelected(option);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            if (_selectedClub != null) ...[
              const Text(
                'Selected Club:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.golf_course, color: Colors.white),
                  ),
                  title: Text(
                    _selectedClub!['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${_selectedClub!['id']}'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
