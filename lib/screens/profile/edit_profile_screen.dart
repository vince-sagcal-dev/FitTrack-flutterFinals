import 'package:material_ui/material_ui.dart';

import '../../models/user_model.dart';
import '../../services/profile_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    required this.profile,
    required this.profiles,
    super.key,
  });

  final UserModel profile;
  final ProfileService profiles;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.fullName);
  late final _goal = TextEditingController(
    text: widget.profile.dailyCalorieGoal.toString(),
  );
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _goal.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.profiles.updateProfile(
        UserModel(
          uid: widget.profile.uid,
          fullName: _name.text.trim(),
          email: widget.profile.email,
          dailyCalorieGoal: int.parse(_goal.text),
          photoUrl: widget.profile.photoUrl,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit profile')),
    body: Form(
      key: _key,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomTextField(
            controller: _name,
            label: 'Full name',
            validator: (value) => Validators.required(value, label: 'Name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _goal,
            label: 'Daily calorie goal',
            keyboardType: TextInputType.number,
            validator: (value) {
              final number = int.tryParse(value ?? '');
              if (number == null || number < 500 || number > 10000) {
                return 'Choose a goal between 500 and 10,000 kcal.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Your calorie goal is for general tracking only and is not medical advice.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 22),
          CustomButton(
            label: 'Save profile',
            onPressed: _save,
            isLoading: _saving,
          ),
        ],
      ),
    ),
  );
}
