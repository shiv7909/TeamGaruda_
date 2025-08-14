import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_evolve/Today/HomePage.dart';
import 'package:project_evolve/Today/loginView2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://tzozyfpevetkjansgaoi.supabase.co',
      anonKey:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6b3p5ZnBldmV0a2phbnNnYW9pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNjYzOTYsImV4cCI6MjA3MDY0MjM5Nn0.frt0UNJecHbaFDuIpropFojsyk97cmY0rhYh6utD79A',
    );
    // Get.put(EmailSendService());
    // Get.put(MemberService());
  } catch (e) {
    print('Failed to initialize Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'College Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: session != null ? '/' : '/login',
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: '/login', page: () => const LoginPage()),
      ],
    );
  }
}

