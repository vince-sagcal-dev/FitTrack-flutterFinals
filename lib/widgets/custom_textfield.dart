import 'package:material_ui/material_ui.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    obscureText: obscureText,
    maxLines: obscureText ? 1 : maxLines,
    textCapitalization: textCapitalization,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      suffixIcon: suffix,
    ),
  );
}
