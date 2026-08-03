import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/farm_setup_provider.dart';

class FarmSetup2 extends ConsumerStatefulWidget {
  const FarmSetup2({super.key});

  @override
  ConsumerState<FarmSetup2> createState() => _FarmSetup2State();
}

class _FarmSetup2State extends ConsumerState<FarmSetup2> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customCropController = TextEditingController();
  String _searchQuery = '';
  bool _isCustomSelected = false;

  final List<Map<String, String>> _allCrops = const [
    {'id': 'rice', 'name': 'Rice / Paddy (धान)', 'icon': '🌾'},
    {'id': 'cotton', 'name': 'Cotton (कपास / పత్తి)', 'icon': '☁️'},
    {'id': 'maize', 'name': 'Maize / Corn (मक्का / జొన్న)', 'icon': '🌽'},
    {'id': 'tomato', 'name': 'Tomato (टमाटर / టమాటా)', 'icon': '🍅'},
    {'id': 'onion', 'name': 'Onion (प्याज / ఉల్లిపాయ)', 'icon': '🧅'},
    {'id': 'banana', 'name': 'Banana (केला / అరటి)', 'icon': '🍌'},
    {'id': 'groundnut', 'name': 'Groundnut / Peanut (मूंगफली / వేరుశెనగ)', 'icon': '🥜'},
    {'id': 'millets', 'name': 'Millets / Ragi / Bajra (बाजरा / మిల్లెట్స్)', 'icon': '🌾'},
    {'id': 'sugarcane', 'name': 'Sugarcane (गन्ना / చెరకు)', 'icon': '🎋'},
    {'id': 'wheat', 'name': 'Wheat (गेहूं / గోధుమ)', 'icon': '🌾'},
    {'id': 'chilli', 'name': 'Chilli (मिर्च / మిరప)', 'icon': '🌶️'},
    {'id': 'turmeric', 'name': 'Turmeric (हल्दी / పసుపు)', 'icon': '🟨'},
    {'id': 'mango', 'name': 'Mango (आम / మామిడి)', 'icon': '🥭'},
    {'id': 'papaya', 'name': 'Papaya (पपीता / బొప్పాయి)', 'icon': '🥭'},
    {'id': 'coconut', 'name': 'Coconut (नारियल / కొబ్బరి)', 'icon': '🥥'},
    {'id': 'coffee', 'name': 'Coffee (कॉफी / కాఫీ)', 'icon': '☕'},
    {'id': 'tea', 'name': 'Tea (चाय / టీ)', 'icon': '🍃'},
    {'id': 'rubber', 'name': 'Rubber (रबर)', 'icon': '🌳'},
    {'id': 'pulses', 'name': 'Pulses / Dal (दालें / పప్పులు)', 'icon': '🫘'},
    {'id': 'oilseeds', 'name': 'Oil Seeds / Mustard / Soy (तिलहन / నూనెగింజలు)', 'icon': '🌻'},
    {'id': 'vegetables', 'name': 'Mixed Vegetables (सब्जियां / కూరగాయలు)', 'icon': '🥦'},
    {'id': 'fruits', 'name': 'Mixed Fruits (फल / పండ్లు)', 'icon': '🍎'},
    {'id': 'other', 'name': 'Other (Custom Crop)', 'icon': '🌱'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _customCropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCrop = ref.watch(farmSetupProvider).crop;

    final filteredCrops = _allCrops.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What crops are you growing?',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your primary crop from over 22 Indian agricultural varieties.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search Rice, Chilli, Tomato, Cotton, Mango...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.separated(
                  itemCount: filteredCrops.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final crop = filteredCrops[index];
                    final isSelected = selectedCrop == crop['name'] || (crop['id'] == 'other' && _isCustomSelected);

                    return InkWell(
                      onTap: () {
                        if (crop['id'] == 'other') {
                          setState(() {
                            _isCustomSelected = true;
                          });
                        } else {
                          setState(() {
                            _isCustomSelected = false;
                          });
                          ref.read(farmSetupProvider.notifier).setCrop(crop['name']!);
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(crop['icon']!, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    crop['name']!,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? theme.colorScheme.primary : null,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
                              ],
                            ),
                            if (crop['id'] == 'other' && _isCustomSelected) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _customCropController,
                                onChanged: (val) {
                                  if (val.trim().isNotEmpty) {
                                    ref.read(farmSetupProvider.notifier).setCrop(val.trim());
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Type your custom crop name...',
                                  filled: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedCrop.isNotEmpty ? () => context.push('/setup/3') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
