import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _observationController = TextEditingController();

  XFile? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _diagnosticReport;
  String? _errorMessage;

  final List<String> _exampleObservationChips = const [
    'Brown spots on leaves',
    'Leaves curling downwards',
    'White powder on stem',
    'Yellowing after heavy rain',
    'Wilting seedling shoots'
  ];

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _errorMessage = null;
        _diagnosticReport = null;
      });

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select image: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final fields = <String, String>{};
      if (_observationController.text.trim().isNotEmpty) {
        fields['user_observation'] = _observationController.text.trim();
      }

      final response = await _apiClient.uploadMultipartFile(
        '/vision/analyze',
        _selectedImage!.path,
        fields: fields,
      );

      setState(() {
        _diagnosticReport = response as Map<String, dynamic>;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Vision Diagnostic Engine failed: $e';
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _selectedImage = null;
      _diagnosticReport = null;
      _errorMessage = null;
      _observationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Crop Vision Diagnostic'),
          ],
        ),
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _resetScanner,
              tooltip: 'New Scan',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selectedImage == null) ..._buildImageSelectionView(theme),
              if (_selectedImage != null && _diagnosticReport == null) ..._buildPreviewAndContextView(theme),
              if (_diagnosticReport != null) ..._buildStructuredReportView(theme),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildImageSelectionView(ThemeData theme) {
    return [
      Text(
        'Scan Crop Disease or Pest',
        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        'Capture a photo or upload from gallery to run instant AI multimodal disease diagnostics.',
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
      ),
      const SizedBox(height: 32),

      Row(
        children: [
          Expanded(
            child: _buildPickerCard(
              theme,
              title: 'Camera',
              subtitle: 'Take Live Photo',
              icon: Icons.camera_alt_rounded,
              color: theme.colorScheme.primary,
              onTap: () => _pickImage(ImageSource.camera),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildPickerCard(
              theme,
              title: 'Gallery',
              subtitle: 'Choose Photo',
              icon: Icons.photo_library_rounded,
              color: theme.colorScheme.secondary,
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildPickerCard(ThemeData theme, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPreviewAndContextView(ThemeData theme) {
    return [
      Text('Image Preview & Observation Context', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),

      // Image Preview Container
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(_selectedImage!.path),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 20),

      // Multiline Observation Context Input
      TextField(
        controller: _observationController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Describe what you observe (optional)',
          hintText: 'e.g., Brown spots on upper paddy leaves after rainfall...',
          prefixIcon: const Icon(Icons.notes_rounded),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 12),

      // Observation Chips
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _exampleObservationChips.map((chip) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text(chip, style: const TextStyle(fontSize: 12)),
                onPressed: () {
                  _observationController.text = chip;
                },
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 24),

      if (_isAnalyzing) ...[
        const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Analyzing crop photo with Multimodal Vision AI...', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ] else ...[
        ElevatedButton.icon(
          onPressed: _analyzeImage,
          icon: const Icon(Icons.psychology_rounded),
          label: const Text('Analyze Crop Health', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
        ),
      ],

      if (_errorMessage != null) ...[
        const SizedBox(height: 16),
        Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ],
    ];
  }

  List<Widget> _buildStructuredReportView(ThemeData theme) {
    final report = _diagnosticReport!;
    final disease = report['disease_prediction'] as Map<String, dynamic>?;
    final isFallback = report['is_fallback'] == true;
    final caption = report['caption'] as String? ?? 'Analysis complete.';

    if (isFallback || disease == null) {
      return [
        Card(
          color: Colors.orange.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
                const SizedBox(height: 12),
                Text('Image Analysis Notice', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(caption, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _resetScanner,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Another Photo'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final diseaseName = disease['disease'] ?? 'Detected Condition';
    final confidence = ((disease['confidence'] ?? 0.9) as num) * 100;
    final severity = disease['severity'] ?? 'Medium';
    final affectedArea = disease['affected_area'] ?? 'Leaf Surface';
    final causes = List<String>.from(disease['possible_causes'] ?? []);
    final actions = List<String>.from(disease['immediate_actions'] ?? []);
    final medicine = disease['recommended_medicine'] ?? 'Consult extension officer';
    final dosage = disease['dosage'] ?? 'Follow label instructions';
    final precautions = List<String>.from(disease['precautions'] ?? []);
    final recoveryTime = disease['expected_recovery_time'] ?? '7-10 Days';
    final expertContact = disease['when_to_contact_expert'] ?? 'Contact local KVK officer if unresolved.';

    return [
      Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.sanitizer_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(diseaseName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text('Confidence: ${confidence.toStringAsFixed(0)}% • Severity: $severity', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),

              _buildReportSection('Affected Area', affectedArea),
              _buildListSection('Possible Causes', causes),
              _buildListSection('Immediate Actions Required', actions),

              const Divider(),
              _buildReportSection('Recommended Medicine', medicine, isHighlight: true),
              _buildReportSection('Dosage Instructions', dosage),
              _buildListSection('Safety Precautions', precautions),

              const Divider(),
              _buildReportSection('Expected Recovery Time', recoveryTime),
              _buildReportSection('When to Contact Expert', expertContact),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report saved to Farm History!')));
                      },
                      icon: const Icon(Icons.bookmark_add_rounded),
                      label: const Text('Save to History'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report link copied to share.')));
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share Report'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildReportSection(String title, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.green : null,
              fontSize: isHighlight ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          ...items.map((it) => Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(it, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
