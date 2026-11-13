import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/aut_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _key = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService().changePassword(
        currentPassword: _current.text,
        newPassword: _new.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message =
          error.code == 'wrong-password' || error.code == 'invalid-credential'
          ? 'Your current password is incorrect.'
          : error.message ?? 'Could not change your password.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Change password')),
    body: Form(
      key: _key,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomTextField(
            controller: _current,
            label: 'Current password',
            validator: (value) =>
                Validators.required(value, label: 'Current password'),
            obscureText: true,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _new,
            label: 'New password',
            validator: Validators.password,
            obscureText: true,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _confirm,
            label: 'Confirm new password',
            validator: (value) =>
                value != _new.text ? 'Passwords do not match.' : null,
            obscureText: true,
          ),
          const SizedBox(height: 22),
          CustomButton(
            label: 'Update password',
            onPressed: _change,
            isLoading: _loading,
          ),
        ],
      ),
    ),
  );
}
