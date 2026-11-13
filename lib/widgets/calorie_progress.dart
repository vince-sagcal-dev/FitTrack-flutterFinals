import 'package:material_ui/material_ui.dart';

import '../utils/app_colors.dart';

class CalorieProgress extends StatelessWidget {
  const CalorieProgress({
    required this.consumed,
    required this.goal,
    super.key,
  });

  final double consumed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final progress = goal <= 0 ? 0.0 : (consumed / goal).clamp(0.0, 1.0);
    final remaining = (goal - consumed).round().clamp(0, goal);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TODAY\'S CALORIES',
            style: TextStyle(color: Colors.white70, letterSpacing: 1.1),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                consumed.round().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  'kcal eaten',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const Spacer(),
              Text('$goal goal', style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            remaining == 0
                ? 'Daily goal reached — great work!'
                : '$remaining kcal remaining',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
