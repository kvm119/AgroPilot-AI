import 'package:flutter/material.dart';

class DosageRecommendationScreen extends StatefulWidget {
  const DosageRecommendationScreen({super.key});

  @override
  State<DosageRecommendationScreen> createState() => _DosageRecommendationScreenState();
}

class _DosageRecommendationScreenState extends State<DosageRecommendationScreen> {
  String _selectedCrop = 'Rice (BPT 5204)';
  String _growthStage = 'Vegetative Stage (30-45 Days)';
  double _farmAreaAcres = 2.5;

  final List<String> _crops = ['Rice (BPT 5204)', 'Tomato (Hybrid)', 'Cotton', 'Chilli (Teja)', 'Maize'];
  final List<String> _stages = [
    'Nursery / Seedling (0-15 Days)',
    'Vegetative Stage (30-45 Days)',
    'Flowering & Panicle (45-60 Days)',
    'Grain Filling / Maturity (60-90 Days)'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final npkDosageKg = (_farmAreaAcres * 50).toStringAsFixed(1);
    final ureaDosageKg = (_farmAreaAcres * 35).toStringAsFixed(1);
    final zincSulfateKg = (_farmAreaAcres * 10).toStringAsFixed(1);
    final fungicideML = (_farmAreaAcres * 250).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosage Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agri Dosage Recommendation',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Calculate precise fertilizer, pesticide, fungicide, and micronutrient dosages.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 24),

            // Inputs Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCrop,
                      decoration: const InputDecoration(labelText: 'Select Crop'),
                      items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCrop = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _growthStage,
                      decoration: const InputDecoration(labelText: 'Growth Stage'),
                      items: _stages.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _growthStage = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Farm Area: ${_farmAreaAcres.toStringAsFixed(1)} Acres', style: theme.textTheme.titleSmall),
                    Slider(
                      value: _farmAreaAcres,
                      min: 0.5,
                      max: 20.0,
                      divisions: 39,
                      label: '$_farmAreaAcres Acres',
                      onChanged: (val) => setState(() => _farmAreaAcres = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('Calculated Input Dosages', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _buildDosageCard(
              context,
              title: 'Fertilizer (NPK 19:19:19)',
              dosage: '$npkDosageKg kg',
              instructions: 'Apply broadcast evenly during soil moist conditions in morning hours.',
              icon: Icons.grass_rounded,
              color: Colors.green,
            ),
            _buildDosageCard(
              context,
              title: 'Nitrogen Supplement (Urea)',
              dosage: '$ureaDosageKg kg',
              instructions: 'Top dressing application. Ensure 2cm soil moisture.',
              icon: Icons.science_rounded,
              color: Colors.blue,
            ),
            _buildDosageCard(
              context,
              title: 'Micronutrient (Zinc Sulfate 21%)',
              dosage: '$zincSulfateKg kg',
              instructions: 'Corrects basal zinc deficiency. Mix with farmyard manure.',
              icon: Icons.eco_rounded,
              color: Colors.amber,
            ),
            _buildDosageCard(
              context,
              title: 'Prophylactic Fungicide (Tricyclazole 75 WP)',
              dosage: '$fungicideML grams / ${(_farmAreaAcres * 200).toStringAsFixed(0)}L Water',
              instructions: 'Foliar spray for blast protection during high humidity.',
              icon: Icons.sanitizer_rounded,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDosageCard(BuildContext context, {required String title, required String dosage, required String instructions, required IconData icon, required Color color}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(instructions, style: theme.textTheme.bodySmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            dosage,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
