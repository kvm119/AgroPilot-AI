import 'package:flutter/material.dart';

class FarmLogEntry {
  final String id;
  final String category; // Irrigation, Fertilizer, Spraying, Harvest, Expenses
  final String title;
  final String details;
  final double amountCost;
  final DateTime date;

  const FarmLogEntry({
    required this.id,
    required this.category,
    required this.title,
    required this.details,
    required this.amountCost,
    required this.date,
  });
}

class FarmActivityLogsScreen extends StatefulWidget {
  const FarmActivityLogsScreen({super.key});

  @override
  State<FarmActivityLogsScreen> createState() => _FarmActivityLogsScreenState();
}

class _FarmActivityLogsScreenState extends State<FarmActivityLogsScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<FarmLogEntry> _logs = [
    FarmLogEntry(id: '1', category: 'Irrigation', title: 'Borewell Canal Irrigation', details: '4 hours watering for Paddy Field 1', amountCost: 350.0, date: DateTime.now().subtract(const Duration(hours: 12))),
    FarmLogEntry(id: '2', category: 'Fertilizer', title: 'NPK 19:19:19 Application', details: 'Applied 50kg bag per acre', amountCost: 1450.0, date: DateTime.now().subtract(const Duration(days: 2))),
    FarmLogEntry(id: '3', category: 'Spraying', title: 'Tricyclazole Prophylactic Spray', details: 'Blast disease prevention spray', amountCost: 850.0, date: DateTime.now().subtract(const Duration(days: 4))),
    FarmLogEntry(id: '4', category: 'Expenses', title: 'Tractor Field Plowing Fuel', details: '20 Liters Diesel for land preparation', amountCost: 1900.0, date: DateTime.now().subtract(const Duration(days: 7))),
    FarmLogEntry(id: '5', category: 'Harvest', title: 'First Batch Paddy Cutting', details: 'Yield 28 Bags collected', amountCost: 0.0, date: DateTime.now().subtract(const Duration(days: 12))),
  ];

  final List<String> _categories = ['All', 'Irrigation', 'Fertilizer', 'Spraying', 'Harvest', 'Expenses'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addLogDialog() {
    final titleCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String category = 'Irrigation';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Activity Log'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => category = val ?? category,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title / Activity')),
              TextField(controller: detailsCtrl, decoration: const InputDecoration(labelText: 'Details')),
              TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost (₹)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                setState(() {
                  _logs.insert(
                    0,
                    FarmLogEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      category: category,
                      title: titleCtrl.text,
                      details: detailsCtrl.text,
                      amountCost: double.tryParse(costCtrl.text) ?? 0.0,
                      date: DateTime.now(),
                    ),
                  );
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save Log'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filtered = _logs.where((l) {
      if (_selectedCategory != 'All' && l.category != _selectedCategory) return false;
      if (_searchController.text.isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        return l.title.toLowerCase().contains(q) || l.details.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Activity Logs'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLogDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Log'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search logs (e.g. Irrigation, Spraying, NPK)...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Logs List
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No activity logs found.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(_getCategoryIcon(item.category), color: theme.colorScheme.primary),
                          ),
                          title: Text(item.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.details}\n${_formatDate(item.date)}', style: theme.textTheme.bodySmall),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.amountCost > 0)
                                Text('₹${item.amountCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _logs.removeWhere((l) => l.id == item.id);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Irrigation':
        return Icons.water_drop_rounded;
      case 'Fertilizer':
        return Icons.grass_rounded;
      case 'Spraying':
        return Icons.sanitizer_rounded;
      case 'Harvest':
        return Icons.agriculture_rounded;
      case 'Expenses':
      default:
        return Icons.monetization_on_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
