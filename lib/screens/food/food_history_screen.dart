import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../../models/food_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/food_card.dart';
import 'edit_food_screen.dart';

class FoodHistoryScreen extends StatelessWidget {
  const FoodHistoryScreen({required this.foods, super.key});

  final FirestoreService foods;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Please sign in again.'));
    return StreamBuilder<List<FoodModel>>(
      stream: foods.watchFoods(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load your diary.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? const <FoodModel>[];
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 52,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Your diary is empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Meals you add will appear here.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          );
        }
        final grouped = <String, List<FoodModel>>{};
        for (final food in items) {
          final key = DateFormat('yyyy-MM-dd').format(food.foodDate);
          grouped.putIfAbsent(key, () => []).add(food);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
          children: [
            const Text(
              'Food diary',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your meals, one day at a time.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dateLabel(DateTime.parse(entry.key)),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value.fold<double>(0, (sum, food) => sum + food.calories).round()} kcal',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              for (final food in entry.value)
                FoodCard(
                  food: food,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EditFoodScreen(food: food, foods: foods),
                    ),
                  ),
                  onDelete: () => _delete(context, uid, food),
                ),
            ],
          ],
        );
      },
    );
  }

  String _dateLabel(DateTime date) {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final itemDay = DateTime(date.year, date.month, date.day);
    if (itemDay == day) return 'Today';
    if (itemDay == day.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(date);
  }

  Future<void> _delete(BuildContext context, String uid, FoodModel food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this food?'),
        content: Text('${food.foodName} will be removed from your diary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await foods.deleteFood(uid, food.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete food: $error')));
    }
  }
}
