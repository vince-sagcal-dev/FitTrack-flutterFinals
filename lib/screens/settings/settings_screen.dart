import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/aut_service.dart';
import '../../utils/app_colors.dart';
import '../profile/change_password_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../../models/user_model.dart';
import '../../services/profile_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ChangePasswordScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: user == null
                ? null
                : () async {
                    final profiles = ProfileService();
                    try {
                      final profile =
                          await profiles.getProfile(user.uid) ??
                          UserModel(
                            uid: user.uid,
                            fullName: user.displayName ?? '',
                            email: user.email ?? '',
                          );
                      if (!context.mounted) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EditProfileScreen(
                            profile: profile,
                            profiles: profiles,
                          ),
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not load profile: $error'),
                        ),
                      );
                    }
                  },
          ),
          const Divider(height: 30),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About FitTracker'),
            subtitle: Text('Food logging and estimated calorie goals'),
          ),
          const ListTile(
            leading: Icon(Icons.health_and_safety_outlined),
            title: Text('A note on estimates'),
            subtitle: Text(
              'AI-generated nutrition values are estimates and are not medical advice.',
            ),
          ),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.danger),
            ),
            onTap: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You can sign back in any time. Your account and saved data will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await AuthService().logout();
      if (!context.mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not sign out: $error')));
    }
  }
}
