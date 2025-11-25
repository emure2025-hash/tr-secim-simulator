import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultPage extends StatelessWidget {
  final Map<String, int> results;

  const ResultPage({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final totalSeats = results.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Milletvekili Dağılımı"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Grafik Gösterimi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 250),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sections: results.entries.map((e) {
                  final percent = (e.value / totalSeats) * 100;

                  return PieChartSectionData(
                    value: percent,
                    title: "${percent.toStringAsFixed(1)}%",
                    radius: 55,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            "Detaylı Liste",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ...results.entries.map((e) => ListTile(
                title: Text(
                  e.key,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  "${e.value} MV",
                  style: const TextStyle(fontSize: 18),
                ),
              )),
        ],
      ),
    );
  }
}
