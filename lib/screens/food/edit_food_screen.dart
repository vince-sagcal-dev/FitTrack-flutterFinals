import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/food_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditFoodScreen extends StatefulWidget {
  const EditFoodScreen({required this.food, required this.foods, super.key});

  final FoodModel food;
  final FirestoreService foods;

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.food.foodName);
  late final _calories = TextEditingController(
    text: widget.food.calories.toString(),
  );
  late final _serving = TextEditingController(text: widget.food.servingSize);
  late final _protein = TextEditingController(
    text: widget.food.protein.toString(),
  );
  late final _carbs = TextEditingController(
    text: widget.food.carbohydrates.toString(),
  );
  late final _fat = TextEditingController(text: widget.food.fat.toString());
  late String _meal = widget.food.mealType;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _serving.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await widget.foods.updateFood(
        uid,
        widget.food.copyWith(
          foodName: _name.text.trim(),
          calories: double.parse(_calories.text),
          servingSize: _serving.text.trim(),
          protein: double.tryParse(_protein.text) ?? 0,
          carbohydrates: double.tryParse(_carbs.text) ?? 0,
          fat: double.tryParse(_fat.text) ?? 0,
          mealType: _meal,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update food: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit food')),
    body: Form(
      key: _key,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomTextField(
            controller: _name,
            label: 'Food name',
            validator: (value) =>
                Validators.required(value, label: 'Food name'),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _calories,
            label: 'Calories (kcal)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) =>
                Validators.positiveNumber(value, label: 'Calories'),
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
          Row(
            children: [
              Expanded(child: _macro(_protein, 'Protein g')),
              const SizedBox(width: 8),
              Expanded(child: _macro(_carbs, 'Carbs g')),
              const SizedBox(width: 8),
              Expanded(child: _macro(_fat, 'Fat g')),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Save changes',
            onPressed: _save,
            isLoading: _saving,
          ),
        ],
      ),
    ),
  );

  Widget _macro(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) => value == null || value.isEmpty
            ? null
            : Validators.nonNegativeNumber(value, label: label),
        decoration: InputDecoration(labelText: label),
      );
}
