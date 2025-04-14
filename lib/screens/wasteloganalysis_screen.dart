import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import 'package:go_router/go_router.dart'; // required for login redirect
import 'menu_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // needed for Timestamp
// f1_charts reference https://clay-atlas.com/us/blog/2021/10/14/flutter-en-flchart-pie-chart/
import '../widgets/wastesummary_card.dart';

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
    // get the data oldest last
    _weekStarts = [];
    for (int i = 3; i >= 0; i--) {
      _weekStarts.add(currentWeekStart.subtract(Duration(days: 7 * i)));
    }
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
      double totalRecycled = 0;

      for (var log in logs) {
        totalWaste += (log['amount'] ?? 0) as double;
        totalComposted += (log['composted'] ?? 0) as double;
        totalInedible += (log['inedibleParts'] ?? 0) as double;
        totalRecycled += (log['recycled'] ?? 0) as double;
      }
      String label = DateFormat.MMMd().format(weekStart);
      weeklyStats[label] = {
        'totalWaste': totalWaste,
        'totalRecycled': totalRecycled,
        'totalComposted': totalComposted,
        // 'totalInedible': totalInedible, don't want to show inedible
      };
    }
    return weeklyStats;
  }

  Future<Map<String, dynamic>> _getWeeklyData() async {
    try {
      final stats = await _getWeeklyStats();
      final weekStart = _weekStarts.first;

      final smartlistItems =
          await widget.firebaseService.getSmartlistForWeek(userId, weekStart);
      final allLogs = await widget.firebaseService.getAllWasteLogsRaw(userId);
      final allSmartlists =
          await widget.firebaseService.getAllSmartlistDocuments(userId);
      final currentWeekId = DateFormat('yyyy-MM-dd').format(weekStart);

      double convertToGrams(double amount, String unit) {
        switch (unit.toLowerCase()) {
          case 'kg':
            return amount * 1000;
          case 'g':
            return amount;
          case 'l':
            return amount * 1000;
          case 'ml':
            return amount;
          case 'tbsp':
            return amount * 15;
          case 'tsp':
            return amount * 5;
          case '':
            return 100;
          default:
            return amount;
        }
      }

      double lifetimeWaste = 0.0;
      for (var log in allLogs) {
        final dynamic ts = log['timestamp'] ?? log['date'];
        late DateTime date;

        if (ts is Timestamp) {
          date = ts.toDate();
        } else if (ts is String) {
          date = DateTime.tryParse(ts) ?? DateTime(2000);
        } else {
          date = DateTime(2000);
        }

        final logWeekStart = date.subtract(Duration(days: date.weekday % 7));
        if (DateFormat('yyyy-MM-dd').format(logWeekStart) == currentWeekId)
          continue;

        lifetimeWaste += (log['amount'] ?? 0.0) as double;
      }

      double lifetimeBought = 0.0;
      for (var doc in allSmartlists) {
        if (doc['weekId'] == currentWeekId) continue;

        final items =
            doc['items'] as List<dynamic>; // cast to dynamic list first

        for (var rawItem in items) {
          final item = Map<String, dynamic>.from(rawItem);
          double amount = (item['purchase_amount'] ?? 0.0) as double;
          if (amount == 0.0) continue;
// debug
          print(
              'smartlist: ${item['name']} ${item['purchase_amount']}${item['unit']} = ${convertToGrams(amount, item['unit'] ?? '')}g');
          lifetimeBought += convertToGrams(amount, item['unit'] ?? '');
        }
      }
// debug
      print(
          'weekstart: $weekStart | lifetimeWaste: $lifetimeWaste | lifetimeBought: $lifetimeBought');
      return {
        'weeklyStats': stats,
        'smartlistItems': smartlistItems,
        'weekStart': weekStart,
        'lifetimeWaste': lifetimeWaste,
        'lifetimeBought': lifetimeBought,
      };
    } catch (e, stacktrace) {
      print('Error in _getWeeklyData: $e');
      print(stacktrace);
      rethrow;
    }
  }

  double _getMaxWaste(Map<String, Map<String, double>> weeklyStats) {
    double max = 0;
    weeklyStats.forEach((key, stats) {
      final total = (stats['totalWaste'] as double?) ?? 0.0;
      if (total > max) max = total;
    });
    return max > 0 ? max + 20 : 100; // use 100 if everything is 0
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, Map<String, double>> weeklyStats) {
    // assume the latest week is the first week in _weekStarts.
    String latestWeekLabel = DateFormat.MMMd().format(_weekStarts.first);
    Map<String, double> latestStats = weeklyStats[latestWeekLabel] ??
        {'totalRecycled': 0, 'totalComposted': 0, 'totalInedible': 0};

    double recycled = latestStats['totalRecycled']!;
    double composted = latestStats['totalComposted']!;
    double totalWaste = latestStats['totalWaste']!;
//    double inedible = latestStats['totalInedible']!;  don't show inedible
//    double other = totalWaste - (composted + recycled);

    List<PieChartSectionData> sections = [];

    if (totalWaste > 0) {
      sections.add(
        PieChartSectionData(
          value: composted,
          color: Colors.green,
          title: '${((composted / totalWaste) * 100).toStringAsFixed(1)}%',
          titleStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          titlePositionPercentageOffset: 0.6,
        ),
      );
      sections.add(
        PieChartSectionData(
          value: recycled,
          color: Colors.blue,
          title: '${((recycled / totalWaste) * 100).toStringAsFixed(1)}%',
          titleStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          titlePositionPercentageOffset: 0.6,
        ),
      );
    } else {
      sections.add(
        PieChartSectionData(
          value: 1,
          color: Colors.grey,
          title: 'No Data',
          titleStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Log Analysis'),
      ),
      drawer: MenuDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getWeeklyData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading analysis.'));
          }

          final weeklyStats =
              snapshot.data!['weeklyStats'] as Map<String, Map<String, double>>;
          final smartlistItems =
              snapshot.data!['smartlistItems'] as List<Map<String, dynamic>>;
          final weekStart = snapshot.data!['weekStart'] as DateTime;
          final lifetimeWaste = snapshot.data!['lifetimeWaste'] as double;
          final lifetimeBought = snapshot.data!['lifetimeBought'] as double;

          final latestWeekLabel = DateFormat.MMMd().format(weekStart);
          final double totalWaste =
              weeklyStats[latestWeekLabel]?['totalWaste'] ?? 0.0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  WasteSummary_Card(
                    totalWaste: totalWaste,
                    smartlistItems: smartlistItems,
                    lifetimeWaste: lifetimeWaste,
                    lifetimeBought: lifetimeBought,
                  ),
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
                        barGroups:
                            weeklyStats.entries.toList().reversed.map((entry) {
                          final index =
                              weeklyStats.keys.toList().indexOf(entry.key);

                          final total =
                              (entry.value['totalWaste'] as double?) ?? 0.0;
                          final composted =
                              (entry.value['totalComposted'] as double?) ?? 0.0;
                          final inedible =
                              (entry.value['totalInedible'] as double?) ?? 0.0;

                          final recycled = total - (composted + inedible);

                          // Skip bar if total is zero (avoids invisible bars)
                          if (total == 0) {
                            return BarChartGroupData(x: index, barRods: []);
                          }

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: total,
                                rodStackItems: [
                                  BarChartRodStackItem(0, recycled,
                                      Colors.blue), // Recycled (base)
                                  BarChartRodStackItem(
                                      recycled,
                                      recycled + composted,
                                      Colors.green), // Composted (on top)
                                ],
                                width: 22,
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
                                List<String> labels =
                                    weeklyStats.keys.toList().reversed.toList();
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(color: Colors.green, label: 'Composted'),
                      _buildLegendItem(color: Colors.blue, label: 'Recycled'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
