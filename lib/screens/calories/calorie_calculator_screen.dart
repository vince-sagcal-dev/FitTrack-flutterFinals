import 'package:material_ui/material_ui.dart';

import '../../services/profile_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/calorie_calculator.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({
    required this.uid,
    required this.profiles,
    super.key,
  });

  final String uid;
  final ProfileService profiles;

  @override
  State<CalorieCalculatorScreen> createState() =>
      _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _bodyFat = TextEditingController();
  BiologicalSex? _sex;
  ActivityLevel? _activityLevel;
  bool _loadingProfile = true;
  bool _savingTarget = false;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    _bodyFat.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await widget.profiles.getProfile(widget.uid);
      if (!mounted) return;
      if (profile != null) {
        _age.text = profile.age?.toString() ?? '';
        _weight.text = _numberText(profile.weightKg);
        _height.text = _numberText(profile.heightCm);
        _bodyFat.text = _numberText(profile.bodyFatPercent);
        _sex = _sexFor(profile.sex);
        _activityLevel = _activityFor(profile.activityLevel);
      }
    } catch (error) {
      if (!mounted) return;
      _profileError = 'Could not load saved details: $error';
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  String _numberText(double? number) => number == null
      ? ''
      : number == number.roundToDouble()
      ? number.toInt().toString()
      : number.toString();

  BiologicalSex? _sexFor(String? key) {
    for (final sex in BiologicalSex.values) {
      if (sex.key == key) return sex;
    }
    return null;
  }

  ActivityLevel? _activityFor(String? key) {
    for (final level in ActivityLevel.values) {
      if (level.key == key) return level;
    }
    return null;
  }

  CalorieTargets? get _targets {
    final age = int.tryParse(_age.text);
    final weightKg = double.tryParse(_weight.text);
    final heightCm = double.tryParse(_height.text);
    final bodyFatPercent = _bodyFat.text.trim().isEmpty
        ? null
        : double.tryParse(_bodyFat.text);
    if (age == null ||
        age < 18 ||
        age > 100 ||
        weightKg == null ||
        !weightKg.isFinite ||
        weightKg < 25 ||
        weightKg > 300 ||
        heightCm == null ||
        !heightCm.isFinite ||
        heightCm < 100 ||
        heightCm > 250 ||
        _sex == null ||
        _activityLevel == null ||
        (_bodyFat.text.trim().isNotEmpty &&
            (bodyFatPercent == null ||
                !bodyFatPercent.isFinite ||
                bodyFatPercent < 3 ||
                bodyFatPercent > 70))) {
      return null;
    }
    return calculateCalorieTargets(
      age: age,
      weightKg: weightKg,
      heightCm: heightCm,
      sex: _sex!,
      activityLevel: _activityLevel!,
      bodyFatPercent: bodyFatPercent,
    );
  }

  Future<void> _setDailyGoal(int target) async {
    if (!_formKey.currentState!.validate()) return;
    final targets = _targets;
    if (targets == null || _sex == null || _activityLevel == null) return;

    setState(() => _savingTarget = true);
    try {
      await widget.profiles.saveCaloriePlan(
        uid: widget.uid,
        dailyCalorieGoal: target,
        age: int.parse(_age.text),
        weightKg: double.parse(_weight.text),
        heightCm: double.parse(_height.text),
        sex: _sex!.key,
        activityLevel: _activityLevel!.key,
        bodyFatPercent: _bodyFat.text.trim().isEmpty
            ? null
            : double.parse(_bodyFat.text),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily goal updated to $target kcal.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save your calorie plan: $error')),
      );
    } finally {
      if (mounted) setState(() => _savingTarget = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final targets = _targets;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        const Text(
          'Calorie goals',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Estimate your daily needs and choose a target for your food diary.',
          style: TextStyle(color: AppColors.muted),
        ),
        if (_profileError != null) ...[
          const SizedBox(height: 12),
          Text(_profileError!, style: const TextStyle(color: AppColors.danger)),
        ],
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      controller: _age,
                      label: 'Age (years)',
                      min: 18,
                      max: 100,
                      decimals: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      controller: _weight,
                      label: 'Weight (kg)',
                      min: 25,
                      max: 300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      controller: _height,
                      label: 'Height (cm)',
                      min: 100,
                      max: 250,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      controller: _bodyFat,
                      label: 'Body fat % (optional)',
                      min: 3,
                      max: 70,
                      optional: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<BiologicalSex>(
                initialValue: _sex,
                decoration: const InputDecoration(labelText: 'Sex'),
                validator: (value) =>
                    value == null ? 'Select male or female.' : null,
                items: BiologicalSex.values
                    .map(
                      (sex) =>
                          DropdownMenuItem(value: sex, child: Text(sex.label)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _sex = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ActivityLevel>(
                initialValue: _activityLevel,
                decoration: const InputDecoration(labelText: 'Activity level'),
                validator: (value) =>
                    value == null ? 'Select your activity level.' : null,
                items: ActivityLevel.values
                    .map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text('${level.label}  (${level.factor}×)'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _activityLevel = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Activity estimates: sedentary (little exercise), light (1–3 days/week), '
          'moderate (3–5), very active (6–7), extra active (hard training or physical work).',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        if (_loadingProfile)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (targets != null) ...[
          const SizedBox(height: 20),
          _RestingEstimate(targets: targets),
          const SizedBox(height: 10),
          _TargetCard(
            title: 'Maintain',
            description: 'Estimated calories to maintain your current weight',
            calories: targets.maintenanceCalories,
            icon: Icons.balance_outlined,
            onSelect: _savingTarget
                ? null
                : () => _setDailyGoal(targets.maintenanceCalories),
          ),
          _TargetCard(
            title: 'Bulk',
            description: 'Maintenance + 250 kcal',
            calories: targets.bulkingCalories,
            icon: Icons.trending_up,
            onSelect: _savingTarget
                ? null
                : () => _setDailyGoal(targets.bulkingCalories),
          ),
          _TargetCard(
            title: 'Cut',
            description: targets.maintenanceCalories <= 1000
                ? 'No lower target suggested for this estimate'
                : 'Maintenance − 500 kcal (minimum 1,000 kcal)',
            calories: targets.cuttingCalories,
            icon: Icons.trending_down,
            onSelect: _savingTarget
                ? null
                : () => _setDailyGoal(targets.cuttingCalories),
          ),
          if (_savingTarget)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Complete the fields above to see your estimated calorie targets.',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        const SizedBox(height: 18),
        const _CalculationNotes(),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required num min,
    required num max,
    bool decimals = true,
    bool optional = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: decimals),
    onChanged: (_) => setState(() {}),
    validator: (value) {
      final text = value?.trim() ?? '';
      if (optional && text.isEmpty) return null;
      final number = decimals ? double.tryParse(text) : int.tryParse(text);
      if (number == null ||
          (number is double && !number.isFinite) ||
          number < min ||
          number > max) {
        return optional
            ? 'Use $min–$max%.'
            : 'Use ${min.toInt()}–${max.toInt()}.';
      }
      return null;
    },
    decoration: InputDecoration(labelText: label),
  );
}

class _RestingEstimate extends StatelessWidget {
  const _RestingEstimate({required this.targets});

  final CalorieTargets targets;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const Icon(Icons.local_fire_department_outlined, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimated resting calories',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '${targets.restingCalories} kcal / day',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.title,
    required this.description,
    required this.calories,
    required this.icon,
    required this.onSelect,
  });

  final String title;
  final String description;
  final int calories;
  final IconData icon;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.muted),
                ),
                Text(
                  '$calories kcal / day',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onSelect, child: const Text('Use goal')),
        ],
      ),
    ),
  );
}

class _CalculationNotes extends StatelessWidget {
  const _CalculationNotes();

  @override
  Widget build(BuildContext context) => const Text(
    'Estimates are for adults 18+ and are not medical advice. Resting calories '
    'use Mifflin–St Jeor; entering body fat switches to a lean-mass estimate. '
    'Maintenance applies an activity multiplier. Bulk/cut targets are simple '
    '+250/−500 kcal starting estimates, with a 1,000 kcal/day lower bound '
    'based on the NIDDK planner; individual needs vary. Reassess with your '
    'health professional.\n\n'
    'References: Mifflin et al., American Journal of Clinical Nutrition (1990), '
    'doi:10.1093/ajcn/51.2.241; NIH/NIDDK Body Weight Planner: '
    'https://www.niddk.nih.gov/bwp',
    style: TextStyle(fontSize: 12, color: AppColors.muted),
  );
}
