import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../models/tracking_metric.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'metric_detail_screen.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  Future<void> _addMetric(BuildContext context, Pet pet) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _MetricDialog(),
    );

    if (result != null && result['name'] != null && result['frequency'] != null) {
      final newMetric = TrackingMetric(
        id: '${pet.id}-${pet.trackingMetrics.length}',
        petId: pet.id.toString(),
        name: result['name'],
        frequency: result['frequency'],
      );

      pet.trackingMetrics.add(newMetric);
      await Provider.of<ApiService>(context, listen: false).updatePet(pet);
      (context as Element).markNeedsBuild();
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
      pet.trackingMetrics.remove(metric);
      await Provider.of<ApiService>(context, listen: false).updatePet(pet);
      (context as Element).markNeedsBuild();
    }
  }

  void _toggleCompletion(BuildContext context, Pet pet, TrackingMetric metric) async {
    metric.isCompleted = !metric.isCompleted;
    metric.lastCompletion = metric.isCompleted ? DateTime.now() : null;
    await Provider.of<ApiService>(context, listen: false).updatePet(pet);
    (context as Element).markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    if (userProvider.pets.isEmpty) {
      return const Scaffold(body: Center(child: Text('No pet added yet')));
    }
    final pet = userProvider.pets.first;
    final metrics = pet.trackingMetrics;

    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: ListView.builder(
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return ListTile(
            title: Text(metric.name ?? 'Unnamed Metric'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Frequency: ${metric.frequency ?? 'N/A'}'),
                Text('Last: ${metric.lastCompletion?.toString() ?? 'N/A'}'),
              ],
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: Icon(
                    metric.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: metric.isCompleted ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => _toggleCompletion(context, pet, metric),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeMetric(context, pet, metric),
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MetricDetailScreen(metric: metric)),
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
            items: ['Daily', 'Weekly', 'Monthly']
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (value) => setState(() => _selectedFrequency = value),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'name': _nameController.text,
              'frequency': _selectedFrequency ?? 'Unspecified',
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
