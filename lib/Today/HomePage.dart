import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:project_evolve/Today/sideMenu.dart';
import 'dart:io';


import 'dart/AIFOR_CHITRAGUOTHA.dart';
import 'dart/Aiforcasting.dart';
import 'dart/Analytics.dart';
import 'dart/DataTablePage.dart';
import 'dart/dashboard.dart'; // Ensure this import points to your dashboard.dart file
import 'dart/integration.dart';
import 'dart/profile.dart';
import 'homePage.dart'; // Assuming you have GetX in your project


class HomePage extends StatefulWidget {
  final int? initialPageId; // Optional initial page ID

  const HomePage({Key? key, this.initialPageId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int selectedPageId;
  bool _logoutDialogShown = false;

  // State variables for data loading and processing
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = false;
  String _statusMessage = 'Please upload a CSV file to begin analysis.';
  // Store your OpenAI API Key securely, ideally not directly in code for production
final String _openAIApiKey = "";

  @override
  void initState() {
    super.initState();
    selectedPageId = widget.initialPageId ?? 1;
  }

  // --- CSV Parsing and Data Handling Methods ---

  // This function runs on a separate Isolate to avoid blocking the UI thread.
  static List<Map<String, dynamic>> _parseCsvInBackground(String csvString) {
    List<List<dynamic>> rowsAsList = const CsvToListConverter(
      eol: '\n',
      fieldDelimiter: ',',
      textDelimiter: '"',
    ).convert(csvString);

    if (rowsAsList.length <= 1) {
      return [];
    }

    List<String> headers = rowsAsList.first.map((e) => e.toString().trim()).toList();
    List<List<dynamic>> dataRows = rowsAsList.sublist(1);

    List<Map<String, dynamic>> parsedData = [];
    for (var row in dataRows) {
      if (row.length == headers.length) {
        Map<String, dynamic> rowMap = {};
        for (int i = 0; i < headers.length; i++) {
          rowMap[headers[i]] = _cleanData(row[i]);
        }
        parsedData.add(rowMap);
      }
    }
    return parsedData;
  }

  static dynamic _cleanData(dynamic value) {
    if (value == null) return null;

    // Convert the value to string to handle both numeric and string inputs uniformly
    String stringValue = value.toString();

    if (stringValue.isEmpty) return null;

    String cleanString = stringValue.replaceAll(',', '').trim();

      if (cleanString.endsWith('M')) {
        return num.tryParse(cleanString.replaceAll('M', '')) != null
            ? (num.tryParse(cleanString.replaceAll('M', '')) ?? 0) * 1000000
            : stringValue; // Return original string if 'M' part is not a number
      }
      if (cleanString.endsWith('%')) {
        return num.tryParse(cleanString.replaceAll('%', '')) ?? stringValue; // Return original string if '%' part is not a number
      }
      // Try to parse as a number, if it fails, return the original cleaned string
      return num.tryParse(cleanString) ?? cleanString;
  }



  Future<void> _pickAndParseCsv() async {
    setState(() {
      _isLoading = true;
      _data = [];
      _statusMessage = 'Processing file...';
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String csvString = await file.readAsString();

        List<Map<String, dynamic>> parsedData = await compute(_parseCsvInBackground, csvString);

        if (mounted) {
          setState(() {
            _data = parsedData;
            _statusMessage = 'Data loaded successfully! ${parsedData.length} records found.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error loading file: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onMenuTap(int id) {
    setState(() {
      // Get.delete<MembershipPageController>(); // Uncomment if you are using this
      selectedPageId = id;
      _logoutDialogShown = false; // Reset dialog shown flag on new page select
    });
  }

  // --- Screen Navigation ---
  Widget _getScreen() {
    switch (selectedPageId) {
      case 1:
      // MainScreen is now DashboardPage which needs data to be passed
        return DashboardPage(
          data: _data,
          statusMessage: _statusMessage,
          onUploadTap: _pickAndParseCsv, // Pass the upload function
          onClearTap: () {
            setState(() {
              _data = [];
              _statusMessage = 'Please upload a CSV file to begin analysis.';
            });
          },
        );
      case 2:
        return DataTablePage(data: _data, statusMessage: _statusMessage);
      case 3:
        return AnalyticsPage(data: _data, statusMessage: _statusMessage);
      case 4:
        // Navigate to the new AI Forecasting Page
        return AIForcastingPage(
            data: _data,
            statusMessage: _statusMessage,
            apiKey: _openAIApiKey);
      case 5:
        return HubSpotPage();
      case 6:
        if (!_logoutDialogShown) {
          _logoutDialogShown = true;
        }
        return ProfilePage();
      case 7:
        return FinancialAnalyticsScreen(); // Navigate to Chitraguptha AI Page
      case 8:
        return Container();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout( // Make sure ResponsiveLayout is defined or imported correctly.
      content: _getScreen(),
      onMenuTap: _onMenuTap,
      selectedId: selectedPageId,
    );
  }
}

// Define ResponsiveLayout if it's not imported from another file.
// This is a placeholder; you should use your actual ResponsiveLayout widget.
class ResponsiveLayout extends StatelessWidget {
  final Widget content;
  final void Function(int)? onMenuTap;
  final int? selectedId;

  const ResponsiveLayout({
    Key? key,
    required this.content,
    this.onMenuTap,
    this.selectedId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a basic example. Your actual ResponsiveLayout might be more complex.
    return Scaffold(
      drawer: Drawer(
        child: SideMenu(
          onMenuTap: onMenuTap,
          selectedId: selectedId,
        ),
      ),
      body: Row(
        children: [
          // On larger screens, show the SideMenu permanently
          if (MediaQuery.of(context).size.width > 600)
            SizedBox(
                width: 250,
                child: SideMenu(onMenuTap: onMenuTap, selectedId: selectedId)),
          Expanded(child: content),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 💡 Add the helper classes below to make the above code work
// ─────────────────────────────────────────────────────────────
class MenuItemData {
  final int id;
  final String title;
  final IconData icon;

  const MenuItemData({required this.id, required this.title, required this.icon});
}
