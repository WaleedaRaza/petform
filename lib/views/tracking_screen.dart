import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../models/tracking_metric.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import 'metric_detail_screen.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  Future<void> _addMetric(BuildContext context, Pet pet) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _MetricDialog(),
    );

    if (result != null && result['name'] != null && result['frequency'] != null) {
      final newMetric = TrackingMetric(
        id: 'metric_${DateTime.now().millisecondsSinceEpoch}',
        petId: pet.id.toString(),
        name: result['name']!,
        frequency: result['frequency']!,
        targetValue: double.tryParse(result['targetValue'] ?? '10.0') ?? 10.0,
      );

      final appState = Provider.of<AppStateProvider>(context, listen: false);
      await appState.addTrackingMetric(newMetric);
    }
  }

  Future<void> _removeMetric(BuildContext context, Pet pet, TrackingMetric metric) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Metric'),
        content: Text('Are you sure you want to remove "${metric.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );

    if (confirmed == true) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      await appState.removeTrackingMetric(metric);
    }
  }

  void _updateMetricValue(BuildContext context, Pet pet, TrackingMetric metric, double newValue) async {
    final updatedMetric = metric.addEntry(newValue);
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await appState.updateTrackingMetric(updatedMetric);
  }

  void _showEditDialog(BuildContext context, Pet pet, TrackingMetric metric) {
    final nameController = TextEditingController(text: metric.name);
    final targetValueController = TextEditingController(text: metric.targetValue.toString());
    String selectedFrequency = metric.frequency;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Metric'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Metric Name',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Frequency'),
                value: selectedFrequency,
                items: ['daily', 'weekly', 'monthly']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (value) => setState(() => selectedFrequency = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Value',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
                          TextButton(
                onPressed: () {
                  final targetValue = double.tryParse(targetValueController.text);
                  if (nameController.text.isNotEmpty && targetValue != null) {
                    final updatedMetric = metric.copyWith(
                      name: nameController.text,
                      frequency: selectedFrequency,
                      targetValue: targetValue,
                    );
                    final appState = Provider.of<AppStateProvider>(context, listen: false);
                    appState.updateTrackingMetric(updatedMetric);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, Pet pet, TrackingMetric metric) {
    final controller = TextEditingController(text: metric.currentValue.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${metric.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'New Value',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null) {
                _updateMetricValue(context, pet, metric, newValue);
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    if (appState.pets.isEmpty) {
      return const Scaffold(body: Center(child: Text('No pet added yet')));
    }
    final pet = appState.pets.first;
    final metrics = appState.getMetricsByPet(pet.id.toString());

    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: ListView.builder(
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(metric.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text('Frequency: ${metric.frequency}'),
                  Text('Current: ${metric.currentValue} • Target: ${metric.targetValue}'),
                  if (metric.lastUpdated != null)
                    Text('Last Updated: ${metric.lastUpdated!.toString().split('.')[0]}'),
              ],
            ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(context, pet, metric),
                    tooltip: 'Edit Metric',
                  ),
                  IconButton(
                    icon: const Icon(Icons.update),
                    onPressed: () => _showUpdateDialog(context, pet, metric),
                    tooltip: 'Update Value',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeMetric(context, pet, metric),
                    tooltip: 'Remove Metric',
                  ),
                ],
              ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MetricDetailScreen(metric: metric)),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMetric(context, pet),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MetricDialog extends StatefulWidget {
  @override
  __MetricDialogState createState() => __MetricDialogState();
}

class __MetricDialogState extends State<_MetricDialog> {
  final _nameController = TextEditingController();
  final _targetValueController = TextEditingController(text: '10.0');
  String? _selectedFrequency;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Metric'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Metric Name'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Frequency'),
            items: ['daily', 'weekly', 'monthly']
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (value) => setState(() => _selectedFrequency = value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _targetValueController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Target Value'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'name': _nameController.text,
              'frequency': _selectedFrequency ?? 'daily',
              'targetValue': _targetValueController.text,
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
