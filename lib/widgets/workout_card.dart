import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../core/constants.dart';
import '../core/utils.dart';

/// Professional workout card widget for displaying workout information
class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isSelected;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: isSelected ? 4 : AppConstants.cardElevation,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.defaultSpacing / 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with exercise name and actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultSpacing),
                  
                  // Exercise name and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.exercise,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout.summary,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions menu
                  if (showActions)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: AppConstants.defaultSpacing),
              
              // Workout details
              _buildWorkoutDetails(context),
              
              const SizedBox(height: AppConstants.defaultSpacing),
              
              // Footer with timestamp and volume
              _buildFooter(context),
              
              // Notes section if available
              if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.defaultSpacing),
                _buildNotesSection(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutDetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        _buildDetailChip(
          context,
          icon: Icons.format_list_numbered,
          label: 'Sets',
          value: workout.sets.toString(),
        ),
        const SizedBox(width: AppConstants.defaultSpacing),
        _buildDetailChip(
          context,
          icon: Icons.repeat,
          label: 'Reps',
          value: workout.reps.toString(),
        ),
        const SizedBox(width: AppConstants.defaultSpacing),
        _buildDetailChip(
          context,
          icon: Icons.line_weight,
          label: 'Weight',
          value: '${workout.weight}kg',
        ),
      ],
    );
  }

  Widget _buildDetailChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Timestamp
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              Utils.getRelativeTime(workout.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        
        // Total volume
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up,
                size: 14,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                '${workout.totalVolume.toStringAsFixed(1)}kg',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Notes',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            workout.notes!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}