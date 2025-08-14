

import 'package:flutter/material.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';


class FinancialAnalyticsScreen extends StatefulWidget {
  const FinancialAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<FinancialAnalyticsScreen> createState() => _FinancialAnalyticsScreenState();
}

class _FinancialAnalyticsScreenState extends State<FinancialAnalyticsScreen> {
  bool _isLoading = true;
  Webview? _webview;

  @override
  void initState() {
    super.initState();
    _openWebView();
  }

  Future<void> _openWebView() async {
    setState(() => _isLoading = true);
    final webview = await WebviewWindow.create(
      configuration: CreateConfiguration(
        title: "Financial Analytics",
        titleBarTopPadding: 0,
      ),
    );
    webview
      ..setBrightness(Brightness.dark)
      ..setApplicationNameForUserAgent(" WebviewExample/1.0.0")
      ..launch("https://financial-analytics-platform-823645413328.us-central1.run.app")
      ..addOnUrlRequestCallback((url) {
        debugPrint('url requested: $url');
      })
      ..onClose.whenComplete(() {
        if (mounted) {
          setState(() => _webview = null);
        }
      });
    setState(() => _isLoading = false);
    _webview = webview;
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _webview?.reload(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analytics'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_webview != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _webview?.reload(),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Stack(
        children: [
          // WebView with your ML service
          if (_webview == null)
            Center(
              child: ElevatedButton(
                onPressed: _openWebView,
                child: const Text("Open Financial Analytics"),
              ),
            ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading AI Financial Analytics...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '🤖 Preparing ML models and dashboard',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // Optional: Help button
      floatingActionButton: FloatingActionButton(
        onPressed: _showHelp,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.help, color: Colors.white),
        tooltip: 'How to use',
      ),
    );
  }

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Financial Analytics Help',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Features
            const Text(
              'What you can do:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _buildFeatureItem(
              Icons.upload_file,
              'Upload Data',
              'Drop CSV, JSON, or Excel files to analyze',
              Colors.blue,
            ),
            _buildFeatureItem(
              Icons.psychology,
              'AI Insights',
              'Get intelligent analysis and recommendations',
              Colors.green,
            ),
            _buildFeatureItem(
              Icons.trending_up,
              'Forecasting',
              '98.4% accurate revenue and expense predictions',
              Colors.orange,
            ),
            _buildFeatureItem(
              Icons.warning,
              'Anomaly Detection',
              'Identify unusual patterns in your data',
              Colors.red,
            ),
            _buildFeatureItem(
              Icons.bar_chart,
              'Visualizations',
              'Interactive charts and detailed reports',
              Colors.purple,
            ),

            const SizedBox(height: 20),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Start Analyzing', style: TextStyle(fontSize: 16)),
              ),
            ),

            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example usage in your app:
/*
// 1. Add to pubspec.yaml:
dependencies:
  desktop_webview_window: ^0.2.4 // Check for the latest version

// 2. Use in your app:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FinancialAnalyticsScreen(),
  ),
);

// 3. Or add to bottom navigation:
BottomNavigationBarItem(
  icon: Icon(Icons.analytics),
  label: 'Analytics',
),
*/
