import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/tracking_metric.dart';
import '../widgets/rounded_button.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  Future<Pet> _loadPet() async {
    final prefs = await SharedPreferences.getInstance();
    final pets = prefs.getString('pets') ?? '[]';
    final petsList = jsonDecode(pets) as List;
    if (petsList.isEmpty) throw Exception('No pet found');
    return Pet.fromJson(petsList.first as Map<String, dynamic>);
  }

  bool _isCompleted(TrackingMetric metric) {
    if (metric.lastCompletion == null) return false;
    final now = DateTime.now();
    switch (metric.frequency) {
      case 'daily':
        return metric.lastCompletion!.year == now.year &&
            metric.lastCompletion!.month == now.month &&
            metric.lastCompletion!.day == now.day;
      case 'weekly':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return metric.lastCompletion!.isAfter(startOfWeek) ||
            metric.lastCompletion!.isAtSameMomentAs(startOfWeek);
      case 'monthly':
        return metric.lastCompletion!.year == now.year &&
            metric.lastCompletion!.month == now.month;
      default:
        return false;
    }
  }

  Future<void> _completeMetric(BuildContext context, Pet pet, TrackingMetric metric) async {
    final updatedMetric = TrackingMetric(
      id: metric.id,
      petId: metric.petId,
      name: metric.name,
      value: metric.value,
      frequency: metric.frequency,
      lastCompletion: DateTime.now(),
      createdAt: metric.createdAt,
    );
    final index = pet.metrics.indexWhere((m) => m.id == metric.id);
    if (index != -1) {
      pet.metrics[index] = updatedMetric;
    }
    final prefs = await SharedPreferences.getInstance();
    final pets = jsonDecode(prefs.getString('pets') ?? '[]') as List;
    if (pets.isNotEmpty) {
      pets[0] = pet.toJson();
      await prefs.setString('pets', jsonEncode(pets));
      if (kDebugMode) {
        print('TrackingScreen: Updated pet metrics');
      }
    }
    // Force rebuild
    (context as Element).markNeedsBuild();
  }

  Future<void> _addMetric(BuildContext context, Pet pet) async {
    String name = '';
    String frequency = 'daily';
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Metric'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Metric Name'),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: ['daily', 'weekly', 'monthly'].map((f) {
                  return DropdownMenuItem(value: f, child: Text(f.capitalize()));
                }).toList(),
                onChanged: (value) => frequency = value!,
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
                if (name.trim().isNotEmpty) {
                  Navigator.pop(context, {'name': name, 'frequency': frequency});
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final newMetric = TrackingMetric(
        id: '${pet.id ?? 1}-${DateTime.now().millisecondsSinceEpoch}',
        petId: '${pet.id ?? 1}',
        name: result['name'],
        frequency: result['frequency'],
        createdAt: DateTime.now(),
      );
      pet.metrics.add(newMetric);
      final prefs = await SharedPreferences.getInstance();
      final pets = jsonDecode(prefs.getString('pets') ?? '[]') as List;
      if (pets.isNotEmpty) {
        pets[0] = pet.toJson();
        await prefs.setString('pets', jsonEncode(pets));
        if (kDebugMode) {
          print('TrackingScreen: Added new metric ${result['name']}');
        }
      }
      // Force rebuild
      (context as Element).markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Tracking')),
      body: FutureBuilder<Pet>(
        future: _loadPet(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('No pets added yet'));
          }
          final pet = snapshot.data!;
          if (pet.metrics.isEmpty) {
            return const Center(child: Text('No tracking metrics available'));
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: pet.metrics.map((metric) {
              final isCompleted = _isCompleted(metric);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(metric.name ?? 'Unnamed Metric'),
                  subtitle: Text('Frequency: ${metric.frequency?.capitalize() ?? 'Unknown'}'),
                  trailing: isCompleted
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : RoundedButton(
                          text: 'Complete',
                          onPressed: () => _completeMetric(context, pet, metric),
                        ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FutureBuilder<Pet>(
        future: _loadPet(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final pet = snapshot.data!;
          return FloatingActionButton(
            onPressed: () => _addMetric(context, pet),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}