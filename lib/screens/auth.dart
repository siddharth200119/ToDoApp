import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerWidget{
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseClient = Supabase.instance.client;
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Future<void> signInWithEmail() async {
      final String email = emailController.text;
      final String password = passwordController.text;

      try{
        final response = await supabaseClient.auth.signInWithPassword(
          email: email,
          password: password,
        );
        print(response);
        if(response.user != null && response.session != null){
          //set user and session in provider
          //redirect to home page
          Navigator.pushReplacementNamed(context, '/home');
        }else{
          //login not successful handle cases
        }

      }catch(e){
        if(e is AuthException){
          //handle auth exception
        }else{
          //handle general error (network, etc)
        }
      }
    }

    Future<void> signUpWithEmail() async {
      final String email = emailController.text;
      final String password = passwordController.text;

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.session != null) {
        // Update the session provider
      } else{
        print('Error logging in');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Supabase Auth'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: signInWithEmail,
              child: const Text('Sign In with Email'),
            ),
            ElevatedButton(
              onPressed: signUpWithEmail,
              child: const Text('Sign Up with Email'),
            ),
          ],
        ),
      ),
    );
  }
}