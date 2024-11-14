import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../localization/app_localizations.dart';
import '../models/game_statistics.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<GameStatistics> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _statisticsFuture = _loadStatistics();
  }

  Future<GameStatistics> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('game_statistics');
    if (statsJson != null) {
      return GameStatistics.fromJson(json.decode(statsJson));
    }
    return GameStatistics();
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return '0:00';
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(String title, Map<String, int> data, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...data.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / (entry.value + 10),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  Text('${entry.value} ${l10n.get('completed')}'),
                  SizedBox(height: 8),
                ],
              );
            }).toList(),
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
        title: Text(l10n.get('statistics')),
        centerTitle: true,
      ),
      body: FutureBuilder<GameStatistics>(
        future: _statisticsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data!;
          final completionRate = stats.totalGamesPlayed == 0
              ? 0
              : (stats.gamesCompleted / stats.totalGamesPlayed * 100).toStringAsFixed(1);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      l10n.get('completed_levels'),
                      stats.gamesCompleted.toString(),
                      Icons.done_all,
                    ),
                    _buildStatCard(
                      l10n.get('success_rate'),
                      '$completionRate%',
                      Icons.analytics,
                    ),
                    _buildStatCard(
                      l10n.get('best_time'),
                      _formatDuration(stats.bestTime),
                      Icons.timer,
                    ),
                    _buildStatCard(
                      l10n.get('streak_record'),
                      stats.bestStreak.toString(),
                      Icons.local_fire_department,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildProgressSection(l10n.get('progress_by_size'), stats.completedBySize, context),
                _buildProgressSection(l10n.get('progress_by_difficulty'), stats.completedByDifficulty, context),
                Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.get('general_stats'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ListTile(
                          leading: Icon(Icons.access_time),
                          title: Text(l10n.get('total_time')),
                          trailing: Text(_formatDuration(stats.totalTimePlayed)),
                        ),
                        ListTile(
                          leading: Icon(Icons.lightbulb),
                          title: Text(l10n.get('hints_used')),
                          trailing: Text(stats.totalHintsUsed.toString()),
                        ),
                        ListTile(
                          leading: Icon(Icons.local_fire_department),
                          title: Text(l10n.get('current_streak')),
                          trailing: Text(stats.currentStreak.toString()),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}