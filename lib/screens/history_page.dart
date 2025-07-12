import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../widgets/workout_card.dart';
import '../widgets/loading_overlay.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../core/validators.dart';
import '../widgets/custom_text_field.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _workoutService = WorkoutService();
  bool _isLoading = false;

  Future<void> _deleteWorkout(BuildContext context, Workout workout) async {
    final confirmed = await Utils.showConfirmationDialog(
      context,
      AppConstants.dialogDeleteWorkout,
      AppConstants.dialogDeleteConfirmation,
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final result = await _workoutService.deleteWorkout(workout);
      
      if (result.isSuccess && mounted) {
        Utils.showSnackBar(context, AppConstants.successWorkoutDeleted);
      } else if (result.isFailure && mounted) {
        Utils.showSnackBar(
          context, 
          result.exception!.message,
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(
          context, 
          AppConstants.errorGeneral,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editWorkout(BuildContext context, Workout workout) async {
    final result = await showDialog<Workout>(
      context: context,
      builder: (_) => EditWorkoutDialog(workout: workout),
    );

    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final updateResult = await _workoutService.updateWorkout(result);
      
      if (updateResult.isSuccess && mounted) {
        Utils.showSnackBar(context, AppConstants.successWorkoutUpdated);
      } else if (updateResult.isFailure && mounted) {
        Utils.showSnackBar(
          context, 
          updateResult.exception!.message,
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(
          context, 
          AppConstants.errorGeneral,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearAllDialog(context),
            tooltip: 'Clear all workouts',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Processing...',
        child: ValueListenableBuilder<Box<Workout>>(
          valueListenable: _workoutService.getWorkoutListenable(),
          builder: (context, box, _) {
            final workouts = box.values.toList();
            workouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

            if (workouts.isEmpty) {
              return _buildEmptyState(context);
            }

            return Column(
              children: [
                // Statistics header
                _buildStatisticsHeader(context, workouts),
                
                // Workout list
                Expanded(
                  child: ListView.builder(
                    itemCount: workouts.length,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.defaultSpacing,
                    ),
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      
                      return WorkoutCard(
                        workout: workout,
                        onEdit: () => _editWorkout(context, workout),
                        onDelete: () => _deleteWorkout(context, workout),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.fitness_center,
                size: 64,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppConstants.defaultSpacing * 2),
            Text(
              'No workouts logged yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              'Start your fitness journey by adding your first workout!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultSpacing * 2),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add),
              label: const Text('Add Workout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsHeader(BuildContext context, List<Workout> workouts) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final totalWorkouts = workouts.length;
    final totalVolume = workouts.fold<double>(
      0, 
      (sum, workout) => sum + workout.totalVolume,
    );
    final uniqueExercises = workouts.map((w) => w.exercise).toSet().length;
    
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.fitness_center,
                  label: 'Total Workouts',
                  value: totalWorkouts.toString(),
                ),
              ),
              const SizedBox(width: AppConstants.defaultSpacing),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.trending_up,
                  label: 'Total Volume',
                  value: '${totalVolume.toStringAsFixed(1)}kg',
                ),
              ),
              const SizedBox(width: AppConstants.defaultSpacing),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.category,
                  label: 'Exercises',
                  value: uniqueExercises.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showClearAllDialog(BuildContext context) async {
    final confirmed = await Utils.showConfirmationDialog(
      context,
      'Clear All Workouts',
      'Are you sure you want to delete all workouts? This action cannot be undone.',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final result = await _workoutService.clearAllWorkouts();
      
      if (result.isSuccess && mounted) {
        Utils.showSnackBar(context, 'All workouts cleared');
      } else if (result.isFailure && mounted) {
        Utils.showSnackBar(
          context, 
          result.exception!.message,
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(
          context, 
          AppConstants.errorGeneral,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Edit workout dialog
class EditWorkoutDialog extends StatefulWidget {
  final Workout workout;

  const EditWorkoutDialog({super.key, required this.workout});

  @override
  State<EditWorkoutDialog> createState() => _EditWorkoutDialogState();
}

class _EditWorkoutDialogState extends State<EditWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _exerciseController;
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _exerciseController = TextEditingController(text: widget.workout.exercise);
    _setsController = TextEditingController(text: widget.workout.sets.toString());
    _repsController = TextEditingController(text: widget.workout.reps.toString());
    _weightController = TextEditingController(text: widget.workout.weight.toString());
    _notesController = TextEditingController(text: widget.workout.notes ?? '');
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppConstants.dialogEditWorkout),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: AppConstants.labelExercise,
                controller: _exerciseController,
                validator: Validators.validateExercise,
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: AppConstants.labelSets,
                      controller: _setsController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validateSets,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultSpacing),
                  Expanded(
                    child: CustomTextField(
                      label: AppConstants.labelReps,
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validateReps,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              CustomTextField(
                label: AppConstants.labelWeight,
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validateWeight,
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              CustomTextField(
                label: 'Notes (Optional)',
                controller: _notesController,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppConstants.buttonCancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final updatedWorkout = Workout.copy(widget.workout);
              updatedWorkout.updateWith(
                exercise: _exerciseController.text.trim(),
                sets: int.parse(_setsController.text.trim()),
                reps: int.parse(_repsController.text.trim()),
                weight: double.parse(_weightController.text.trim()),
                notes: _notesController.text.trim().isNotEmpty 
                    ? _notesController.text.trim() 
                    : null,
              );
              Navigator.of(context).pop(updatedWorkout);
            }
          },
          child: const Text(AppConstants.buttonUpdate),
        ),
      ],
    );
  }
}