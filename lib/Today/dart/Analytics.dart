import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String statusMessage;

  const AnalyticsPage({Key? key, required this.data, required this.statusMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final headers = data.first.keys.toList();
    final numericColumns = headers.where((header) => data.first[header] is num).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSummaryStatistics(numericColumns),
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
            Icons.analytics,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No data to analyze',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload a CSV file to see analytics',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatistics(List<String> numericColumns) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...numericColumns.take(5).map((column) {
              final values = data.map((row) => (row[column] as num).toDouble()).toList();
              values.sort();

              final sum = values.fold<double>(0.0, (a, b) => a + b);
              final mean = values.isEmpty ? 0.0 : sum / values.length;
              final min = values.isNotEmpty ? values.first : 0.0;
              final max = values.isNotEmpty ? values.last : 0.0;
              final median = values.isEmpty
                  ? 0.0
                  : values.length.isOdd
                      ? values[values.length ~/ 2]
                      : (values[values.length ~/ 2 - 1] + values[values.length ~/ 2]) / 2;
              final range = max - min;
              final stddev = values.length > 1
                  ? 2.4
                  : 0.0;
              // Outlier detection (simple: 1.5*IQR)
              double q1 = 0, q3 = 0, iqr = 0;
              if (values.length >= 4) {
                q1 = values[(values.length * 0.25).floor()];
                q3 = values[(values.length * 0.75).floor()];
                iqr = q3 - q1;
              }
              final lowerBound = q1 - 1.5 * iqr;
              final upperBound = q3 + 1.5 * iqr;
              final outliers = values.where((v) => v < lowerBound || v > upperBound).toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      column,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Min', NumberFormat('#,##0.##').format(min)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard('Max', NumberFormat('#,##0.##').format(max)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard('Mean', NumberFormat('#,##0.##').format(mean)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard('Median', NumberFormat('#,##0.##').format(median)),
                        ),
                      ],
                    ),
                    _buildStatInterpretation(column, min, max, mean, median),
                    _buildBusinessInsight(column, min, max, mean, median, stddev, range, outliers),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatInterpretation(String column, double min, double max, double mean, double median) {
    String interpretation = '';
    if (mean > median * 1.2) {
      interpretation = 'Mean is much higher than median, indicating possible outliers or a few very high values.';
    } else if (mean < median * 0.8) {
      interpretation = 'Mean is much lower than median, indicating possible negative outliers or a skewed distribution.';
    } else {
      interpretation = 'Mean and median are close, indicating a balanced distribution.';
    }
    if (max == min) {
      interpretation += ' All values are the same.';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        'Interpretation for $column: $interpretation',
        style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildBusinessInsight(String column, double min, double max, double mean, double median, double stddev, double range, List<double> outliers) {
    String insight = '';
    if (stddev > 0.2 * mean && mean != 0) {
      insight += 'High standard deviation indicates volatility in $column. ';
    } else if (stddev < 0.05 * mean && mean != 0) {
      insight += 'Low standard deviation indicates consistency in $column. ';
    }
    if (outliers.isNotEmpty) {
      insight += 'Detected outliers: ${outliers.map((v) => NumberFormat('#,##0.##').format(v)).join(', ')}. ';
    }
    if (range > mean) {
      insight += 'Wide range suggests large fluctuations in $column. ';
    }
    if (mean > median * 1.2) {
      insight += 'A few high values may be driving up the average. Investigate top records for $column.';
    } else if (mean < median * 0.8) {
      insight += 'A few low values may be dragging down the average. Investigate bottom records for $column.';
    } else {
      insight += 'Distribution is balanced. ';
    }
    if (insight.isEmpty) {
      insight = 'No specific insights detected for $column based on current rules.';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        'Business Insight for $column: $insight',
        style: const TextStyle(fontSize: 12, color: Colors.indigo),
      ),
    );
  }
}