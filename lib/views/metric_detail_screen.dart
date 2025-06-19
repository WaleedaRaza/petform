import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tracking_metric.dart';
import '../models/pet.dart';
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

  Future<void> _addEntry() async {
    if (_valueController.text.isNotEmpty) {
      final newEntry = MetricHistory(
        timestamp: DateTime.now(),
        value: _valueController.text,
      );
      setState(() => widget.metric.history.add(newEntry));
      _valueController.clear();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final pet = userProvider.pets.firstWhere((p) => p.id == int.parse(widget.metric.petId!));
      await Provider.of<ApiService>(context, listen: false).updatePet(pet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.metric.name ?? 'Metric Detail')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.metric.history.length,
              itemBuilder: (context, index) {
                final entry = widget.metric.history[index];
                return ListTile(
                  title: Text(entry.value ?? 'No value'),
                  subtitle: Text(entry.timestamp.toString()),
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
                    decoration: const InputDecoration(labelText: 'Enter value'),
                  ),
                ),
                IconButton(onPressed: _addEntry, icon: const Icon(Icons.add)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}