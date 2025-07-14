import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      currentUser = authService.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(),
                  
                  // Profile Information
                  _buildProfileInformation(),
                  
                  // Settings Section
                  _buildSettingsSection(themeProvider),
                  
                  // Actions Section
                  _buildActionsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.white.withOpacity(0.2),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.white,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          
          // User Name
          Text(
            currentUser?.displayName ?? 'User',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // User Email
          Text(
            currentUser?.email ?? 'user@example.com',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          
          // User Role Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.defaultSpacing / 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Text(
              currentUser?.role.toString().split('.').last.toUpperCase() ?? 'USER',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInformation() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          
          _buildInfoRow(
            icon: Icons.person,
            label: 'Full Name',
            value: currentUser?.displayName ?? 'Not set',
          ),
          
          _buildInfoRow(
            icon: Icons.email,
            label: 'Email',
            value: currentUser?.email ?? 'Not set',
          ),
          
          _buildInfoRow(
            icon: Icons.phone,
            label: 'Phone',
            value: currentUser?.phoneNumber ?? 'Not set',
          ),
          
          _buildInfoRow(
            icon: Icons.cake,
            label: 'Date of Birth',
            value: currentUser?.dateOfBirth != null
                ? '${currentUser!.dateOfBirth!.day}/${currentUser!.dateOfBirth!.month}/${currentUser!.dateOfBirth!.year}'
                : 'Not set',
          ),
          
          _buildInfoRow(
            icon: Icons.fitness_center,
            label: 'Role',
            value: currentUser?.role.toString().split('.').last.toUpperCase() ?? 'Not set',
          ),
          
          const SizedBox(height: AppConstants.defaultSpacing),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _editProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppConstants.defaultSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          
          // Dark Mode Toggle
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark theme',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              activeColor: AppColors.primary,
            ),
          ),
          
          // Notifications
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to notifications settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications settings coming soon!')),
              );
            },
          ),
          
          // Privacy
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy',
            subtitle: 'Control your privacy settings',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to privacy settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings coming soon!')),
              );
            },
          ),
          
          // About
          _buildSettingsTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionsSection() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Help & Support
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Navigate to help & support
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon!')),
                );
              },
              icon: const Icon(Icons.help_outline),
              label: const Text('Help & Support'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultSpacing,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultSpacing,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile coming soon!')),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Gym Tracker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version: ${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              Text(
                'Gym Tracker is your personal fitness companion. Track your workouts, monitor your progress, and stay motivated on your fitness journey.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppConstants.defaultSpacing),
              Text(
                'Built with Flutter and ❤️',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signOut();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
