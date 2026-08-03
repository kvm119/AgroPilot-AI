import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _languageKey = 'user_preferred_language';

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale>((ref) {
  return AppLocaleNotifier();
});

class AppLocaleNotifier extends StateNotifier<Locale> {
  AppLocaleNotifier() : super(const Locale('en')) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedCode = await _storage.read(key: _languageKey);
    if (savedCode != null && savedCode.isNotEmpty) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLanguage(String languageCode) async {
    state = Locale(languageCode);
    await _storage.write(key: _languageKey, value: languageCode);
  }
}

class AppStrings {
  final String languageCode;

  AppStrings(this.languageCode);

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'AgriPilot AI',
      'welcome': 'Welcome to AgriPilot',
      'home': 'Home',
      'scan': 'Scan',
      'market': 'Market',
      'profile': 'Profile',
      'weather_title': 'Weather Forecast',
      'recommendations_title': 'Agronomic Recommendations',
      'copilot_title': 'AI Copilot Assistant',
      'dosages': 'Dosage Calculator',
      'activity_logs': 'Farm Activity Logs',
      'expert_consult': 'Expert Consultation',
      'gov_schemes': 'Government Schemes',
      'sign_out': 'Sign Out',
      'preferred_language': 'Preferred Language',
      'scan_crop': 'Scan Crop',
      'dosage': 'Dosage',
      'logs': 'Logs',
      'expert': 'Expert',
      'view_all': 'View All',
      'change_location': 'Change Location',
      'set_farm_location': 'Set Farm Location',
      'search_placeholder': 'Search crops, mandis, or schemes...',
      'retry': 'Retry',
      'complete_setup': 'Complete Setup',
      'setup_success': 'Farm Setup Complete! Welcome to AgriPilot AI.',
      'non_agri_warning': 'This image does not appear to contain an agricultural object.',
      'low_conf_warning': 'Unable to determine crop confidently.',
    },
    'hi': {
      'app_title': 'एग्रीपायलट एआई',
      'welcome': 'एग्रीपायलट में आपका स्वागत है',
      'home': 'होम',
      'scan': 'स्कैन',
      'market': 'मंडी भाव',
      'profile': 'प्रोफाइल',
      'weather_title': 'मौसम पूर्वानुमान',
      'recommendations_title': 'कृषि सलाह',
      'copilot_title': 'एआई कोपायलट सहायक',
      'dosages': 'खुराक कैलकुलेटर',
      'activity_logs': 'फार्म गतिविधि लॉग',
      'expert_consult': 'विशेषज्ञ परामर्श',
      'gov_schemes': 'सरकारी योजनाएं',
      'sign_out': 'साइन आउट',
      'preferred_language': 'पसंदीदा भाषा',
      'scan_crop': 'फसल स्कैन करें',
      'dosage': 'खुराक',
      'logs': 'गतिविधि लॉग',
      'expert': 'विशेषज्ञ सलाह',
      'view_all': 'सभी देखें',
      'change_location': 'स्थान बदलें',
      'set_farm_location': 'फार्म स्थान सेट करें',
      'search_placeholder': 'फसल, मंडी या योजना खोजें...',
      'retry': 'पुनः प्रयास करें',
      'complete_setup': 'सेटअप पूरा करें',
      'setup_success': 'फार्म सेटअप पूरा हुआ! एग्रीपायलट में स्वागत है।',
      'non_agri_warning': 'इस छवि में कोई कृषि वस्तु दिखाई नहीं दे रही है।',
      'low_conf_warning': 'फसल का आत्मविश्वास से निर्धारण करने में असमर्थ।',
    },
    'te': {
      'app_title': 'అగ్రిపైలట్ AI',
      'welcome': 'అగ్రిపైలట్‌కు స్వాగతం',
      'home': 'హోమ్',
      'scan': 'స్కాన్',
      'market': 'మార్కెట్ ధరలు',
      'profile': 'ప్రొఫైల్',
      'weather_title': 'వాతావరణ నివేదిక',
      'recommendations_title': 'వ్యవసాయ సిఫార్సులు',
      'copilot_title': 'AI కోపైలట్ సహాయకుడు',
      'dosages': 'మందుల మోతాదు లెక్కింపు',
      'activity_logs': 'ఫారం యాక్టివిటీ లాగ్‌లు',
      'expert_consult': 'నిపుణుల సంప్రదింపులు',
      'gov_schemes': 'ప్రభుత్వ పథకాలు',
      'sign_out': 'సైన్ అవుట్',
      'preferred_language': 'ఎంచుకున్న భాష',
      'scan_crop': 'పంట స్కాన్ చేయండి',
      'dosage': 'మోతాదు',
      'logs': 'లాగ్‌లు',
      'expert': 'నిపుణులు',
      'view_all': 'అన్నీ చూడండి',
      'change_location': 'ప్రాంతం మార్చండి',
      'set_farm_location': 'పొలం ప్రాంతాన్ని నమోదు చేయండి',
      'search_placeholder': 'పంటలు, మార్కెట్లు లేదా పథకాలను శోధించండి...',
      'retry': 'మళ్ళీ ప్రయత్నించండి',
      'complete_setup': 'సెటప్ పూర్తి చేయండి',
      'setup_success': 'ఫారం సెటప్ పూర్తయింది! అగ్రిపైలట్‌కు స్వాగతం.',
      'non_agri_warning': 'ఈ చిత్రంలో ఎటువంటి వ్యవసాయ వస్తువు కనిపించడం లేదు.',
      'low_conf_warning': 'పంటను నమ్మకంగా నిర్ధారించలేకపోతున్నాము.',
    },
  };

  String get(String key) {
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
