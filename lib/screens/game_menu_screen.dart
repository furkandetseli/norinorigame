import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../localization/app_localizations.dart';
import 'puzzle_screen.dart';
import '../screens/main_screen.dart';
import '../services/level_service.dart';

class GameMenuScreen extends StatefulWidget {
  @override
  State<GameMenuScreen> createState() => _GameMenuScreenState();
}

class _GameMenuScreenState extends State<GameMenuScreen> with WidgetsBindingObserver {
  final levelService = LevelService();
  late Future<Map<String, dynamic>?> savedGameFuture;
  late Timer _refreshTimer;

  final List<Map<String, dynamic>> randomLevelOptions = [
    {'size': 6, 'difficulty': 'normal'},
    {'size': 6, 'difficulty': 'hard'},
    {'size': 8, 'difficulty': 'normal'},
    {'size': 8, 'difficulty': 'hard'},
    {'size': 10, 'difficulty': 'normal'},
    {'size': 10, 'difficulty': 'hard'},
    {'size': 15, 'difficulty': 'normal'},
    {'size': 15, 'difficulty': 'hard'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    savedGameFuture = getSavedGameInfo();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _refreshSavedGame();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshSavedGame();
    }
  }

  void _refreshSavedGame() {
    setState(() {
      savedGameFuture = getSavedGameInfo();
    });
  }

  Future<Map<String, dynamic>?> getSavedGameInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('puzzle_state_')).toList();

      if (keys.isEmpty) return null;

      Map<String, dynamic>? latestSave;
      int latestTimestamp = 0;

      for (var key in keys) {
        final savedStateJson = prefs.getString(key);
        if (savedStateJson != null) {
          final savedState = jsonDecode(savedStateJson);
          final timestamp = savedState['lastUpdated'] ?? 0;
          if (timestamp > latestTimestamp) {
            latestTimestamp = timestamp;
            latestSave = {
              'levelId': key.replaceFirst('puzzle_state_', ''),
              'state': savedState,
            };
          }
        }
      }

      return latestSave;
    } catch (e) {
      print('Error getting saved game info: $e');
      return null;
    }
  }

  void _handleDeleteSavedGame(BuildContext context, String levelId) async {
    final l10n = AppLocalizations.of(context);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('puzzle_state_$levelId');
      await prefs.remove('level_info_$levelId');

      if (context.mounted) {
        Navigator.pop(context);
        _refreshSavedGame();
      }
    } catch (e) {
      print('Error deleting saved game: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.get('save_error'))),
        );
      }
    }
  }

  void _showErrorDialog(BuildContext context, String levelId) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('error')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.get('load_error')),
            SizedBox(height: 8),
            Text(l10n.get('delete_saved_game')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('cancel')),
          ),
          TextButton(
            onPressed: () => _handleDeleteSavedGame(context, levelId),
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );
  }

  void _loadSavedGame(BuildContext context, String levelId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final levelData = await levelService.getLevelData(levelId, 0, '');

      if (context.mounted) {
        Navigator.pop(context);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PuzzleScreen(
              levelId: levelId,
              size: levelData.size,
              difficulty: levelData.difficulty,
            ),
          ),
        );

        _refreshSavedGame();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, levelId);
      }
    }
  }

  Future<void> _startRandomGame(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      randomLevelOptions.shuffle();
      final option = randomLevelOptions.first;
      String randomLevel = await levelService.getRandomLevel(
        option['size'],
        option['difficulty'],
      );

      if (context.mounted) {
        Navigator.pop(context);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PuzzleScreen(
              levelId: randomLevel,
              size: option['size'],
              difficulty: option['difficulty'],
            ),
          ),
        );

        _refreshSavedGame();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.get('error')),
            content: Text(l10n.get('loading_error')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.get('ok')),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showDifficultyDialog(BuildContext context, String size) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('select_difficulty')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.star_outline),
              title: Text(l10n.get('normal')),
              onTap: () => _startGame(context, size, 'normal'),
            ),
            ListTile(
              leading: Icon(Icons.stars),
              title: Text(l10n.get('hard')),
              onTap: () => _startGame(context, size, 'hard'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startGame(BuildContext context, String size, String difficulty) async {
    final l10n = AppLocalizations.of(context);
    Navigator.pop(context);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      int gridSize = int.parse(size.split('x')[0]);
      String randomLevel = await levelService.getRandomLevel(gridSize, difficulty);

      if (context.mounted) {
        Navigator.pop(context);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PuzzleScreen(
              levelId: randomLevel,
              size: gridSize,
              difficulty: difficulty,
            ),
          ),
        );

        _refreshSavedGame();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.get('error')),
            content: Text(l10n.get('loading_error')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.get('ok')),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildSizeCard(BuildContext context, String size) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showDifficultyDialog(context, size),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_on, size: 48),
            SizedBox(height: 8),
            Text(
              size,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Norinori'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshSavedGame();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: savedGameFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final savedGame = snapshot.data!;
                    final state = savedGame['state'];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Icon(Icons.save, color: Colors.blue),
                        title: Text(l10n.get('saved_game')),
                        subtitle: Text(
                            '${l10n.get('time')}: ${Duration(seconds: state['elapsed']).inMinutes}:${(Duration(seconds: state['elapsed']).inSeconds % 60).toString().padLeft(2, '0')} • '
                                '${l10n.get('lives')}: ${state['remainingLives']} • '
                                '${l10n.get('hints')}: ${state['remainingHints']}'
                        ),
                        onTap: () => _loadSavedGame(context, savedGame['levelId']),
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),

              Card(
                margin: EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => _startRandomGame(context),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.shuffle, size: 48, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          l10n.get('random_level'),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 4),
                        Text(
                          l10n.get('level_size_info'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Text(
                l10n.get('level_selection'),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildSizeCard(context, '6x6'),
                    _buildSizeCard(context, '8x8'),
                    _buildSizeCard(context, '10x10'),
                    _buildSizeCard(context, '15x15'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}