import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';
import '../../services/workout_service.dart';
import '../../models/user.dart';
import '../../models/workout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Workout>> _workoutsFuture;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    currentUser = authService.currentUser;
    _workoutsFuture = _loadWorkouts();
  }

  Future<List<Workout>> _loadWorkouts() async {
    final result = WorkoutService().getAllWorkouts();
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw Exception(result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: AppConstants.defaultSpacing * 2),
              
              // Stats Cards
              _buildStatsCards(),
              const SizedBox(height: AppConstants.defaultSpacing * 2),
              
              // Recent Workouts
              _buildRecentWorkouts(),
              const SizedBox(height: AppConstants.defaultSpacing * 2),
              
              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentUser?.displayName ?? 'User',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          Text(
            'Ready to crush your fitness goals today?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return FutureBuilder<List<Workout>>(
      future: _workoutsFuture,
      builder: (context, snapshot) {
        final workouts = snapshot.data ?? [];
        final totalWorkouts = workouts.length;
        final thisWeekWorkouts = workouts.where((w) {
          final weekAgo = DateTime.now().subtract(const Duration(days: 7));
          return w.timestamp.isAfter(weekAgo);
        }).length;
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Workouts',
                value: totalWorkouts.toString(),
                icon: Icons.fitness_center,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppConstants.defaultSpacing),
            Expanded(
              child: _buildStatCard(
                title: 'This Week',
                value: thisWeekWorkouts.toString(),
                icon: Icons.calendar_today,
                color: AppColors.secondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultSpacing),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkouts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Workouts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to workout history
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultSpacing),
        FutureBuilder<List<Workout>>(
          future: _workoutsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            
            final workouts = snapshot.data ?? [];
            if (workouts.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: AppColors.greyLight),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 48,
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
                      'Start your fitness journey today!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            final recentWorkouts = workouts.take(3).toList();
            return Column(
              children: recentWorkouts.map((workout) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: AppColors.greyLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.exercise,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${workout.sets} sets • ${workout.reps} reps • ${workout.weight}kg',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(workout.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultSpacing),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'New Workout',
                icon: Icons.add,
                color: AppColors.primary,
                onTap: () {
                  // Navigate to add workout screen
                },
              ),
            ),
            const SizedBox(width: AppConstants.defaultSpacing),
            Expanded(
              child: _buildActionCard(
                title: 'View Progress',
                icon: Icons.trending_up,
                color: AppColors.secondary,
                onTap: () {
                  // Navigate to progress screen
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
