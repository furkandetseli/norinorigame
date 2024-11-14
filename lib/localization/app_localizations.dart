import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation & Common
      'settings': 'Settings',
      'statistics': 'Statistics',
      'game': 'Game',
      'theme': 'Theme',
      'language': 'Language',
      'ok': 'OK',
      'cancel': 'Cancel',
      'back': 'Back',
      'continue': 'Continue',
      'error': 'Error',

      // Settings
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'turkish': 'Turkish',
      'english': 'English',
      'settings_info': 'Settings Information',
      'settings_description': 'You can customize the app appearance and language preferences here. Changes are saved automatically.',

      // Statistics
      'completed_levels': 'Completed Levels',
      'success_rate': 'Success Rate',
      'best_time': 'Best Time',
      'streak_record': 'Streak Record',
      'total_time': 'Total Time',
      'hints_used': 'Hints Used',
      'current_streak': 'Current Streak',
      'progress_by_size': 'Progress by Size',
      'progress_by_difficulty': 'Progress by Difficulty',
      'general_stats': 'General Statistics',
      'completed': 'completed',

      // Game Menu
      'random_level': 'Random Level',
      'saved_game': 'Saved Game',
      'level_selection': 'Level Selection',
      'time': 'Time',
      'lives': 'Lives',
      'hints': 'Hints',
      'level_size_info': '6x6, 8x8, 10x10 or 15x15',

      // Difficulty
      'select_difficulty': 'Select Difficulty',
      'normal': 'Normal',
      'hard': 'Hard',

      // Game Screen
      'loading': 'Loading...',
      'pause': 'Pause',
      'game_paused': 'Game Paused',
      'what_to_do': 'What would you like to do?',
      'resume_game': 'Resume Game',
      'return_main_menu': 'Return to Main Menu',
      'congratulations': 'Congratulations!',
      'level_completed': 'Level completed successfully!',
      'game_over': 'Game Over',
      'no_lives_remaining': 'Sorry, you\'re out of lives!',
      'new_level': 'New Level',
      'delete': 'Delete',

      // Game Rules
      'game_rules': 'Game Rules',
      'rule_1': '1. You must shade exactly 2 cells in each region.',
      'rule_2': '2. Shaded cells must be adjacent.',
      'rule_3': '3. You have 3 lives.',
      'rule_4': '4. You have 3 hints.',
      'understood': 'I Understand',

      // Error Messages
      'loading_error': 'Error loading the level. Please try again.',
      'save_error': 'Error saving game state',
      'load_error': 'Error loading saved game',
      'delete_saved_game': 'Would you like to delete the saved game and start a new one?',
    },
    'tr': {
      // Navigation & Common
      'settings': 'Ayarlar',
      'statistics': 'İstatistikler',
      'game': 'Oyun',
      'theme': 'Tema',
      'language': 'Dil',
      'ok': 'Tamam',
      'cancel': 'İptal',
      'back': 'Geri',
      'continue': 'Devam Et',
      'error': 'Hata',

      // Settings
      'dark_mode': 'Karanlık Mod',
      'light_mode': 'Aydınlık Mod',
      'turkish': 'Türkçe',
      'english': 'İngilizce',
      'settings_info': 'Ayarlar Bilgisi',
      'settings_description': 'Uygulama görünümünü ve dil tercihlerinizi buradan özelleştirebilirsiniz. Değişiklikler otomatik olarak kaydedilir.',

      // Statistics
      'completed_levels': 'Tamamlanan Bölümler',
      'success_rate': 'Başarı Oranı',
      'best_time': 'En İyi Süre',
      'streak_record': 'Seri Rekoru',
      'total_time': 'Toplam Süre',
      'hints_used': 'Kullanılan İpucu',
      'current_streak': 'Mevcut Seri',
      'progress_by_size': 'Boyuta Göre İlerleme',
      'progress_by_difficulty': 'Zorluğa Göre İlerleme',
      'general_stats': 'Genel İstatistikler',
      'completed': 'tamamlandı',

      // Game Menu
      'random_level': 'Rastgele Bölüm',
      'saved_game': 'Kayıtlı Oyun',
      'level_selection': 'Bölüm Seçimi',
      'time': 'Süre',
      'lives': 'Can',
      'hints': 'İpucu',
      'level_size_info': '6x6, 8x8, 10x10 veya 15x15',

      // Difficulty
      'select_difficulty': 'Zorluk Seçin',
      'normal': 'Normal',
      'hard': 'Zor',

      // Game Screen
      'loading': 'Yükleniyor...',
      'pause': 'Duraklat',
      'game_paused': 'Oyun Duraklatıldı',
      'what_to_do': 'Ne yapmak istersiniz?',
      'resume_game': 'Devam Et',
      'return_main_menu': 'Ana Menüye Dön',
      'congratulations': 'Tebrikler!',
      'level_completed': 'Bölümü başarıyla tamamladınız!',
      'game_over': 'Oyun Bitti',
      'no_lives_remaining': 'Üzgünüm, tüm haklarınız bitti!',
      'new_level': 'Yeni Bölüm',
      'delete': 'Sil',

      // Game Rules
      'game_rules': 'Oyun Kuralları',
      'rule_1': '1. Her bölgede tam olarak 2 hücre boyamalısınız.',
      'rule_2': '2. Boyalı hücreler birbirine bitişik olmalıdır.',
      'rule_3': '3. 3 hata hakkınız vardır.',
      'rule_4': '4. 3 ipucu hakkınız vardır.',
      'understood': 'Anladım',

      // Error Messages
      'loading_error': 'Bölüm yüklenirken bir hata oluştu. Lütfen tekrar deneyin.',
      'save_error': 'Oyun durumu kaydedilirken hata oluştu',
      'load_error': 'Kayıtlı oyun yüklenirken hata oluştu',
      'delete_saved_game': 'Kayıtlı oyunu silmek ve yeni bir oyuna başlamak ister misiniz?',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('tr', ''),
  ];
}