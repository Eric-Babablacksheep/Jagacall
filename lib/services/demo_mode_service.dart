import 'package:shared_preferences/shared_preferences.dart';

class DemoModeService {
  static const String _demoModeKey = 'demo_mode_enabled';
  static bool _isDemoMode = true; // Default to demo mode
  
  static bool get isDemoMode => _isDemoMode;
  
  /// Initialize demo mode from local storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDemoMode = prefs.getBool(_demoModeKey) ?? true; // Default to true
  }
  
  /// Toggle demo mode on/off
  static Future<void> toggleDemoMode() async {
    _isDemoMode = !_isDemoMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, _isDemoMode);
  }
  
  /// Set demo mode explicitly
  static Future<void> setDemoMode(bool enabled) async {
    _isDemoMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, enabled);
  }
  
  /// Get demo mode status as string
  static String get demoModeStatus => _isDemoMode ? 'ON' : 'OFF';
  
  /// Get demo mode description
  static String get demoModeDescription {
    if (_isDemoMode) {
      return 'Demo Mode: Using simulated AI responses for testing. No real API calls are made.';
    } else {
      return 'Live Mode: Real API calls to ILMU backend will be made.';
    }
  }
}