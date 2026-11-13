import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/user_model.dart';
import '../../services/profile_service.dart';
import '../../utils/app_colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.profiles,
    required this.onSettings,
    super.key,
  });

  final ProfileService profiles;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Please sign in again.'));
    return StreamBuilder<UserModel?>(
      stream: profiles.watchProfile(user.uid),
      builder: (context, snapshot) {
        final profile =
            snapshot.data ??
            UserModel(
              uid: user.uid,
              fullName: user.displayName ?? '',
              email: user.email ?? '',
            );
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Your profile',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    foregroundImage: profile.photoUrl == null
                        ? null
                        : NetworkImage(profile.photoUrl!),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.fullName.isEmpty ? 'Welcome' : profile.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ProfileTile(
              icon: Icons.edit_outlined,
              title: 'Edit profile',
              subtitle: 'Name and daily calorie goal',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      EditProfileScreen(profile: profile, profiles: profiles),
                ),
              ),
            ),
            _ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Password and account options',
              onTap: onSettings,
            ),
            if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  'Could not load profile: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
