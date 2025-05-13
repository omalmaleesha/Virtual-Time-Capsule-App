import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String _lastUsedTemplateKey = 'last_used_template';
  static const String _favoriteTemplatesKey = 'favorite_templates';

  // Onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  static Future<void> setCompletedOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, value);
  }

  // Last used template
  static Future<String?> getLastUsedTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUsedTemplateKey);
  }

  static Future<void> setLastUsedTemplate(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUsedTemplateKey, templateId);
  }

  // Favorite templates
  static Future<List<String>> getFavoriteTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteTemplatesKey) ?? [];
  }

  static Future<void> addFavoriteTemplate(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoriteTemplatesKey) ?? [];
    if (!favorites.contains(templateId)) {
      favorites.add(templateId);
      await prefs.setStringList(_favoriteTemplatesKey, favorites);
    }
  }

  static Future<void> removeFavoriteTemplate(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoriteTemplatesKey) ?? [];
    if (favorites.contains(templateId)) {
      favorites.remove(templateId);
      await prefs.setStringList(_favoriteTemplatesKey, favorites);
    }
  }

  static Future<bool> isTemplateFavorite(String templateId) async {
    final favorites = await getFavoriteTemplates();
    return favorites.contains(templateId);
  }
}
