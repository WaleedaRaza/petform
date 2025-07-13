import 'package:flutter/material.dart';
import '../services/firestore_verification_service.dart';
import '../widgets/video_background.dart';

class FirestoreTestScreen extends StatefulWidget {
  const FirestoreTestScreen({super.key});

  @override
  _FirestoreTestScreenState createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  final FirestoreVerificationService _verificationService = FirestoreVerificationService();
  Map<String, dynamic>? _testResults;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'lib/assets/animation2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Firestore Test'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Test Buttons
              Card(
                color: Colors.grey[850]!.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Firestore Integration Tests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _runTests,
                        child: Text(_isLoading ? 'Running Tests...' : 'Run Integration Tests'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _getUserData,
                        child: const Text('Get All User Data'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _cleanupTestData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Cleanup Test Data'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Test Results
              if (_testResults != null) ...[
                Card(
                  color: Colors.grey[850]!.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Test Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTestResults(_testResults!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // User Data
              if (_userData != null) ...[
                Card(
                  color: Colors.grey[850]!.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Data in Firestore',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildUserData(_userData!),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestResults(Map<String, dynamic> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: results.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;

        if (value is bool) {
          return ListTile(
            leading: Icon(
              value ? Icons.check_circle : Icons.error,
              color: value ? Colors.green : Colors.red,
            ),
            title: Text(
              key.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              value ? 'PASSED' : 'FAILED',
              style: TextStyle(
                color: value ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else if (value is String && value.contains('error')) {
          return ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: Text(
              key.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (value is Map) {
          return ExpansionTile(
            title: Text(
              key.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  value.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        } else {
          return ListTile(
            title: Text(
              key.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              value.toString(),
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildUserData(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data['user_profile'] != null) ...[
          const Text(
            'User Profile:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            data['user_profile'].toString(),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
        ],
        if (data['pets'] != null) ...[
          Text(
            'Pets (${data['pets'].length}):',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          ...data['pets'].map<Widget>((pet) => Text(
            '  - ${pet['name']} (${pet['type']})',
            style: const TextStyle(color: Colors.grey),
          )),
          const SizedBox(height: 16),
        ],
        if (data['posts'] != null) ...[
          Text(
            'Posts (${data['posts'].length}):',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          ...data['posts'].map<Widget>((post) => Text(
            '  - ${post['title']}',
            style: const TextStyle(color: Colors.grey),
          )),
          const SizedBox(height: 16),
        ],
        if (data['shopping_items'] != null) ...[
          Text(
            'Shopping Items (${data['shopping_items'].length}):',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          ...data['shopping_items'].map<Widget>((item) => Text(
            '  - ${item['name']} (\$${item['price']})',
            style: const TextStyle(color: Colors.grey),
          )),
          const SizedBox(height: 16),
        ],
        if (data['tracking_metrics'] != null) ...[
          Text(
            'Tracking Metrics (${data['tracking_metrics'].length}):',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          ...data['tracking_metrics'].map<Widget>((metric) => Text(
            '  - ${metric['name']}: ${metric['value']} ${metric['unit']}',
            style: const TextStyle(color: Colors.grey),
          )),
        ],
      ],
    );
  }

  Future<void> _runTests() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await _verificationService.testFirestoreIntegration();
      setState(() {
        _testResults = results;
        _isLoading = false;
      });

      // Show results in a snackbar
      final success = results['success'] ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'All tests passed!' : 'Some tests failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _verificationService.getAllUserData();
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cleanupTestData() async {
    setState(() => _isLoading = true);
    
    try {
      await _verificationService.cleanupTestData();
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test data cleaned up successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cleanup test data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 