class ExerciseAssets {
  static const String _defaultImage =
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500&auto=format&fit=crop&q=60';

  static final Map<String, String> _assets = {
    'flexiones':
        'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=500&auto=format&fit=crop&q=60',
    'sentadillas':
        'https://images.unsplash.com/photo-1574680096141-1cddd32e04ca?w=500&auto=format&fit=crop&q=60',
    'burpees':
        'https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?w=500&auto=format&fit=crop&q=60',
    'plancha':
        'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=500&auto=format&fit=crop&q=60',
    'zancadas':
        'https://images.unsplash.com/photo-1434608519344-49d77a699ded?w=500&auto=format&fit=crop&q=60',
  };

  static String getAssetFor(String exerciseName) {
    final key = exerciseName.toLowerCase().trim();
    return _assets[key] ?? _defaultImage;
  }

  static bool isNetwork(String path) {
    return path.startsWith('http') || path.startsWith('https');
  }
}
