import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/aut_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService().resetPassword(_email.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Could not send reset email.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reset password')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'We’ll email you a secure link to reset your password.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _email,
              label: 'Email address',
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Send reset link',
              onPressed: _sendReset,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    ),
  );
}
