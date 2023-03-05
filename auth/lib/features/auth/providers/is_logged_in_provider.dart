import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_practice/features/auth/providers/auth_state_notifier_provider.dart';

final isLoggedInProvider = Provider<bool>((ref) {
  final userId = ref.watch(authStateNotifierProvider);
  return userId.userId != null;
});
