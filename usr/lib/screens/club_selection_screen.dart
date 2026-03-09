import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClubSelectionScreen extends StatefulWidget {
  const ClubSelectionScreen({super.key});

  @override
  State<ClubSelectionScreen> createState() => _ClubSelectionScreenState();
}

class _ClubSelectionScreenState extends State<ClubSelectionScreen> {
  final _supabase = Supabase.instance.client;
  
  // Club State
  Map<String, dynamic>? _selectedClub;
  
  // Course State
  List<Map<String, dynamic>> _courses = [];
  Map<String, dynamic>? _selectedCourse;
  bool _isLoadingCourses = false;

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

  Future<void> _fetchCoursesForClub(String clubId) async {
    setState(() {
      _isLoadingCourses = true;
      _courses = [];
      _selectedCourse = null;
    });

    try {
      final response = await _supabase
          .from('course_header')
          .select('id, name')
          .eq('club_id', clubId)
          .order('name');
          
      if (mounted) {
        setState(() {
          _courses = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCourses = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Club & Course'),
      ),
      body: SingleChildScrollView(
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
                // Fetch courses when a club is selected
                _fetchCoursesForClub(selection['id'].toString());
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Club Name',
                    hintText: 'Start typing a club name...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _selectedClub != null 
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            textEditingController.clear();
                            setState(() {
                              _selectedClub = null;
                              _courses = [];
                              _selectedCourse = null;
                            });
                          },
                        )
                      : null,
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
            
            // Show Club and Course selection if a club is selected
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
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                'Select a Course:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              if (_isLoadingCourses)
                const Center(child: CircularProgressIndicator())
              else if (_courses.isEmpty)
                const Text(
                  'No courses found for this club.', 
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)
                )
              else
                DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  hint: const Text('Choose a course'),
                  value: _selectedCourse,
                  isExpanded: true,
                  items: _courses.map((course) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: course,
                      child: Text(course['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value;
                    });
                  },
                ),
                
              if (_selectedCourse != null) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected ${_selectedCourse!['name']} at ${_selectedClub!['name']}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm Selection', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ]
            ]
          ],
        ),
      ),
    );
  }
}
