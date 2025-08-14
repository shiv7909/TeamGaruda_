import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String statusMessage;
  final VoidCallback onUploadTap;
  final VoidCallback onClearTap;

  const DashboardPage({
    Key? key,
    required this.data,
    required this.statusMessage,
    required this.onUploadTap,
    required this.onClearTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (data.isNotEmpty)
                Chip(
                  label: Text('${data.length} Records'),
                  backgroundColor: Colors.blue.shade100,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            statusMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          if (data.isEmpty)
            _buildEmptyState()
          else ...[
            _buildKpiCards(),
            const SizedBox(height: 24),
            _buildChart(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onUploadTap,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload CSV File'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCards() {
    if (data.isEmpty) return const SizedBox.shrink();

    List<Widget> cards = [];
    final headers = data.first.keys.toList();
    final numericColumns = headers.where((header) {
      final value = data.first[header];
      return value is num;
    }).toList();

    for (int i = 0; i < numericColumns.length && i < 4; i++) {
      final column = numericColumns[i];
      final values = data.map((row) => (row[column] as num)).toList();
      final total = values.fold<double>(0.0, (sum, value) => sum + value.toDouble());
      final average = values.isEmpty ? 0.0 : total / values.length;

      cards.add(
        _buildKpiCard(
          title: column,
          value: NumberFormat('#,##0.00').format(total),
          subtitle: 'Total',
          secondaryValue: 'Avg: ${NumberFormat('#,##0.00').format(average)}',
        ),
      );
    }

    if (cards.isEmpty) {
      return Center(
        child: _buildKpiCard(
          title: 'No Numeric Data',
          value: data.length.toString(),
          subtitle: 'Total Rows',
          secondaryValue: '${headers.length} Columns',
        ),
      );
    }

    return GridView.count(
      crossAxisCount: cards.length.clamp(1, 4),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.5,
      children: cards,
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    String? secondaryValue,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            if (secondaryValue != null) ...[
              const SizedBox(height: 4),
              Text(
                secondaryValue,
                style: const TextStyle(fontSize: 10, color: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (data.isEmpty) return const SizedBox.shrink();

    final headers = data.first.keys.toList();
    final numericColumns = headers.where((header) {
      final value = data.first[header];
      return value is num;
    }).toList();

    if (numericColumns.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Chart requires at least 2 numeric columns'),
          ),
        ),
      );
    }

    final xColumn = headers.firstWhereOrNull((header) => !(numericColumns.contains(header)));
    final yColumn = numericColumns[0];

    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final yValue = (data[i][yColumn] as num?);
      if (yValue != null) {
        spots.add(FlSpot(i.toDouble(), yValue.toDouble()));
      }
    }

    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chart: $yColumn over Time',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) => Text(
                          NumberFormat.compact().format(value),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (xColumn != null && index >= 0 && index < data.length) {
                            return Text(
                              data[index][xColumn].toString(),
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            );
                          } else if (index >= 0 && index < data.length) {
                            return Text(
                              'Row ${index + 1}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}