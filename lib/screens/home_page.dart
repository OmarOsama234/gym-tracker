import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
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
  final WorkoutService workoutService = WorkoutService();

  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      final newWorkout = Workout(
        _exerciseController.text.trim(),
        int.parse(_setsController.text.trim()),
        int.parse(_repsController.text.trim()),
        double.parse(_weightController.text.trim()),
        DateTime.now(),
      );

      await workoutService.addWorkout(newWorkout);
      _exerciseController.clear();
      _setsController.clear();
      _repsController.clear();
      _weightController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                label: 'Exercise',
                controller: _exerciseController,
                icon: Icons.fitness_center,
                validator: (value) => value!.isEmpty ? 'Enter exercise name' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Sets',
                      controller: _setsController,
                      icon: Icons.format_list_numbered,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value!.isEmpty || int.tryParse(value) == null ? 'Enter valid sets' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Reps',
                      controller: _repsController,
                      icon: Icons.repeat,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value!.isEmpty || int.tryParse(value) == null ? 'Enter valid reps' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Weight (kg)',
                      controller: _weightController,
                      icon: Icons.line_weight,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value!.isEmpty || double.tryParse(value) == null ? 'Enter valid weight' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveWorkout,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Workout'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}