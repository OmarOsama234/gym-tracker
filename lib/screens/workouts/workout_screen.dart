import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/workout_service.dart';
import '../../models/workout.dart';
import '../../widgets/workout_card.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late Future<List<Workout>> _workoutsFuture;
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() {
    _workoutsFuture = WorkoutService().getAllWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadWorkouts();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Add Workout Section
          _buildQuickAddSection(),
          
          // Workouts List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadWorkouts();
                });
              },
              child: FutureBuilder<List<Workout>>(
                future: _workoutsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: AppConstants.defaultSpacing),
                          Text(
                            'Error loading workouts',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final workouts = snapshot.data ?? [];
                  
                  if (workouts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppConstants.defaultSpacing),
                          Text(
                            'No workouts yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first workout above!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      return WorkoutCard(
                        workout: workouts[index],
                        onEdit: () => _editWorkout(workouts[index]),
                        onDelete: () => _deleteWorkout(workouts[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWorkoutDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickAddSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.greyLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Add Workout',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _exerciseController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise',
                    hintText: 'Push-ups',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.defaultSpacing / 2),
              Expanded(
                child: TextFormField(
                  controller: _setsController,
                  decoration: const InputDecoration(
                    labelText: 'Sets',
                    hintText: '3',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppConstants.defaultSpacing / 2),
              Expanded(
                child: TextFormField(
                  controller: _repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    hintText: '12',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppConstants.defaultSpacing / 2),
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: '50',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _quickAddWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultSpacing,
                ),
              ),
              child: const Text('Add Workout'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _quickAddWorkout() async {
    if (_exerciseController.text.trim().isEmpty ||
        _setsController.text.trim().isEmpty ||
        _repsController.text.trim().isEmpty ||
        _weightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      final workout = Workout(
        exercise: _exerciseController.text.trim(),
        sets: int.parse(_setsController.text.trim()),
        reps: int.parse(_repsController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        timestamp: DateTime.now(),
      );

      await WorkoutService().addWorkout(workout);

      // Clear form
      _exerciseController.clear();
      _setsController.clear();
      _repsController.clear();
      _weightController.clear();

      // Refresh list
      setState(() {
        _loadWorkouts();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding workout: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddWorkoutDialog() {
    final exerciseController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Workout'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: exerciseController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    hintText: 'e.g., Bench Press',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultSpacing),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: setsController,
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultSpacing),
                    Expanded(
                      child: TextFormField(
                        controller: repsController,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultSpacing),
                TextFormField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: '0.0',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (exerciseController.text.trim().isEmpty ||
                    setsController.text.trim().isEmpty ||
                    repsController.text.trim().isEmpty ||
                    weightController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }

                try {
                  final workout = Workout(
                    exercise: exerciseController.text.trim(),
                    sets: int.parse(setsController.text.trim()),
                    reps: int.parse(repsController.text.trim()),
                    weight: double.parse(weightController.text.trim()),
                    date: DateTime.now(),
                  );

                  await WorkoutService().addWorkout(workout);

                  if (mounted) {
                    Navigator.of(context).pop();
                    setState(() {
                      _loadWorkouts();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout added successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editWorkout(Workout workout) {
    final exerciseController = TextEditingController(text: workout.exercise);
    final setsController = TextEditingController(text: workout.sets.toString());
    final repsController = TextEditingController(text: workout.reps.toString());
    final weightController = TextEditingController(text: workout.weight.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Workout'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: exerciseController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultSpacing),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: setsController,
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultSpacing),
                    Expanded(
                      child: TextFormField(
                        controller: repsController,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultSpacing),
                TextFormField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final updatedWorkout = Workout(
                    exercise: exerciseController.text.trim(),
                    sets: int.parse(setsController.text.trim()),
                    reps: int.parse(repsController.text.trim()),
                    weight: double.parse(weightController.text.trim()),
                    timestamp: workout.timestamp,
                  );

                  await WorkoutService().updateWorkout(workout, updatedWorkout);

                  if (mounted) {
                    Navigator.of(context).pop();
                    setState(() {
                      _loadWorkouts();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout updated successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteWorkout(Workout workout) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Workout'),
          content: Text('Are you sure you want to delete "${workout.exercise}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await WorkoutService().deleteWorkout(workout);

                  if (mounted) {
                    Navigator.of(context).pop();
                    setState(() {
                      _loadWorkouts();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout deleted successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
