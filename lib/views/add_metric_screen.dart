import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../models/tracking_metric.dart';

class AddMetricScreen extends StatefulWidget {
  const AddMetricScreen({super.key});

  @override
  _AddMetricScreenState createState() => _AddMetricScreenState();
}

class _AddMetricScreenState extends State<AddMetricScreen> {
  final _nameController = TextEditingController();
  String _selectedFrequency = 'Daily';
  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly', 'As Needed'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Add Tracking Metric')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Metric Name',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Frequency:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _frequencies.map((frequency) {
                return ChoiceChip(
                  label: Text(frequency),
                  selected: _selectedFrequency == frequency,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFrequency = frequency;
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    final newMetric = TrackingMetric(
                      name: _nameController.text,
                      frequency: _selectedFrequency,
                      history: [],
                    );
                    trackingProvider.addMetric(context, newMetric);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Metric', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}