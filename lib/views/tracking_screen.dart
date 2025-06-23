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

    if (result != null && result['name'] != null && result['type'] != null && result['unit'] != null) {
      final newMetric = TrackingMetric(
        id: '${pet.id}-${pet.trackingMetrics.length}',
        petId: pet.id.toString(),
        name: result['name']!,
        type: result['type']!,
        unit: result['unit']!,
        targetValue: double.tryParse(result['targetValue'] ?? '10.0') ?? 10.0,
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

  void _updateMetricValue(BuildContext context, Pet pet, TrackingMetric metric, double newValue) async {
    final updatedMetric = metric.addEntry(newValue);
    final index = pet.trackingMetrics.indexWhere((m) => m.id == metric.id);
    if (index != -1) {
      pet.trackingMetrics[index] = updatedMetric;
    await Provider.of<ApiService>(context, listen: false).updatePet(pet);
    (context as Element).markNeedsBuild();
    }
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
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(metric.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text('Type: ${metric.type} • Unit: ${metric.unit}'),
                  Text('Current: ${metric.currentValue} ${metric.unit} • Target: ${metric.targetValue} ${metric.unit}'),
                  if (metric.lastUpdated != null)
                    Text('Last Updated: ${metric.lastUpdated!.toString().split('.')[0]}'),
              ],
            ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showUpdateDialog(context, pet, metric),
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
            labelText: 'New Value (${metric.unit})',
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
}

class _MetricDialog extends StatefulWidget {
  @override
  __MetricDialogState createState() => __MetricDialogState();
}

class __MetricDialogState extends State<_MetricDialog> {
  final _nameController = TextEditingController();
  final _targetValueController = TextEditingController(text: '10.0');
  String? _selectedType;
  String? _selectedUnit;

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
            decoration: const InputDecoration(labelText: 'Type'),
            items: ['weight', 'duration', 'count', 'temperature']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Unit'),
            items: _getUnitsForType(_selectedType)
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (value) => setState(() => _selectedUnit = value),
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
              'type': _selectedType ?? 'count',
              'unit': _selectedUnit ?? 'times',
              'targetValue': _targetValueController.text,
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  List<String> _getUnitsForType(String? type) {
    switch (type) {
      case 'weight':
        return ['lbs', 'kg', 'oz', 'g'];
      case 'duration':
        return ['minutes', 'hours', 'days'];
      case 'count':
        return ['times', 'times/day', 'times/week'];
      case 'temperature':
        return ['°F', '°C'];
      default:
        return ['times'];
    }
  }
}
