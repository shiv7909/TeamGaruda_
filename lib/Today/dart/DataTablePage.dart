


// data_table_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DataTablePage extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String statusMessage;

  const DataTablePage({Key? key, required this.data, required this.statusMessage}) : super(key: key);

  @override
  State<DataTablePage> createState() => _DataTablePageState();
}

class _DataTablePageState extends State<DataTablePage> {
  String? _selectedChartColumn;

  @override
  void initState() {
    super.initState();
    if (widget.data.isNotEmpty) {
      final numericColumns = widget.data.first.keys.where((header) {
        final value = widget.data.first[header];
        return value is num;
      }).toList();
      _selectedChartColumn = numericColumns.isNotEmpty ? numericColumns[0] : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    final headers = widget.data.first.keys.toList();
    final numericColumns = headers.where((header) => widget.data.first[header] is num).toList();
    final timeColumns = headers.where((header) => ['Date', 'Quarter', 'Month'].contains(header)).toList();
    final xColumn = timeColumns.isNotEmpty ? timeColumns[0] : null;

    final _dataSource = _DataSource(
      data: widget.data,
      headers: headers,
    );

    List<DataColumn> dataColumns = headers
        .map((key) => DataColumn(
      label: Text(
        key,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ))
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Data Table',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${widget.data.length} rows × ${headers.length} columns',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          _buildDynamicChart(numericColumns, xColumn),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PaginatedDataTable(
              header: const Text('All Records'),
              columns: dataColumns,
              source: _dataSource,
              rowsPerPage: 10,
              availableRowsPerPage: const [10, 20, 50],
            ),
          ),
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
            Icons.table_chart,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No data to display',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload a CSV file to see the data table',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicChart(List<String> numericColumns, String? xColumn) {
    if (numericColumns.isEmpty) return const SizedBox.shrink();

    List<FlSpot> spots = [];
    final yColumn = _selectedChartColumn ?? numericColumns.first;

    for (int i = 0; i < widget.data.length; i++) {
      final yValue = (widget.data[i][yColumn] as num?);
      if (yValue != null) {
        spots.add(FlSpot(i.toDouble(), yValue.toDouble()));
      }
    }

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Chart for: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedChartColumn,
                  items: numericColumns.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedChartColumn = newValue;
                    });
                  },
                ),
              ],
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
                          if (xColumn != null && index >= 0 && index < widget.data.length) {
                            return Text(
                              widget.data[index][xColumn].toString(),
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            );
                          } else if (index >= 0 && index < widget.data.length) {
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

// Helper class for PaginatedDataTable
class _DataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final List<String> headers;

  _DataSource({required this.data, required this.headers});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final row = data[index];
    return DataRow.byIndex(
      index: index,
      cells: headers.map((header) {
        final value = row[header];
        String displayValue;

        if (value is num) {
          displayValue = NumberFormat('#,##0.##').format(value);
        } else {
          displayValue = value?.toString() ?? '';
        }

        return DataCell(Text(displayValue));
      }).toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}