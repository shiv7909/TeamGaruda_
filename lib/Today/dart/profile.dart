

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _client
          .from('businesses')
          .select('business_name, business_type, contact_person, phone_number')
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}





class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _supabaseService.fetchUserProfile();
      setState(() {
        _userData = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _supabaseService.signOut();
    // Navigate to a login or welcome screen after signing out
    // Example: Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      )
          : _userData == null
          ? const Center(
        child: Text(
          'No profile data found. Please complete your registration.',
          textAlign: TextAlign.center,
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.business, size: 50),
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                icon: Icons.badge,
                label: 'Business Name',
                value: _userData!['business_name'] ?? 'N/A',
              ),
              _buildInfoCard(
                icon: Icons.category,
                label: 'Business Type',
                value: _userData!['business_type'] ?? 'N/A',
              ),
              _buildInfoCard(
                icon: Icons.person,
                label: 'Contact Person',
                value: _userData!['contact_person'] ?? 'N/A',
              ),
              _buildInfoCard(
                icon: Icons.phone,
                label: 'Phone Number',
                value: _userData!['phone_number'] ?? 'N/A',
              ),
              const SizedBox(height: 24),
              const Text(
                'Other Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              _buildOptionTile(
                icon: Icons.support,
                title: 'Support',
                onTap: () {
                  // Navigate to a support page
                },
              ),
              _buildOptionTile(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  // Navigate to a settings page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String value}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}