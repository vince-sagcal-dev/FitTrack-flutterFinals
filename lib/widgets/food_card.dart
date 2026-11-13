import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../models/food_model.dart';
import '../utils/app_colors.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({required this.food, this.onTap, this.onDelete, super.key});

  final FoodModel food;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    ),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryLight,
        child: food.imageUrl == null
            ? const Icon(Icons.restaurant, color: AppColors.primary)
            : ClipOval(
                child: Image.network(
                  food.imageUrl!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.restaurant, color: AppColors.primary),
                ),
              ),
      ),
      title: Text(
        food.foodName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${food.mealType} · ${food.servingSize} · ${DateFormat('h:mm a').format(food.foodDate)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${food.calories.round()} kcal',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete food',
              onPressed: onDelete,
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
    ),
  );
}
