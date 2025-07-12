import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String _formatDate(DateTime date) {
    return "${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} - "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _deleteWorkout(BuildContext context, Workout workout) async {
    await WorkoutService().deleteWorkout(workout);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Workout deleted")),
    );
  }

  void _editWorkout(BuildContext context, Workout workout) {
    final exerciseController = TextEditingController(text: workout.exercise);
    final setsController = TextEditingController(text: workout.sets.toString());
    final repsController = TextEditingController(text: workout.reps.toString());
    final weightController = TextEditingController(text: workout.weight.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Workout"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: exerciseController,
                decoration: const InputDecoration(labelText: 'Exercise'),
              ),
              TextField(
                controller: setsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sets'),
              ),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              workout.exercise = exerciseController.text.trim();
              workout.sets = int.tryParse(setsController.text.trim()) ?? workout.sets;
              workout.reps = int.tryParse(repsController.text.trim()) ?? workout.reps;
              workout.weight = double.tryParse(weightController.text.trim()) ?? workout.weight;
              await workout.save();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Workout updated")),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Workout>('workouts');

    return Scaffold(
      appBar: AppBar(title: const Text("Workout History")),
      body: ValueListenableBuilder<Box<Workout>>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          final workouts = box.values.toList().reversed.toList();

          if (workouts.isEmpty) {
            return const Center(child: Text("No workouts logged yet."));
          }

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (_, index) {
              final workout = workouts[index];

              return Dismissible(
                key: ValueKey(workout.key),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteWorkout(context, workout),
                child: ListTile(
                  title: Text("${workout.exercise} - ${workout.sets}x${workout.reps} @ ${workout.weight}kg"),
                  subtitle: Text(_formatDate(workout.timestamp)),
                  onTap: () => _editWorkout(context, workout),
                ),
              );
            },
          );
        },
      ),
    );
  }
}