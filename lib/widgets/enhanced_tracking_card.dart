import 'package:flutter/material.dart';
import '../models/tracking_metric.dart';
import '../models/pet.dart';

class EnhancedTrackingCard extends StatelessWidget {
  final TrackingMetric metric;
  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onAddEntry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EnhancedTrackingCard({
    super.key,
    required this.metric,
    required this.pet,
    this.onTap,
    this.onAddEntry,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with pet name and status
              _buildHeader(context),
              
              const SizedBox(height: 12),
              
              // Progress section
              _buildProgressSection(context),
              
              const SizedBox(height: 12),
              
              // Actions
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Pet avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: _getPetTypeColor(),
          child: Text(
            pet.name.isNotEmpty ? pet.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Pet name and metric info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                metric.name,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            metric.status,
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: metric.progressPercentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
          minHeight: 8,
        ),
        
        const SizedBox(height: 8),
        
        // Progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${metric.currentValue.toStringAsFixed(1)} / ${metric.targetValue.toStringAsFixed(1)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${metric.progressPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Frequency and due info
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatFrequency(metric.frequency),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (metric.isDueToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Due Today',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Add entry button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAddEntry,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Edit button
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 20),
          color: Colors.grey[600],
        ),
        
        // Delete button
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, size: 20),
          color: Colors.red[400],
        ),
      ],
    );
  }

  Color _getPetTypeColor() {
    switch (pet.species.toLowerCase()) {
      case 'dog':
        return Colors.blue;
      case 'cat':
        return Colors.orange;
      case 'bird':
        return Colors.green;
      case 'fish':
        return Colors.cyan;
      default:
        return Colors.purple;
    }
  }

  Color _getStatusColor() {
    switch (metric.status) {
      case 'On Track':
        return Colors.green;
      case 'Needs Attention':
        return Colors.red;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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