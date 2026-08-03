import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scheme_detail_screen.dart';

class SchemeModel {
  final String id;
  final String title;
  final String category; // Central, State, Subsidy, Loan, Insurance, Equipment, Training
  final String department;
  final String state;
  final String eligibilityStatus; // Eligible, Possibly Eligible, Not Eligible
  final String maxBenefit;
  final String deadline;
  final String description;
  final List<String> requiredDocs;
  final String officialUrl;
  final bool isBookmarked;

  const SchemeModel({
    required this.id,
    required this.title,
    required this.category,
    required this.department,
    required this.state,
    required this.eligibilityStatus,
    required this.maxBenefit,
    required this.deadline,
    required this.description,
    required this.requiredDocs,
    required this.officialUrl,
    this.isBookmarked = false,
  });

  SchemeModel copyWith({bool? isBookmarked}) {
    return SchemeModel(
      id: id,
      title: title,
      category: category,
      department: department,
      state: state,
      eligibilityStatus: eligibilityStatus,
      maxBenefit: maxBenefit,
      deadline: deadline,
      description: description,
      requiredDocs: requiredDocs,
      officialUrl: officialUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class GovernmentSchemesScreen extends ConsumerStatefulWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  ConsumerState<GovernmentSchemesScreen> createState() => _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState extends ConsumerState<GovernmentSchemesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedEligibility = 'All';

  final List<SchemeModel> _schemes = [
    const SchemeModel(
      id: 'pm_kisan',
      title: 'PM-KISAN Samman Nidhi',
      category: 'Central',
      department: 'Ministry of Agriculture & Farmers Welfare',
      state: 'All India',
      eligibilityStatus: 'Eligible',
      maxBenefit: '₹6,000 / Year (3 Installments)',
      deadline: '31 Aug 2026',
      description: 'Direct income support of ₹6,000 per year for all landholding farmer families across India.',
      requiredDocs: ['Aadhaar Card', 'Land Holding Record (Pahani/Adangal)', 'Active Bank Account Details'],
      officialUrl: 'https://pmkisan.gov.in',
    ),
    const SchemeModel(
      id: 'pmfby',
      title: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
      category: 'Insurance',
      department: 'Dept of Agriculture, Cooperation & Farmers Welfare',
      state: 'All India',
      eligibilityStatus: 'Eligible',
      maxBenefit: '100% Crop Loss Claim Coverage',
      deadline: '15 Aug 2026',
      description: 'Comprehensive crop insurance against drought, flood, pests, and unseasonal rainfall for Kharif & Rabi seasons.',
      requiredDocs: ['Land Sowing Certificate', 'Aadhaar Card', 'Bank Passbook', 'Crop Photo'],
      officialUrl: 'https://pmfby.gov.in',
    ),
    const SchemeModel(
      id: 'rythu_bharosa',
      title: 'YSR Rythu Bharosa - PM KISAN',
      category: 'State',
      department: 'Dept of Agriculture, Andhra Pradesh',
      state: 'Andhra Pradesh',
      eligibilityStatus: 'Eligible',
      maxBenefit: '₹13,500 / Year',
      deadline: '15 Oct 2026',
      description: 'Financial assistance to farmer families including tenant farmers in Andhra Pradesh for input costs.',
      requiredDocs: ['Rice Card / Ration Card', 'Aadhaar', '1B Land Document', 'Tenant Agreement (CCRC)'],
      officialUrl: 'https://rythubharosa.ap.gov.in',
    ),
    const SchemeModel(
      id: 'smam_drip',
      title: 'Micro Irrigation Subsidy (Drip & Sprinkler)',
      category: 'Subsidy',
      department: 'AP Horticulture Department',
      state: 'Andhra Pradesh',
      eligibilityStatus: 'Possibly Eligible',
      maxBenefit: '90% Subsidy for SF/MF',
      deadline: '30 Nov 2026',
      description: '90% subsidy for small & marginal farmers on installation of Drip and Sprinkler irrigation systems.',
      requiredDocs: ['Water Source Certificate', 'Soil & Water Test Report', 'Land Adangal', 'Aadhaar'],
      officialUrl: 'https://horticulture.ap.gov.in',
    ),
    const SchemeModel(
      id: 'kcc_loan',
      title: 'Kisan Credit Card (KCC) Subsidized Crop Loan',
      category: 'Loan',
      department: 'Reserve Bank of India & NABARD',
      state: 'All India',
      eligibilityStatus: 'Eligible',
      maxBenefit: 'Up to ₹3,00,000 @ 4% Interest',
      deadline: 'Open All Year',
      description: 'Concessional crop loan at 4% effective interest rate (with 3% prompt repayment incentive).',
      requiredDocs: ['Land Record Copy', 'Identity Proof', 'No Dues Certificate from Local Banks'],
      officialUrl: 'https://nabard.org',
    ),
  ];

  final List<String> _categories = ['All', 'Central', 'State', 'Subsidy', 'Loan', 'Insurance'];
  final List<String> _eligibilityFilters = ['All', 'Eligible', 'Possibly Eligible'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filtered = _schemes.where((s) {
      if (_selectedCategory != 'All' && s.category != _selectedCategory) return false;
      if (_selectedEligibility != 'All' && s.eligibilityStatus != _selectedEligibility) return false;
      if (_searchController.text.isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        return s.title.toLowerCase().contains(q) || s.description.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Government Schemes'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search & Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search schemes (PM-KISAN, Drip Subsidy, Fasal Bima)...',
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
              children: [
                ..._categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                ..._eligibilityFilters.map((eFilter) {
                  final isSelected = _selectedEligibility == eFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(eFilter),
                      onSelected: (_) => setState(() => _selectedEligibility = eFilter),
                      selectedColor: Colors.green.withValues(alpha: 0.2),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No government schemes match your criteria.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isEligible = item.eligibilityStatus == 'Eligible';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SchemeDetailScreen(scheme: item),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (isEligible ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.eligibilityStatus,
                                        style: TextStyle(
                                          color: isEligible ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      item.category,
                                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(item.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(item.department, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Max Benefit:'),
                                      Text(item.maxBenefit, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
}
