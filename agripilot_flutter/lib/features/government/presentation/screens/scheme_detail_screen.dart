import 'package:flutter/material.dart';
import 'government_schemes_screen.dart';

class SchemeDetailScreen extends StatefulWidget {
  final SchemeModel scheme;

  const SchemeDetailScreen({super.key, required this.scheme});

  @override
  State<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.scheme.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = widget.scheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(scheme.title),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: _isBookmarked ? Colors.amber : null),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sharing link: ${scheme.officialUrl}')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Header Card
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          scheme.eligibilityStatus,
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const Spacer(),
                      Text('Deadline: ${scheme.deadline}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(scheme.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(scheme.department, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(height: 16),
                  Text(
                    'Financial Benefit: ${scheme.maxBenefit}',
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Scheme Objective & Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(scheme.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),

          Text('Required Documents for Application', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Column(
            children: scheme.requiredDocs.map((doc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(doc, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Text('Application Process', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('1. Collect land adangal/1B and Aadhaar card copies.\n2. Visit your nearest Village Agriculture Assistant (VAA) or CSC Center.\n3. Submit e-KYC biometric verification.\n4. Monitor status on official portal.'),
          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.open_in_new),
            label: Text('Visit Official Portal (${scheme.officialUrl})', style: const TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
          ),
        ],
      ),
    );
  }
}
