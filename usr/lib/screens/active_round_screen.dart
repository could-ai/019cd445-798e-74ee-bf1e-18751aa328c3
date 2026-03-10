import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActiveRoundScreen extends StatefulWidget {
  const ActiveRoundScreen({super.key});

  @override
  State<ActiveRoundScreen> createState() => _ActiveRoundScreenState();
}

class _ActiveRoundScreenState extends State<ActiveRoundScreen> {
  final _supabase = Supabase.instance.client;
  
  Map<String, dynamic> _roundData = {};
  bool _isLoading = true;
  String _userName = 'Player';
  
  // Controllers for the 18 holes
  final Map<int, TextEditingController> _scoreControllers = {};
  
  // Scroll controller for the horizontal scorecard
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers for holes 1 to 18
    for (int i = 1; i <= 18; i++) {
      _scoreControllers[i] = TextEditingController();
    }
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the JSON object passed from the summary screen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _roundData.isEmpty) {
      _roundData = args;
    }
  }

  @override
  void dispose() {
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Fetch user name from the user table
      final userData = await _supabase
          .from('user')
          .select('user_name')
          .eq('auth_user_id', userId)
          .maybeSingle();
          
      if (userData != null && userData['user_name'] != null) {
        _userName = userData['user_name'];
      }

      // 2. Fetch existing scores for this user from the round_hole table
      final scoresData = await _supabase
          .from('round_hole')
          .select('hole_number, score')
          .eq('auth_user_id', userId);

      // Populate the controllers with existing scores
      for (var row in scoresData) {
        final hole = row['hole_number'] as int;
        final score = row['score'] as int;
        if (_scoreControllers.containsKey(hole)) {
          _scoreControllers[hole]!.text = score.toString();
        }
      }
    } catch (e) {
      debugPrint('Error loading round data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveScore(int hole, String value) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      if (value.trim().isEmpty) {
        // If the user clears the field, delete the score record
        await _supabase
            .from('round_hole')
            .delete()
            .match({'auth_user_id': userId, 'hole_number': hole});
        return;
      }

      final score = int.tryParse(value.trim());
      if (score == null) return; // Ignore invalid non-numeric input

      // Upsert the score. The table has a unique constraint on (auth_user_id, hole_number)
      await _supabase.from('round_hole').upsert({
        'auth_user_id': userId,
        'hole_number': hole,
        'score': score,
      }, onConflict: 'auth_user_id, hole_number');
      
    } catch (e) {
      debugPrint('Error saving score for hole $hole: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save score for hole $hole'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Round'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // Vertical scrolling for the entire page
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_golf, size: 60, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Your round is in progress!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  // Scorecard Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Scorecard',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Custom Table Layout for Fixed Column + Scrollable Columns
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fixed Player Column
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 56,
                                  color: Colors.green,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: const Text(
                                    'Player',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Container(
                                  height: 60,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    _userName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Scrollable Holes Columns
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController,
                              scrollDirection: Axis.horizontal,
                              // No Scrollbar widget here to keep it hidden
                              child: Column(
                                children: [
                                  // Header Row (1 to 18)
                                  Row(
                                    children: List.generate(18, (index) {
                                      return Container(
                                        width: 56,
                                        height: 56,
                                        color: Colors.green,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      );
                                    }),
                                  ),
                                  // Data Row (TextFields)
                                  Row(
                                    children: List.generate(18, (index) {
                                      final hole = index + 1;
                                      return Container(
                                        width: 56,
                                        height: 60,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                        alignment: Alignment.center,
                                        child: TextField(
                                          controller: _scoreControllers[hole],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          maxLength: 2,
                                          decoration: const InputDecoration(
                                            counterText: '', // Hide the character counter
                                            contentPadding: EdgeInsets.zero,
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) => _saveScore(hole, value),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Add Player Button (Non-functional)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Non-functional as requested
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add Player functionality coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Player'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Display the summary of the passed data below the scorecard
                  if (_roundData.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 2,
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
                              ..._roundData.entries.map((entry) {
                                final formattedKey = entry.key
                                    .split('_')
                                    .map((word) => word.isNotEmpty 
                                        ? '${word[0].toUpperCase()}${word.substring(1)}' 
                                        : '')
                                    .join(' ');
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(formattedKey, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                      Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
