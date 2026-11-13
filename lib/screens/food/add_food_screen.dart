import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/food_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({
    this.initialFood,
    this.imageBytes,
    this.imageMimeType = 'image/jpeg',
    super.key,
  });

  final FoodModel? initialFood;
  final Uint8List? imageBytes;
  final String imageMimeType;

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialFood?.foodName);
  late final _calories = TextEditingController(
    text: _text(widget.initialFood?.calories),
  );
  late final _protein = TextEditingController(
    text: _text(widget.initialFood?.protein),
  );
  late final _carbs = TextEditingController(
    text: _text(widget.initialFood?.carbohydrates),
  );
  late final _fat = TextEditingController(text: _text(widget.initialFood?.fat));
  late final _serving = TextEditingController(
    text: widget.initialFood?.servingSize ?? '1 serving',
  );
  String _meal = 'Breakfast';
  DateTime _date = DateTime.now();
  bool _saving = false;

  String _text(double? value) => value == null
      ? ''
      : value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  void initState() {
    super.initState();
    _meal = widget.initialFood?.mealType ?? _mealForNow();
    _date = widget.initialFood?.foodDate ?? DateTime.now();
  }

  String _mealForNow() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Breakfast';
    if (hour < 16) return 'Lunch';
    if (hour < 21) return 'Dinner';
    return 'Snack';
  }

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _serving.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in before saving food.')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final food = FoodModel(
        id: '',
        foodName: _name.text.trim(),
        calories: double.parse(_calories.text),
        protein: double.tryParse(_protein.text) ?? 0,
        carbohydrates: double.tryParse(_carbs.text) ?? 0,
        fat: double.tryParse(_fat.text) ?? 0,
        servingSize: _serving.text.trim(),
        mealType: _meal,
        foodDate: _date,
      );
      final id = await FirestoreService().addFood(user.uid, food);
      if (widget.imageBytes != null) {
        try {
          final imageUrl = await StorageService().uploadFoodImage(
            user.uid,
            id,
            widget.imageBytes!,
            mimeType: widget.imageMimeType,
          );
          await FirestoreService().updateFood(
            user.uid,
            food.copyWith(id: id, imageUrl: imageUrl),
          );
        } catch (error) {
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text('Food saved, but photo upload failed: $error'),
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
          return;
        }
      }
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        const SnackBar(content: Text('Food added to your diary.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save food: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add food')),
    body: Form(
      key: _key,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.imageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.memory(
                widget.imageBytes!,
                height: 170,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],
          CustomTextField(
            controller: _name,
            label: 'Food name',
            validator: (value) =>
                Validators.required(value, label: 'Food name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _calories,
            label: 'Calories (kcal)',
            validator: (value) =>
                Validators.positiveNumber(value, label: 'Calories'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _serving,
            label: 'Serving size',
            validator: (value) =>
                Validators.required(value, label: 'Serving size'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _meal,
            decoration: const InputDecoration(labelText: 'Meal'),
            items: AppConstants.mealTypes
                .map((meal) => DropdownMenuItem(value: meal, child: Text(meal)))
                .toList(),
            onChanged: (value) => setState(() => _meal = value ?? _meal),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              'Date: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Macros (optional)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _macroField(_protein, 'Protein (g)')),
              const SizedBox(width: 8),
              Expanded(child: _macroField(_carbs, 'Carbs (g)')),
              const SizedBox(width: 8),
              Expanded(child: _macroField(_fat, 'Fat (g)')),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Save to diary',
            onPressed: _save,
            isLoading: _saving,
          ),
        ],
      ),
    ),
  );

  Widget _macroField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) => value == null || value.isEmpty
            ? null
            : Validators.nonNegativeNumber(value, label: label),
        decoration: InputDecoration(labelText: label),
      );
}
