import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRedirector extends StatefulWidget {
  const AuthRedirector({super.key});

  @override
  State<AuthRedirector> createState() {
    return _AuthRedirectorState();
  }
}

class _AuthRedirectorState extends State<AuthRedirector> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Session? session = Supabase.instance.client.auth.currentSession;
      // Navigate based on session existence
      if (session != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
