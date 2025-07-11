import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tracking_metric.dart';
import '../providers/app_state_provider.dart';
import '../widgets/video_background.dart';

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
    
    final value = double.tryParse(_valueController.text);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
      return;
    }
    
    try {
      setState(() => _isSaving = true);
      
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final updatedMetric = widget.metric.addEntry(value);
      await appState.updateTrackingMetric(updatedMetric);
      
      _valueController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added entry: $value')),
        );
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
    return VideoBackground(
      videoPath: 'lib/assets/animation2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(widget.metric.name)),
        body: Column(
          children: [
            // Metric info card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.metric.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatFrequency(widget.metric.frequency),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Target: ${widget.metric.targetValue.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: widget.metric.progressPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.metric.currentValue.toStringAsFixed(1)} / ${widget.metric.targetValue.toStringAsFixed(1)} (${widget.metric.progressPercentage.toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // History section
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
                            title: Text(entry.value.toStringAsFixed(1)),
                            subtitle: Text(
                              '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} '
                              '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            trailing: entry.notes != null
                                ? Icon(Icons.note, color: Colors.grey[400])
                                : null,
                          ),
                        );
                      },
                    ),
            ),
            
            // Add entry section
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
                      keyboardType: TextInputType.number,
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
      ),
    );
  }

  String _formatFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return frequency;
    }
  }
}