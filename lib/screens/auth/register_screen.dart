import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/aut_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService().register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'email-already-in-use' => 'An account already uses this email.',
        'weak-password' => 'Choose a stronger password.',
        'invalid-email' => 'Enter a valid email address.',
        'network-request-failed' => 'Check your internet connection and retry.',
        _ => error.message ?? 'Could not create your account.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Account setup failed: $error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.eco_outlined,
                    color: AppColors.primary,
                    size: 44,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A little more mindful, one meal at a time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    controller: _name,
                    label: 'Full name',
                    validator: (value) =>
                        Validators.required(value, label: 'Name'),
                    prefixIcon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _email,
                    label: 'Email address',
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _password,
                    label: 'Password (8+ characters)',
                    validator: Validators.password,
                    obscureText: _hidePassword,
                    prefixIcon: Icons.lock_outline,
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _confirm,
                    label: 'Confirm password',
                    validator: (value) => value != _password.text
                        ? 'Passwords do not match.'
                        : null,
                    obscureText: _hidePassword,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 22),
                  CustomButton(
                    label: 'Create account',
                    onPressed: _register,
                    isLoading: _loading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
