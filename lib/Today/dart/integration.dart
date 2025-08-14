import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Enum for supported integrations
enum IntegrationType { hubspot }

class HubSpotPage extends StatefulWidget {
  const HubSpotPage({super.key});

  @override
  State<HubSpotPage> createState() => _HubSpotPageState();
}

class _HubSpotPageState extends State<HubSpotPage> {
  IntegrationType? _selectedIntegration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integrations')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select an Integration:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: [
                ChoiceChip(
                  label: const Text('HubSpot'),
                  selected: _selectedIntegration == IntegrationType.hubspot,
                  onSelected: (_) =>
                      setState(() => _selectedIntegration = IntegrationType.hubspot),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_selectedIntegration != null)
              Expanded(
                child: IntegrationConnector(
                  integrationType: _selectedIntegration!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class IntegrationConnector extends StatefulWidget {
  final IntegrationType integrationType;
  const IntegrationConnector({super.key, required this.integrationType});

  @override
  State<IntegrationConnector> createState() => _IntegrationConnectorState();
}

class _IntegrationConnectorState extends State<IntegrationConnector> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isConnected = false;
  bool _isLoading = false;
  String _status = '';
  List<dynamic> _retrievedData = [];
  bool _showSuccess = false;

  Future<void> _connect() async {
    setState(() {
      _isLoading = true;
      _status = 'Connecting...';
      _showSuccess = false;
    });

    if (_apiKeyController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _status = 'API key required.';
        _isConnected = false;
        _showSuccess = false;
      });
      return;
    }

    try {
      // Send the API key to the backend for validation
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/api/hubspot/connect'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'api_key': _apiKeyController.text}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isConnected = true;
          _showSuccess = true;
          _status = 'Successfully integrated the app!';
        });
      } else {
        setState(() {
          final errorData = json.decode(response.body);
          _status = 'Connection failed: ${errorData['error']}';
          _isConnected = false;
          _showSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error connecting: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _status = 'Fetching data...';
      _retrievedData = [];
    });
    try {
      if (widget.integrationType == IntegrationType.hubspot) {
        final response = await http.get(
          Uri.parse('http://127.0.0.1:5000/api/hubspot/get-contacts'),
        );
        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          setState(() {
            _retrievedData = result;
            _status = 'Fetched ${_retrievedData.length} contacts.';
          });
        } else {
          setState(() {
            _status = 'Failed to fetch data. Status: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Connect to ${widget.integrationType.name.toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (!_isConnected && !_showSuccess) ...[
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isConnected && !_isLoading,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _connect,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Connect'),
              ),
            ],
            // Always show status message if not loading, or if error
            if (_status.isNotEmpty && (!_isLoading || (!_showSuccess && !_isConnected)))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _status,
                  style: TextStyle(
                    color: _showSuccess
                        ? Colors.green
                        : (_status.toLowerCase().contains('error') || _status.toLowerCase().contains('fail'))
                            ? Colors.red
                            : Colors.black,
                    fontWeight: _showSuccess ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_showSuccess) ...[
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status,
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchData,
                icon: const Icon(Icons.download),
                label: const Text('Get Data'),
              ),
            ],
            const SizedBox(height: 16),
            if (_isLoading && !_showSuccess)
              const Center(child: CircularProgressIndicator()),
            if (_retrievedData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _retrievedData.length,
                  itemBuilder: (context, index) {
                    final contact = _retrievedData[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          '${contact['firstname'] ?? 'N/A'} ${contact['lastname'] ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Email: ${contact['email'] ?? 'N/A'}\nCompany: ${contact['company'] ?? 'N/A'}',
                        ),
                      ),
                    );
                  },
                ),
              )
            else if (_showSuccess && !_isLoading && _retrievedData.isEmpty)
              const Expanded(
                child: Center(child: Text('No data to display.')),
              ),
          ],
        ),
      ),
    );
  }
}