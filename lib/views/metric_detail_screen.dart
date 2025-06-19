import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tracking_metric.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';

class MetricDetailScreen extends StatefulWidget {
  final TrackingMetric metric;

  const MetricDetailScreen({super.key, required this.metric});

  @override
  _MetricDetailScreenState createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen> {
  final _valueController = TextEditingController();
  bool _isSaving = false;

  Future<void> _addEntry() async {
    if (_valueController.text.isEmpty) return;
    
    setState(() {
      widget.metric.history.add(
        MetricHistory(
          timestamp: DateTime.now(),
          value: _valueController.text,
        ),
      );
      widget.metric.lastCompletion = DateTime.now();
    });
    
    _valueController.clear();

    try {
      setState(() => _isSaving = true);
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      if (userProvider.pets.isNotEmpty) {
        final pet = userProvider.pets.first;
        await apiService.updatePet(pet);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.metric.name ?? 'Metric Detail')),
      body: Column(
        children: [
          Expanded(
            child: widget.metric.history.isEmpty
                ? const Center(
                    child: Text(
                      'No entries yet\nAdd your first entry below',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: widget.metric.history.length,
                    itemBuilder: (context, index) {
                      final entry = widget.metric.history[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(entry.value ?? 'No value'),
                          subtitle: Text(
                            '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} '
                            '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    decoration: InputDecoration(
                      labelText: 'Enter ${widget.metric.name} value',
                      border: const OutlineInputBorder(),
                      filled: true,
                    ),
                    onSubmitted: (_) => _addEntry(),
                  ),
                ),
                const SizedBox(width: 10),
                _isSaving
                    ? const CircularProgressIndicator()
                    : IconButton(
                        onPressed: _addEntry,
                        icon: const Icon(Icons.add),
                        iconSize: 32,
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}