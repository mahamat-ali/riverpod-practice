import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_practice/features/auth/providers/auth_state_notifier_provider.dart';
import 'package:instagram_practice/features/auth/providers/is_logged_in_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer(
        builder: (context, ref, child) {
          final isLoggedIn = ref.watch(isLoggedInProvider);
          if (isLoggedIn) {
            return const WelcomeScreen();
          } else {
            return const HomeScreen();
          }
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            return Column(
              children: [
                TextButton(
                  onPressed: ref.read(authStateNotifierProvider.notifier).loginWithGoogle,
                  child: const Text('Login With Google'),
                ),
                const SizedBox(height: 40),
                TextButton(
                  onPressed:
                      ref.read(authStateNotifierProvider.notifier).loginWithFacebook,
                  child: const Text('Login With Facebook'),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Screen'),
      ),
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            return Column(
              children: [
                TextButton(
                  onPressed: ref.read(authStateNotifierProvider.notifier).logOut,
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
