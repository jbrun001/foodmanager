import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import 'package:go_router/go_router.dart'; // required for login redirect
import 'menu_drawer.dart';

class WasteLogAnalysisScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const WasteLogAnalysisScreen({required this.firebaseService});

  @override
  _WasteLogAnalysisScreenState createState() => _WasteLogAnalysisScreenState();
}

class _WasteLogAnalysisScreenState extends State<WasteLogAnalysisScreen> {
  // Define a range of weeks to analyze (for example, the last 4 weeks)
  late List<DateTime> _weekStarts;
  String userId = ''; // used to hold the current user

  @override
  void initState() {
    super.initState();
    userId = FirebaseService().getCurrentUserId();
    if (userId == '') {
      print("No user logged in. Redirecting to login page...");
      context.go('/');
    }
    _initializeWeeks();
  }

  void _initializeWeeks() {
    DateTime now = DateTime.now();
    // Get the current week start (assuming week starts on Sunday)
    DateTime currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
    _weekStarts = List.generate(
        4, (index) => currentWeekStart.subtract(Duration(days: 7 * index)));
  }

  /// Aggregates the waste logs for each week into a map
  Future<Map<String, Map<String, double>>> _getWeeklyStats() async {
    // Map keys will be week labels (e.g., "Sep 22") and values are a map of stats.
    Map<String, Map<String, double>> weeklyStats = {};

    for (DateTime weekStart in _weekStarts) {
      List<Map<String, dynamic>> logs =
          await widget.firebaseService.getWasteLogsForWeek(
        userId: userId,
        weekStart: weekStart,
      );

      double totalWaste = 0;
      double totalComposted = 0;
      double totalInedible = 0;

      for (var log in logs) {
        totalWaste += (log['amount'] ?? 0) as double;
        totalComposted += (log['composted'] ?? 0) as double;
        totalInedible += (log['inedibleParts'] ?? 0) as double;
      }
      String label = DateFormat.MMMd().format(weekStart);
      weeklyStats[label] = {
        'totalWaste': totalWaste,
        'totalComposted': totalComposted,
        'totalInedible': totalInedible,
      };
    }
    return weeklyStats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Log Analysis'),
      ),
      drawer: MenuDrawer(),
      body: FutureBuilder<Map<String, Map<String, double>>>(
        future: _getWeeklyStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading analysis.'));
          }
          final weeklyStats = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Graph 1: Bar chart of total waste per week
                  Text(
                    'Weekly Total Waste',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxWaste(weeklyStats),
                        barGroups: weeklyStats.entries.map((entry) {
                          double totalWaste = entry.value['totalWaste']!;
                          int index =
                              weeklyStats.keys.toList().indexOf(entry.key);
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: totalWaste,
                                color: Colors.blue,
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(value.toInt().toString());
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                int index = value.toInt();
                                List<String> labels = weeklyStats.keys.toList();
                                if (index >= 0 && index < labels.length) {
                                  return Text(labels[index]);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Graph 2: Pie chart for waste composition of the latest week
                  Text(
                    'Waste Composition (Latest Week)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(weeklyStats),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _getMaxWaste(Map<String, Map<String, double>> weeklyStats) {
    double max = 0;
    weeklyStats.forEach((key, stats) {
      if (stats['totalWaste']! > max) max = stats['totalWaste']!;
    });
    return max + (max * 0.1);
  }

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, Map<String, double>> weeklyStats) {
    // Assume the latest week is the first week in _weekStarts.
    String latestWeekLabel = DateFormat.MMMd().format(_weekStarts.first);
    Map<String, double> latestStats = weeklyStats[latestWeekLabel] ??
        {'totalWaste': 0, 'totalComposted': 0, 'totalInedible': 0};
    double totalWaste = latestStats['totalWaste']!;
    double composted = latestStats['totalComposted']!;
    double inedible = latestStats['totalInedible']!;
    double other = totalWaste - (composted + inedible);

    List<PieChartSectionData> sections = [];
    if (totalWaste > 0) {
      sections.add(
        PieChartSectionData(
          value: composted,
          color: Colors.green,
          title: '${((composted / totalWaste) * 100).toStringAsFixed(1)}%',
        ),
      );
      sections.add(
        PieChartSectionData(
          value: inedible,
          color: Colors.red,
          title: '${((inedible / totalWaste) * 100).toStringAsFixed(1)}%',
        ),
      );
      sections.add(
        PieChartSectionData(
          value: other,
          color: Colors.blue,
          title: '${((other / totalWaste) * 100).toStringAsFixed(1)}%',
        ),
      );
    } else {
      sections.add(
        PieChartSectionData(
          value: 1,
          color: Colors.grey,
          title: 'No Data',
        ),
      );
    }
    return sections;
  }
}
