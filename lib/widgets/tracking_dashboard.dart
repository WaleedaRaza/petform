import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class TrackingDashboard extends StatelessWidget {
  const TrackingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final metrics = appState.trackingMetrics;
    
    if (metrics.isEmpty) {
      return _buildEmptyState(context);
    }

    final onTrackMetrics = appState.getMetricsOnTrack();
    final needsAttentionMetrics = appState.getMetricsNeedingAttention();
    final recentMetrics = appState.getRecentMetrics();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Metrics',
                  metrics.length.toString(),
                  Icons.track_changes,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'On Track',
                  onTrackMetrics.length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Need Attention',
                  needsAttentionMetrics.length.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Recent activity
          if (recentMetrics.isNotEmpty) ...[
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentMetrics.length,
                itemBuilder: (context, index) {
                  final metric = recentMetrics[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(metric.category),
                                  color: _getCategoryColor(metric.category),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    metric.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${metric.currentValue.toStringAsFixed(1)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: metric.progressPercentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(metric.progressPercentage),
                              ),
                              minHeight: 4,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${metric.progressPercentage.toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Quick actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Add Entry',
                  Icons.add,
                  Colors.blue,
                  () {
                    // TODO: Show add entry dialog
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'View All',
                  Icons.list,
                  Colors.green,
                  () {
                    // TODO: Navigate to tracking screen
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Add Metric',
                  Icons.add_chart,
                  Colors.orange,
                  () {
                    // TODO: Show add metric dialog
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.track_changes,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Tracking Metrics Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your pet\'s health and activities to see insights here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to add metric
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Metric'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'health':
        return Icons.favorite;
      case 'exercise':
        return Icons.directions_run;
      case 'nutrition':
        return Icons.restaurant;
      case 'behavior':
        return Icons.psychology;
      case 'care':
        return Icons.brush;
      default:
        return Icons.track_changes;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'health':
        return Colors.red;
      case 'exercise':
        return Colors.blue;
      case 'nutrition':
        return Colors.green;
      case 'behavior':
        return Colors.orange;
      case 'care':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 40) return Colors.yellow;
    return Colors.red;
  }
} 