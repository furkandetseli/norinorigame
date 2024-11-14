import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/game_statistics.dart';
import '../models/puzzle.dart';
import '../widgets/puzzle_grid.dart';
import '../services/level_service.dart';
import '../services/ad_service.dart';
import '../screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/game_controls.dart';
import '../localization/app_localizations.dart';

class PuzzleScreen extends StatefulWidget {
  final String levelId;
  final int size;
  final String difficulty;
  final Map<String, List<List<int>>>? borders;

  const PuzzleScreen({
    Key? key,
    required this.levelId,
    required this.size,
    required this.difficulty,
    this.borders,
  }) : super(key: key);

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late Puzzle puzzle;
  late AdService _adService;
  bool isCompleted = false;
  bool isLoading = true;
  PaintMode selectedMode = PaintMode.paint;
  int remainingLives = 3;
  int remainingHints = 3;
  late Timer _timer;
  Duration elapsed = Duration.zero;
  bool isTimerActive = true;
  final levelService = LevelService();

  final List<Map<String, dynamic>> allLevelOptions = [
    {'size': 6, 'difficulty': 'normal'},
    {'size': 6, 'difficulty': 'hard'},
    {'size': 8, 'difficulty': 'normal'},
    {'size': 8, 'difficulty': 'hard'},
    {'size': 10, 'difficulty': 'normal'},
    {'size': 10, 'difficulty': 'hard'},
    {'size': 15, 'difficulty': 'normal'},
    {'size': 15, 'difficulty': 'hard'},
  ];

  String get _saveStateKey => 'puzzle_state_${widget.levelId}';

  @override
  void initState() {
    super.initState();
    _adService = AdService();
    _adService.initialize();

    // Clear other saved states when starting a new puzzle
    _clearSavedState().then((_) => loadPuzzle());
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _adService.dispose();
    if (!isCompleted) {
      _saveGameState();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isTimerActive && !isCompleted) {
        setState(() {
          elapsed += Duration(seconds: 1);
        });
      }
    });
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _saveGameState() async {
    try {
      // Clear other saved states first
      await _clearSavedState();

      // Don't save if the puzzle is completed
      if (isCompleted) return;

      final prefs = await SharedPreferences.getInstance();
      final gameState = {
        'remainingLives': remainingLives,
        'remainingHints': remainingHints,
        'elapsed': elapsed.inSeconds,
        'cells': puzzle.cells.map((row) => row.map((cell) => {
          'isShaded': cell.isShaded,
        }).toList()).toList(),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(_saveStateKey, jsonEncode(gameState));
      await levelService.saveLevelInfo(widget.levelId, widget.size, widget.difficulty);
    } catch (e) {
      print('Error saving game state: $e');
    }
  }

  Future<void> _clearSavedState() async {
    final prefs = await SharedPreferences.getInstance();

    // Get all keys that start with puzzle_state_ or level_info_
    final allKeys = prefs.getKeys();
    final puzzleStateKeys = allKeys.where((key) => key.startsWith('puzzle_state_')).toList();
    final levelInfoKeys = allKeys.where((key) => key.startsWith('level_info_')).toList();

    // Keep only the current level's state if it exists
    for (var key in puzzleStateKeys) {
      if (key != _saveStateKey) {
        await prefs.remove(key);
      }
    }

    // Keep only the current level's info if it exists
    for (var key in levelInfoKeys) {
      if (key != 'level_info_${widget.levelId}') {
        await prefs.remove(key);
      }
    }

    // If the puzzle is completed, remove the current level's data too
    if (isCompleted) {
      await prefs.remove(_saveStateKey);
      await prefs.remove('level_info_${widget.levelId}');
    }
  }

  Future<void> loadPuzzle() async {
    try {
      Map<String, List<List<int>>> borders;
      if (widget.borders != null) {
        borders = widget.borders!;
      } else {
        final levelData = await levelService.getLevelData(
          widget.levelId,
          widget.size,
          widget.difficulty,
        );
        borders = levelData.getBorders();
      }

      setState(() {
        puzzle = Puzzle(widget.size, borders);
      });

      final prefs = await SharedPreferences.getInstance();
      final savedStateJson = prefs.getString(_saveStateKey);

      if (savedStateJson != null) {
        final savedState = jsonDecode(savedStateJson);
        setState(() {
          remainingLives = savedState['remainingLives'];
          remainingHints = savedState['remainingHints'];
          elapsed = Duration(seconds: savedState['elapsed']);

          final savedCells = savedState['cells'];
          for (var i = 0; i < puzzle.size; i++) {
            for (var j = 0; j < puzzle.size; j++) {
              final cellState = savedCells[i][j];
              if (cellState['isShaded'] != null) {
                final cell = puzzle.cells[i][j];
                final region = puzzle.regions[cell.regionId!];

                if (cellState['isShaded']) {
                  region.shadeCell(cell);
                  puzzle.updateConnectedShadedSquares(cell);
                } else {
                  region.crossCell(cell);
                }
              }
            }
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showRules();
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog();
      }
    }
  }

  Future<void> _loadRandomLevel() async {
    // Önce reklam göster
    await _adService.showInterstitialAd();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      allLevelOptions.shuffle();
      final option = allLevelOptions.first;
      final String randomLevel = await levelService.getRandomLevel(
        option['size'],
        option['difficulty'],
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PuzzleScreen(
            levelId: randomLevel,
            size: option['size'],
            difficulty: option['difficulty'],
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yeni bölüm yüklenirken hata oluştu')),
      );
      _navigateToMainScreen();
    }
  }

  void _showRules() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('game_rules')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.get('rule_1')),
            SizedBox(height: 8),
            Text(l10n.get('rule_2')),
            SizedBox(height: 8),
            Text(l10n.get('rule_3')),
            SizedBox(height: 8),
            Text(l10n.get('rule_4')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('understood')),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('error')),
        content: Text(l10n.get('loading_error')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToMainScreen();
            },
            child: Text(l10n.get('ok')),
          ),
        ],
      ),
    );
  }

  void _handleCellTap(Cell cell) {
    if (isCompleted || remainingLives <= 0) return;

    setState(() {
      var region = puzzle.regions[cell.regionId!];

      switch (selectedMode) {
        case PaintMode.paint:
          if (cell.isShaded != true) {
            region.shadeCell(cell);
            puzzle.updateConnectedShadedSquares(cell);
          }
          break;
        case PaintMode.cross:
          if (cell.isShaded != false) {
            region.crossCell(cell);
          }
          break;
        case PaintMode.empty:
          if (cell.isShaded != null) {
            region.emptyCell(cell);
          }
          break;
      }
    });

    _saveGameState();
    checkSolution();
  }

  void _useHint() {
    if (remainingHints <= 0 || isCompleted) return;

    List<Cell> validCells = [];
    for (var region in puzzle.regions) {
      if (region.shadedCells.length < 2) {
        for (var cell1 in region.availableCells) {
          for (var cell2 in region.availableCells) {
            if (cell1 != cell2 && _areAdjacent(cell1, cell2)) {
              validCells.add(cell1);
              break;
            }
          }
        }
      }
    }

    if (validCells.isEmpty) return;

    setState(() {
      remainingHints--;

      validCells.shuffle();
      var cellToHint = validCells.first;

      var region = puzzle.regions[cellToHint.regionId!];
      region.shadeCell(cellToHint);
      puzzle.updateConnectedShadedSquares(cellToHint);
    });

    _saveGameState();
    checkSolution();
  }

  bool _areAdjacent(Cell cell1, Cell cell2) {
    return (cell1.row == cell2.row && (cell1.col - cell2.col).abs() == 1) ||
        (cell1.col == cell2.col && (cell1.row - cell2.row).abs() == 1);
  }

  void checkSolution() {
    if (!isCompleted && remainingLives > 0) { // Can kontrolünü ekleyelim
      int f1 = 0;
      int f2 = 0;

      for (var region in puzzle.regions) {
        if (region.shadedCells.length > 2) {
          _decreaseLives();
          return;
        }
        f1 += (2 - region.shadedCells.length).abs();
      }

      Set<Cell> connectedCells = {};
      for (var region in puzzle.regions) {
        for (var cell in region.shadedCells) {
          if (!connectedCells.contains(cell)) {
            var connected = _findConnectedCells(cell);
            if (connected.length != 2 && region.shadedCells.length == 2) {
              f2++;
            }
            connectedCells.addAll(connected);
          }
        }
      }

      if (f1 == 0 && f2 == 0) {
        _handlePuzzleComplete();
      }
    }
  }

  Set<Cell> _findConnectedCells(Cell startCell) {
    Set<Cell> connected = {startCell};
    List<Cell> queue = [startCell];

    while (queue.isNotEmpty) {
      Cell current = queue.removeAt(0);
      for (var dir in [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
        int newRow = current.row + dir[0];
        int newCol = current.col + dir[1];

        if (newRow >= 0 && newRow < puzzle.size &&
            newCol >= 0 && newCol < puzzle.size) {
          Cell neighbor = puzzle.cells[newRow][newCol];
          if (neighbor.isShaded == true && !connected.contains(neighbor)) {
            connected.add(neighbor);
            queue.add(neighbor);
          }
        }
      }
    }
    return connected;
  }

  void _decreaseLives() async {
    setState(() {
      remainingLives--;
    });

    // Can sıfıra düştüğünde veya negatif olduğunda oyun biter
    if (remainingLives <= 0) {
      isTimerActive = false; // Zamanlayıcıyı durdur
      await _showGameOverWithAd();
    }
  }

  Future<void> _showGameOverWithAd() async {
    final l10n = AppLocalizations.of(context);

    // Önce reklam göster
    try {
      await _adService.showInterstitialAd();
    } catch (e) {
      print('Reklam gösteriminde hata: $e');
    }

    if (!mounted) return;

    // Sonra oyun sonu dialogunu göster
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('game_over')),
        content: Text(l10n.get('no_lives_remaining')),
        actions: [
          TextButton(
            onPressed: _navigateToMainScreen,
            child: Text(l10n.get('return_main_menu')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog'u kapat
              _loadRandomLevel(); // Yeni seviye yükle
            },
            child: Text(l10n.get('new_level')),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('game_statistics');
    final stats = statsJson != null
        ? GameStatistics.fromJson(json.decode(statsJson))
        : GameStatistics();

    stats.totalGamesPlayed++;
    stats.gamesCompleted++;
    stats.totalHintsUsed += 3 - remainingHints;
    stats.totalTimePlayed += elapsed.inSeconds;

    if (stats.bestTime == 0 || elapsed.inSeconds < stats.bestTime) {
      stats.bestTime = elapsed.inSeconds;
    }

    stats.currentStreak++;
    if (stats.currentStreak > stats.bestStreak) {
      stats.bestStreak = stats.currentStreak;
    }

    final sizeKey = '${widget.size}x${widget.size}';
    stats.completedBySize[sizeKey] = (stats.completedBySize[sizeKey] ?? 0) + 1;

    stats.completedByDifficulty[widget.difficulty] =
        (stats.completedByDifficulty[widget.difficulty] ?? 0) + 1;

    await prefs.setString('game_statistics', json.encode(stats.toJson()));
  }

  Future<void> _handlePuzzleComplete() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      isCompleted = true;
      isTimerActive = false;
    });

    await _clearSavedState();
    await _updateStatistics();

    // Tamamlama reklamını göster
    await _adService.showInterstitialAd();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('congratulations')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.get('level_completed')),
            SizedBox(height: 8),
            Text('${l10n.get('time')}: ${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}'),
            Text('${l10n.get('lives')}: $remainingLives'),
            Text('${l10n.get('hints')}: $remainingHints'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _navigateToMainScreen,
            child: Text(l10n.get('return_main_menu')),
          ),
          TextButton(
            onPressed: () => _loadRandomLevel(),
            child: Text(l10n.get('new_level')),
          ),
        ],
      ),
    );
  }

  void _showPauseDialog() {
    final l10n = AppLocalizations.of(context);
    isTimerActive = false;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('game_paused')),
        content: Text(l10n.get('what_to_do')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              isTimerActive = true;
            },
            child: Text(l10n.get('resume_game')),
          ),
          TextButton(
            onPressed: () async {
              if (!isCompleted) {
                await _saveGameState();
              }
              _navigateToMainScreen();
            },
            child: Text(l10n.get('return_main_menu')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.get('loading')),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.02;

    return WillPopScope(
      onWillPop: () async {
        if (!isCompleted) {
          await _saveGameState();
        }
        _navigateToMainScreen();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.size}x${widget.size} ${widget.difficulty}'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (!isCompleted) {
                await _saveGameState();
              }
              _navigateToMainScreen();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: _showPauseDialog,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(padding),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PuzzleGrid(
                        puzzle: puzzle,
                        onCellTap: _handleCellTap,
                        selectedMode: selectedMode,
                        isEnabled: !isCompleted && remainingLives > 0,
                      ),
                    ),
                  ),
                ),
              ),
              GameControls(
                selectedMode: selectedMode,
                remainingHints: remainingHints,
                remainingLives: remainingLives,
                elapsed: elapsed,
                onHintPressed: _useHint,
                onModeChanged: (mode) {
                  setState(() {
                    selectedMode = mode;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}