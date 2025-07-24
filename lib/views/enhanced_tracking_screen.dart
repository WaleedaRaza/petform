import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/pet.dart';
import '../models/tracking_metric.dart';
import '../widgets/enhanced_tracking_card.dart';
import '../widgets/video_background.dart';
import 'metric_detail_screen.dart';
import 'pet_profile_creation_screen.dart';
import 'package:flutter/foundation.dart';

class EnhancedTrackingScreen extends StatefulWidget {
  const EnhancedTrackingScreen({super.key});

  @override
  _EnhancedTrackingScreenState createState() => _EnhancedTrackingScreenState();
}

class _EnhancedTrackingScreenState extends State<EnhancedTrackingScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeAppState();
    });
  }

  Future<void> _initializeAppState() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await appState.initialize();
  }

  Widget _buildSearchSection() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final pets = appState.pets;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search tracking metrics...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: pets.isNotEmpty
                ? () => _showAddMetricDialog(context, pets.first)
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Add Metric'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final pets = appState.pets;
    final metrics = appState.trackingMetrics;

    if (kDebugMode) {
      print('EnhancedTrackingScreen: Pets count: ${pets.length}');
      print('EnhancedTrackingScreen: Metrics count: ${metrics.length}');
      print('EnhancedTrackingScreen: Pets: ${pets.map((p) => '${p.name} (${p.id})').toList()}');
      print('EnhancedTrackingScreen: Building with search+add row...');
    }

    if (pets.isEmpty) {
      return VideoBackground(
        videoPath: 'lib/assets/animation2.mp4',
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _buildNoPetsView(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          VideoBackground(
            videoPath: 'lib/assets/animation2.mp4',
            child: Container(),
          ),
          Column(
        children: [
          // Header with title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Pet Tracking',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
              // Search + Add Metric row
          _buildSearchSection(),
          // Main content
          Expanded(
            child: _buildMetricsList(metrics: metrics, pets: pets),
          ),
        ],
      ),
        ],
      ),
    );
  }

  Widget _buildNoPetsView() {
    return Column(
        children: [
          // Header with title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Pet Tracking',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Content
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pets,
                        size: 80,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Pets Added Yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add a pet to start tracking their health and activities. You can monitor weight, exercise, feeding schedules, and more!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PetProfileCreationScreen(),
                          ),
                        );
                        if (result == true) {
                          setState(() {}); // Refresh the screen
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Your First Pet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
    );
  }

  Widget _buildMetricsList({
    required List<TrackingMetric> metrics,
    required List<Pet> pets,
  }) {
    final filteredMetrics = _searchQuery.isEmpty
        ? metrics
        : metrics.where((metric) =>
            metric.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            metric.description?.toLowerCase().contains(_searchQuery.toLowerCase()) == true
          ).toList();

    if (filteredMetrics.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: filteredMetrics.length,
      itemBuilder: (context, index) {
        final metric = filteredMetrics[index];
        final pet = pets.firstWhere(
          (p) => p.id.toString() == metric.petId,
          orElse: () => pets.first,
        );

        return EnhancedTrackingCard(
          metric: metric,
          pet: pet,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MetricDetailScreen(metric: metric),
            ),
          ),
          onAddEntry: () => _showAddEntryDialog(context, metric),
          onEdit: () => _showEditMetricDialog(context, metric),
          onDelete: () => _showDeleteConfirmation(context, metric),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Metrics Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your pet\'s health and activities',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddMetricDialog(BuildContext context, Pet? pet) {
    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a pet first before creating tracking metrics')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => _AddMetricDialog(pet: pet),
    );
  }

  void _showAddEntryDialog(BuildContext context, TrackingMetric metric) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Entry for ${metric.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Value',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) {
                _addEntryToMetric(metric, value);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditMetricDialog(BuildContext context, TrackingMetric metric) {
    showDialog(
      context: context,
      builder: (context) => _EditMetricDialog(metric: metric),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TrackingMetric metric) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Metric'),
        content: Text('Are you sure you want to delete "${metric.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteMetric(metric);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addEntryToMetric(TrackingMetric metric, double value) {
    final updatedMetric = metric.addEntry(value);
            Provider.of<AppStateProvider>(context, listen: false).updateTrackingMetric(updatedMetric.id!, updatedMetric);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added entry: $value')),
    );
  }

  void _deleteMetric(TrackingMetric metric) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
            appState.removeTrackingMetric(metric.id!);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted ${metric.name}')),
    );
  }
}

class _AddMetricDialog extends StatefulWidget {
  final Pet? pet;

  const _AddMetricDialog({this.pet});

  @override
  _AddMetricDialogState createState() => _AddMetricDialogState();
}

class _AddMetricDialogState extends State<_AddMetricDialog> {
  final _nameController = TextEditingController();
  final _targetValueController = TextEditingController(text: '10.0');
  String _selectedFrequency = 'daily';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Tracking Metric'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Metric Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Weight Check, Exercise Time',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              value: _selectedFrequency,
              items: [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (value) => setState(() => _selectedFrequency = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetValueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Value',
                border: OutlineInputBorder(),
                hintText: 'e.g., 50.0',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createMetric,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _createMetric() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a metric name')),
      );
      return;
    }

    if (widget.pet?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot create metric without a valid pet')),
      );
      return;
    }

    final targetValue = double.tryParse(_targetValueController.text);
    if (targetValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target value')),
      );
      return;
    }

    final newMetric = TrackingMetric(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      frequency: _selectedFrequency,
      petId: widget.pet!.id.toString(),
      targetValue: targetValue,
    );

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.addTrackingMetric(newMetric);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${_nameController.text}')),
    );
  }
}

class _EditMetricDialog extends StatefulWidget {
  final TrackingMetric metric;

  const _EditMetricDialog({required this.metric});

  @override
  _EditMetricDialogState createState() => _EditMetricDialogState();
}

class _EditMetricDialogState extends State<_EditMetricDialog> {
  final _nameController = TextEditingController();
  final _targetValueController = TextEditingController();
  String _selectedFrequency = 'daily';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.metric.name;
    _targetValueController.text = widget.metric.targetValue.toString();
    _selectedFrequency = widget.metric.frequency;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Metric'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Metric Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              value: _selectedFrequency,
              items: [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (value) => setState(() => _selectedFrequency = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetValueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Value',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateMetric,
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _updateMetric() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a metric name')),
      );
      return;
    }

    final targetValue = double.tryParse(_targetValueController.text);
    if (targetValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target value')),
      );
      return;
    }

    final updatedMetric = widget.metric.copyWith(
      name: _nameController.text,
      frequency: _selectedFrequency,
      targetValue: targetValue,
    );

    final appState = Provider.of<AppStateProvider>(context, listen: false);
            appState.updateTrackingMetric(updatedMetric.id!, updatedMetric);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated ${_nameController.text}')),
    );
  }
} 