import 'package:flutter/material.dart';

class WasteSummary_Card extends StatelessWidget {
  final double totalWaste;
  final List<Map<String, dynamic>> smartlistItems;
  final double lifetimeWaste;
  final double lifetimeBought;

  WasteSummary_Card(
      {required this.totalWaste,
      required this.smartlistItems,
      required this.lifetimeWaste,
      required this.lifetimeBought});

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

  @override
  Widget build(BuildContext context) {
    print('WasteSummary_Card Inputs');
    print('  totalWaste (this week): $totalWaste');
    print('  smartlistItems (count): ${smartlistItems.length}');
    print('  lifetimeWaste: $lifetimeWaste');
    print('  lifetimeBought: $lifetimeBought');

    double totalBought = 0.0;
    for (var item in smartlistItems) {
      double purchaseAmount = (item['purchase_amount'] ?? 0).toDouble();
      if (purchaseAmount == 0.0) continue;
      String unit = item['unit'] ?? '';
      totalBought += convertToGrams(purchaseAmount, unit);
    }

    double wastePct = totalBought > 0 ? (totalWaste / totalBought) * 100 : 0.0;
    double lifetimeWastePct =
        lifetimeBought > 0 ? (lifetimeWaste / lifetimeBought) * 100 : 0.0;

    double efficiency = 100 - wastePct;
    double lifetimeEfficiency = 100 - lifetimeWastePct;

    Color efficiencyColor(double value) {
      if (value >= 84) return Colors.green; // Better than UK avg
      if (value >= 70) return Colors.orange;
      return Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// Headings row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("This Week",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Lifetime", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("UK Average",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
// Percentages row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${efficiency.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: efficiencyColor(efficiency),
                  ),
                ),
                Text(
                  "${lifetimeEfficiency.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: efficiencyColor(lifetimeEfficiency),
                  ),
                ),
                const Text(
                  "84%",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Explanatory text (full width)
            Text(
              "This week ${totalWaste.toStringAsFixed(1)}g food was wasted vs ${totalBought.toStringAsFixed(1)}g food bought",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            const Text(
              "Compares food waste vs food bought, includes unused and prep waste.",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
