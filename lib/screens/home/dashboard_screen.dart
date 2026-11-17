import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../../models/food_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/profile_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/calorie_progress.dart';
import '../../widgets/food_card.dart';
import '../food/add_food_screen.dart';
import '../food/food_history_screen.dart';
import '../food/edit_food_screen.dart';
import '../calories/calorie_calculator_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;
  final _foods = FirestoreService();
  final _profiles = ProfileService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            _dashboard(user.uid, user.displayName),
            FoodHistoryScreen(foods: _foods),
            CalorieCalculatorScreen(uid: user.uid, profiles: _profiles),
            ProfileScreen(
              profiles: _profiles,
              onSettings: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Diary',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _dashboard(String uid, String? authName) => StreamBuilder<UserModel?>(
    stream: _profiles.watchProfile(uid),
    builder: (context, profileSnapshot) {
      final profile = profileSnapshot.data;
      final greetingName = profile?.fullName ?? authName ?? 'there';
      final goal = profile?.dailyCalorieGoal ?? AppConstants.defaultCalorieGoal;
      return StreamBuilder<List<FoodModel>>(
        stream: _foods.watchFoodsForDay(uid, DateTime.now()),
        builder: (context, foodSnapshot) {
          final items = foodSnapshot.data ?? const <FoodModel>[];
          final calories = items.fold<double>(
            0,
            (total, food) => total + food.calories,
          );
          final protein = items.fold<double>(
            0,
            (total, f) => total + f.protein,
          );
          final carbs = items.fold<double>(
            0,
            (total, f) => total + f.carbohydrates,
          );
          final fat = items.fold<double>(0, (total, f) => total + f.fat);
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, MMMM d')
                                    .format(DateTime.now()),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hello, ${greetingName.split(' ').first}!',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Add food',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AddFoodScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CalorieProgress(consumed: calories, goal: goal),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _MacroTile(
                            title: 'Protein',
                            grams: protein,
                            color: const Color(0xFFE9EFFB),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MacroTile(
                            title: 'Carbs',
                            grams: carbs,
                            color: const Color(0xFFFFF1E2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MacroTile(
                            title: 'Fat',
                            grams: fat,
                            color: const Color(0xFFF9E9E8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Today’s meals',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _tab = 1),
                          child: const Text('See diary'),
                        ),
                      ],
                    ),
                    if (foodSnapshot.hasError)
                      _ErrorMessage(
                        message: 'Could not load today’s meals.',
                        error: foodSnapshot.error,
                      ),
                    if (foodSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (items.isEmpty)
                      _EmptyMeals(
                        onAdd: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AddFoodScreen(),
                            ),
                          );
                        },
                      )
                    else
                      ...items
                          .take(5)
                          .map(
                            (food) => FoodCard(
                              food: food,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      EditFoodScreen(food: food, foods: _foods),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AddFoodScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Add food manually'),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.title,
    required this.grams,
    required this.color,
  });

  final String title;
  final double grams;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          '${grams.round()} g',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: AppColors.muted)),
      ],
    ),
  );
}

class _EmptyMeals extends StatelessWidget {
  const _EmptyMeals({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        const Icon(Icons.restaurant_menu, size: 36, color: AppColors.primary),
        const SizedBox(height: 8),
        const Text(
          'Nothing logged yet',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Add your first meal to start tracking your intake.',
          style: TextStyle(color: AppColors.muted),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Log a meal'),
        ),
      ],
    ),
  );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, required this.error});
  final String message;
  final Object? error;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      '$message ${error ?? ''}',
      style: const TextStyle(color: AppColors.danger),
    ),
  );
}
