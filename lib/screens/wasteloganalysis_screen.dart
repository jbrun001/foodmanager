import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import 'package:go_router/go_router.dart'; // required for login redirect
import 'menu_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // needed for Timestamp
// f1_charts reference https://clay-atlas.com/us/blog/2021/10/14/flutter-en-flchart-pie-chart/
import '../widgets/wastesummary_card.dart';
import '../services/testing_service.dart';

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
    _initialiseWeeks();
  }

  void _initialiseWeeks() {
    DateTime now = DateTime.now();
    // Get the current week start (assuming week starts on Sunday)
    DateTime currentWeekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday % 7),
    );
    // get the data oldest last
    _weekStarts = [];
    for (int i = 3; i >= 0; i--) {
      _weekStarts.add(currentWeekStart.subtract(Duration(days: 7 * i)));
    }
  }

  // aggregates the waste logs for each week into a map
  Future<Map<String, Map<String, double>>> _getWeeklyStats() async {
    // map keys will be week labels (e.g., "Sep 22") and values are a map of stats.
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
      String label = weekStart.toIso8601String().split('T')[0];
      weeklyStats[label] = {
        'totalWaste': totalWaste,
        'totalRecycled': totalRecycled,
        'totalComposted': totalComposted,
        // 'totalInedible': totalInedible, don't want to show inedible
      };
      // testing - output result of weekly stats
      testLog('waste.analysis.getWeeklyStats', 'results',
          {'lable': label, 'total waste': totalWaste});
    }

    return weeklyStats;
  }

  Future<Map<String, dynamic>> _getWeeklyData() async {
    try {
      final stats = await _getWeeklyStats();
      final weekStart = _weekStarts.last;

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
        final dynamic ts = log['logdate'];
        late DateTime date;

        if (ts is Timestamp) {
          date = ts.toDate();
        } else if (ts is String) {
          date = DateTime.tryParse(ts) ?? DateTime(2000);
        } else {
          date = DateTime(2000);
        }

        final logWeekStart = DateTime(
          date.year,
          date.month,
          date.day - (date.weekday % 7),
        );
        // debug - check date formats match
        testLog('waste.analysis._getWeeklyData', 'compare log date', {
          'check': date.toIso8601String(),
          'logWeekStart': logWeekStart,
          'vs expected': currentWeekId
        });
        lifetimeWaste += (log['amount'] ?? 0.0) as double;
      }

      double lifetimeBought = 0.0;
      for (var doc in allSmartlists) {
        final items =
            doc['items'] as List<dynamic>; // cast to dynamic list first

        for (var rawItem in items) {
          final item = Map<String, dynamic>.from(rawItem);
          double amount = (item['purchase_amount'] ?? 0.0) as double;
          if (amount == 0.0) continue;
          // debug
          //print(
          //    'smartlist: ${item['name']} ${item['purchase_amount']}${item['unit']} = ${convertToGrams(amount, item['unit'] ?? '')}g');
          lifetimeBought += convertToGrams(amount, item['unit'] ?? '');
        }
      }
      // testing
      testLog('waste.analysis._getWeeklyData', 'compare log date', {
        'weekStart': weekStart,
        'lifetimeWaste': lifetimeWaste,
        'lifetimeBought': lifetimeBought
      });

      return {
        'weeklyStats': stats,
        'smartlistItems': smartlistItems,
        'weekStart': weekStart,
        'lifetimeWaste': lifetimeWaste,
        'lifetimeBought': lifetimeBought,
      };
    } catch (e) {
      testLog('waste.analysis._getWeeklyData', 'error caught',
          {'error': e.toString()});
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
    String latestWeekLabel = _weekStarts.last.toIso8601String().split('T')[0];
    Map<String, double> latestStats = weeklyStats[latestWeekLabel] ??
        {'totalRecycled': 0, 'totalComposted': 0, 'totalInedible': 0};

    double recycled = latestStats['totalRecycled'] ?? 0.0;
    double composted = latestStats['totalComposted'] ?? 0.0;
    double totalWaste = latestStats['totalWaste'] ?? 0.0;
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
        title: const Text('Waste Efficiency'),
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

          final latestWeekLabel = weekStart.toIso8601String().split('T')[0];
          final double totalWaste =
              weeklyStats[latestWeekLabel]?['totalWaste'] ?? 0.0;
          final entries = weeklyStats.entries.toList();

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
                  // bar chart of total waste per week
                  Text(
                    'Food Waste by Week',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxWaste(weeklyStats),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false, // no vertical lines
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey[300],
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false, // no borders around the chart
                      ),
                      barGroups: entries.asMap().entries.map((e) {
                        final index = e.key;
                        final entry = e.value;

                        final total = entry.value['totalWaste'] ?? 0.0;
                        final composted = entry.value['totalComposted'] ?? 0.0;
                        final recycled = entry.value['totalRecycled'] ?? 0.0;

                        if (total == 0) {
                          return BarChartGroupData(x: index, barRods: []);
                        }

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: total,
                              rodStackItems: [
                                BarChartRodStackItem(0, recycled, Colors.blue),
                                BarChartRodStackItem(recycled,
                                    recycled + composted, Colors.green),
                              ],
                              width: 22,
                              borderRadius:
                                  BorderRadius.zero, // stop bars being rounded
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          axisNameWidget: const Text('g'), // y axis label
                          axisNameSize: 20,
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 50, // fixed spacing like 0, 50, 100...
                            reservedSize: 40,
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
                              final entries = weeklyStats.entries.toList();
                              if (index >= 0 && index < entries.length) {
                                final isoDate = entries[index].key;
                                final date = DateTime.tryParse(isoDate);
                                return Text(date != null
                                    ? DateFormat.MMMd().format(date)
                                    : '');
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false), // hide right axis
                        ),
                        topTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false), // hide top axis
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(color: Colors.green, label: 'Composted'),
                      _buildLegendItem(color: Colors.blue, label: 'Recycled'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // pie chart for waste composition of the latest week
                  Text(
                    'Food Waste Composition (latest week)',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
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
}
