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

  // Tee State
  List<Map<String, dynamic>> _tees = [];
  Map<String, dynamic>? _selectedTee;
  bool _isLoadingTees = false;

  // Confirmation State
  bool _isConfirming = false;

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
      _tees = [];
      _selectedTee = null;
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

  Future<void> _fetchTeesForCourse(String courseId) async {
    setState(() {
      _isLoadingTees = true;
      _tees = [];
      _selectedTee = null;
    });

    try {
      final response = await _supabase
          .from('course_tee_header')
          .select('id, name, color')
          .eq('course_id', courseId)
          .order('name');
          
      if (mounted) {
        setState(() {
          _tees = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('Error fetching tees: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tees: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTees = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _getCurrentUserRecord() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      return await _supabase
          .from('user')
          .select()
          .eq('auth_user_id', userId)
          .maybeSingle();
    } catch (e) {
      debugPrint('Error fetching user record: $e');
      return null;
    }
  }

  // ===========================================================================
  // TODO: Implement your custom logic in this function
  // ===========================================================================
  Future<Map<String, dynamic>> processSelectionData(
    Map<String, dynamic> selectedTee,
    Map<String, dynamic> currentUser,
  ) async {
    // Replace this with your actual code that returns the JSON object
    debugPrint('Processing tee: ${selectedTee['name']} for user: ${currentUser['user_name']}');
    
    return {
      'user_handicap': 79,
      'handicap': 80,
      'slope_rating': 81,
      'course_rating': 82,
      'par': 83
    };
  }
  // ===========================================================================

  Future<void> _handleConfirmation() async {
    if (_selectedTee == null) return;

    setState(() {
      _isConfirming = true;
    });

    try {
      // 1. Fetch the current user's record from the database
      final userRecord = await _getCurrentUserRecord();
      
      if (userRecord == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Could not fetch user profile. Please update your profile first.'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      // 2. Pass both records into the placeholder function
      final jsonResult = await processSelectionData(_selectedTee!, userRecord);
      
      // 3. Log the result and navigate to the summary screen
      debugPrint('JSON Result generated: $jsonResult');

      if (mounted) {
        // Navigate to the summary screen, passing the JSON result as arguments
        Navigator.pushNamed(context, '/summary', arguments: jsonResult);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during confirmation: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
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
                              _tees = [];
                              _selectedTee = null;
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
                      _selectedTee = null;
                      _tees = [];
                    });
                    if (value != null) {
                      _fetchTeesForCourse(value['id'].toString());
                    }
                  },
                ),
                
              if (_selectedCourse != null) ...[
                const SizedBox(height: 32),
                const Text(
                  'Select a Tee:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                if (_isLoadingTees)
                  const Center(child: CircularProgressIndicator())
                else if (_tees.isEmpty)
                  const Text(
                    'No tees found for this course.', 
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)
                  )
                else
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.sports_golf),
                    ),
                    hint: const Text('Choose a tee'),
                    value: _selectedTee,
                    isExpanded: true,
                    items: _tees.map((tee) {
                      // Parse the hex color from the database
                      Color teeColor = Colors.grey;
                      try {
                        String hexColor = tee['color'].toString().replaceAll('#', '');
                        if (hexColor.length == 6) {
                          hexColor = 'FF$hexColor'; // Add full opacity
                        }
                        teeColor = Color(int.parse(hexColor, radix: 16));
                      } catch (e) {
                        // Fallback to grey if parsing fails
                      }

                      // Determine text color based on background brightness for readability
                      Color textColor = teeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: tee,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: teeColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Text(
                            tee['name'] as String,
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTee = value;
                      });
                    },
                  ),
              ],

              if (_selectedTee != null) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isConfirming ? null : _handleConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: _isConfirming
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Confirm Selection', style: TextStyle(fontSize: 16)),
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
