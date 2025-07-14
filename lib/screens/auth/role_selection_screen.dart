import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../main_navigation.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? selectedRole;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.defaultSpacing * 2),
              
              // Title
              Text(
                'Choose Your Role',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              
              // Subtitle
              Text(
                'Please select your role to personalize your experience',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.defaultSpacing * 3),
              
              // Role Cards
              Expanded(
                child: Column(
                  children: [
                    // Trainer Role Card
                    _buildRoleCard(
                      role: UserRole.trainer,
                      title: 'Trainer',
                      description: 'Create workout plans, track client progress, and manage training sessions',
                      icon: Icons.fitness_center,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppConstants.defaultSpacing * 2),
                    
                    // Trainee Role Card
                    _buildRoleCard(
                      role: UserRole.trainee,
                      title: 'Trainee',
                      description: 'Follow workout plans, track your progress, and connect with trainers',
                      icon: Icons.person,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedRole != null && !isLoading ? _handleRoleSelection : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultSpacing),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultSpacing * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: AppConstants.defaultAnimationDuration,
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: isSelected ? color : AppColors.greyLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultSpacing),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.greyLight,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(width: AppConstants.defaultSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultSpacing / 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRoleSelection() async {
    if (selectedRole == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Update user role
      await authService.updateUserRole(selectedRole!);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
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
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
