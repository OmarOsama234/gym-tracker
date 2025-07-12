import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/constants.dart';
import '../core/validators.dart';
import '../core/utils.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  
  final _workoutService = WorkoutService();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final workout = Workout.fromForm(
        exercise: _exerciseController.text.trim(),
        sets: int.parse(_setsController.text.trim()),
        reps: int.parse(_repsController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      final result = await _workoutService.addWorkout(workout);
      
      if (result.isSuccess && mounted) {
        _clearForm();
        Utils.showSnackBar(context, AppConstants.successWorkoutSaved);
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

  void _clearForm() {
    _exerciseController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
            tooltip: AppConstants.navHistory,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Saving workout...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                _buildHeader(context),
                
                const SizedBox(height: AppConstants.defaultSpacing * 2),
                
                // Exercise input
                CustomTextField(
                  label: AppConstants.labelExercise,
                  hint: AppConstants.hintExercise,
                  controller: _exerciseController,
                  prefixIcon: Icons.fitness_center,
                  validator: Validators.validateExercise,
                  maxLength: AppConstants.maxExerciseNameLength,
                ),
                
                const SizedBox(height: AppConstants.defaultSpacing),
                
                // Sets, Reps, Weight row
                Row(
                  children: [
                    Expanded(
                      child: NumericTextField(
                        label: AppConstants.labelSets,
                        hint: AppConstants.hintSets,
                        controller: _setsController,
                        prefixIcon: Icons.format_list_numbered,
                        validator: Validators.validateSets,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultSpacing),
                    Expanded(
                      child: NumericTextField(
                        label: AppConstants.labelReps,
                        hint: AppConstants.hintReps,
                        controller: _repsController,
                        prefixIcon: Icons.repeat,
                        validator: Validators.validateReps,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultSpacing),
                    Expanded(
                      child: NumericTextField(
                        label: AppConstants.labelWeight,
                        hint: AppConstants.hintWeight,
                        controller: _weightController,
                        prefixIcon: Icons.line_weight,
                        validator: Validators.validateWeight,
                        isDecimal: true,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.defaultSpacing),
                
                // Notes input
                CustomTextField(
                  label: 'Notes (Optional)',
                  hint: 'Add any notes about this workout',
                  controller: _notesController,
                  prefixIcon: Icons.note,
                  maxLines: 3,
                  maxLength: 200,
                  showCounter: true,
                ),
                
                const SizedBox(height: AppConstants.defaultSpacing * 2),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveWorkout,
                    icon: const Icon(Icons.save),
                    label: const Text(AppConstants.buttonSave),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.defaultSpacing,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.defaultSpacing),
                
                // Clear button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _clearForm,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Form'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.defaultSpacing,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_circle,
                  color: colorScheme.onPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppConstants.defaultSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Workout',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your fitness progress',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}