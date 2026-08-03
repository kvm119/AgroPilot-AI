import 'package:flutter/material.dart';

class ExpertConsultationScreen extends StatelessWidget {
  const ExpertConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert Consultation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Banner Card
          Card(
            color: theme.colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kisan Call Centre & KVK Help',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Government of India Agricultural Helpline: Toll Free 1800-180-1551',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Agricultural Helplines', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _buildHelplineCard(
            context,
            title: 'Kisan Call Centre (KCC)',
            phone: '1800-180-1551',
            hours: '06:00 AM to 10:00 PM (Daily)',
            subtitle: 'Free phone advice in 22 regional languages.',
            color: Colors.green,
          ),
          _buildHelplineCard(
            context,
            title: 'State Agriculture Dept (Andhra Pradesh)',
            phone: '155251',
            hours: '09:00 AM to 06:00 PM (Mon-Sat)',
            subtitle: 'Rythu Bharosa Kendralu (RBK) helpline.',
            color: Colors.blue,
          ),
          _buildHelplineCard(
            context,
            title: 'ICAR Krishi Vigyan Kendra (Guntur KVK)',
            phone: '0863-2234051',
            hours: '10:00 AM to 05:00 PM',
            subtitle: 'Lam, Guntur Soil Test & Plant Protection Officer.',
            color: Colors.amber,
          ),

          const SizedBox(height: 24),
          Text('Frequently Asked Questions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          const ExpansionTile(
            title: Text('How do I apply for PM-KISAN subsidy?'),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text('Visit your nearest Meeseva/CSC center or pmkisan.gov.in with land record (Pahani/Adangal) and Aadhaar card.'),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('What should I do if my crop leaf develops blast spots?'),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text('Spray Tricyclazole 75 WP at 0.6g/Liter or Isoprothiolane 40 EC at 1.5ml/Liter during early morning hours.'),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('Where can I get soil testing done?'),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text('Contact your local Krishi Vigyan Kendra (KVK) or Village Agriculture Assistant (VAA) at the nearest RBK center.'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineCard(BuildContext context, {required String title, required String phone, required String hours, required String subtitle, required Color color}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.phone_in_talk_rounded, color: color),
        ),
        title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('$subtitle\nHours: $hours', style: theme.textTheme.bodySmall),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            phone,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
