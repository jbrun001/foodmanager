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
    double totalBought = 0.0;

    for (var item in smartlistItems) {
      double purchaseAmount = (item['purchase_amount'] ?? 0.0) as double;
      if (purchaseAmount == 0.0) continue;
      String unit = item['unit'] ?? '';
      totalBought += convertToGrams(purchaseAmount, unit);
    }

    double percent = totalBought > 0 ? (totalWaste / totalBought) * 100 : 0.0;
    double lifetimePercent =
        lifetimeBought > 0 ? (lifetimeWaste / lifetimeBought) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Waste Efficiency",
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Text(
              "${percent.toStringAsFixed(1)}% of food bought was wasted\n(the UK avg: is 16%)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Your food waste was ${totalWaste.toStringAsFixed(1)}g out of ${totalBought.toStringAsFixed(1)}g bought.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              "Since you have been using this app your waste efficiency is ${lifetimePercent.toStringAsFixed(1)}%",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Includes unused and prep waste.",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
