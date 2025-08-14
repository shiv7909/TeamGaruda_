

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart

class AIForcastingPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String statusMessage;
  final String apiKey; // Changed from openAIApiKey to apiKey

  const AIForcastingPage({
    Key? key,
    required this.data,
    required this.statusMessage,
    required this.apiKey, // Changed from openAIApiKey to apiKey
  }) : super(key: key);

  @override
  State<AIForcastingPage> createState() => _AIForcastingPageState();
}

class _AIForcastingPageState extends State<AIForcastingPage> {
  final _promptController = TextEditingController();
  String _aiResponse = '';
  bool _isLoading = false;
  List<FlSpot> _historicalSpots = [];
  List<FlSpot> _forecastSpots = [];

  // API endpoint for Gemini
  final String _geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  // State variable to store the selected column for forecasting
  String? _selectedColumn;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  // New method to generate a forecasting prompt for the AI
  String _generateForecastingPrompt(String column) {
    // Get the last 10 data points for the selected column to provide context
    final recentData = widget.data
        .sublist(
        widget.data.length > 10 ? widget.data.length - 10 : 0,
        widget.data.length)
        .map((row) => row[column])
        .toList();

    return 'Based on the following time series data points for "$column":\n'
        '${recentData.join(", ")}\n\n'
        'Please analyze the trend and provide a forecast for the next 5 periods. '
        'Output the forecast as a comma-separated list of numbers. Do not include any other text.';
  }

  // New method to fetch forecast from Gemini API
  Future<void> _fetchForecast() async {
    if (_selectedColumn == null || widget.data.isEmpty) {
      setState(() {
        _aiResponse = 'Please select a column and ensure data is loaded.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _aiResponse = 'Generating forecast...';
    });

    final prompt = _generateForecastingPrompt(_selectedColumn!);

    try {
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=${widget.apiKey}'), // Use widget.apiKey
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Adjust the path to the forecast text according to Gemini's response structure
        final String rawForecast = data['candidates'][0]['content']['parts'][0]['text'].toString().trim();
        final List<num> forecastValues = rawForecast
            .split(',')
            .map((e) => num.tryParse(e.trim()) ?? 0)
            .toList();

        // Combine historical and forecasted data for the chart
        final historicalValues = widget.data
            .map((row) => row[_selectedColumn!])
            .whereType<num>()
            .toList();

        _historicalSpots = historicalValues
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
            .toList();
        _forecastSpots = forecastValues.asMap().entries.map((e) =>
            FlSpot((historicalValues.length + e.key).toDouble(), e.value.toDouble())).toList();

        setState(() {
          _aiResponse = 'Forecast generated successfully.';
        });
      } else {
        setState(() {
          _aiResponse =
          'Error: ${response.statusCode} - ${response.reasonPhrase}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final hasData = widget.data.isNotEmpty;
    final columns = hasData ? widget.data.first.keys.toList() : [];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI-Powered Forecasting',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use AI to forecast future trends based on your uploaded data.',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 24),
          if (!hasData)
            Center(
              child: Text(
                'No data loaded. Please go to the Dashboard to upload a CSV file.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.redAccent),
              ),
            ),
          if (hasData) ...[
            // Dropdown to select the column for forecasting
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Column for Forecasting',
                border: OutlineInputBorder(),
              ),
              value: _selectedColumn,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedColumn = newValue;
                });
              },
              items: columns
                  .map<DropdownMenuItem<String>>( // Changed dynamic to String
                    (dynamic value) => DropdownMenuItem<String>(
                      value: value as String,
                      child: Text(value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchForecast,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.insights),
              label: Text(_isLoading ? 'Forecasting...' : 'Generate Forecast'),
            ),
            const SizedBox(height: 16),
            if (_aiResponse.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _aiResponse,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            const SizedBox(height: 24),
            // Display the fl_chart LineChart if data is available
            if (_historicalSpots.isNotEmpty || _forecastSpots.isNotEmpty)
              Container(
                height: 400,
                padding: const EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d), width: 1),
                    ),
                    lineBarsData: [
                      if (_historicalSpots.isNotEmpty)
                        LineChartBarData(
                          spots: _historicalSpots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      if (_forecastSpots.isNotEmpty)
                        LineChartBarData(
                          spots: _forecastSpots,
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          dashArray: [5, 5], // Dotted line
                          belowBarData: BarAreaData(show: false),
                        ),
                    ],
                    // Adding a title to the chart
                    lineTouchData: LineTouchData(
                      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) { return []; }, touchTooltipData: LineTouchTooltipData(getTooltipColor: (spot) => Colors.blueGrey.withOpacity(0.8)),
                    ),
                  ),
                )
              ),
          ],
        ],
      ),
    );
  }
}