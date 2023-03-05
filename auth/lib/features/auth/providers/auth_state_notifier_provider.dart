import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_practice/features/auth/models/auth_state.dart';
import 'package:instagram_practice/features/auth/notifiers/auth_controller.dart';
import 'package:instagram_practice/features/auth/repository/auth_ripository.dart';
import 'package:instagram_practice/features/user/repository/user_info_storage.dart';

final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final userInfoStorage = ref.watch(userInfoStorageRepositoryProvider);
    return AuthStateNotifier(
      authRepository: authRepository,
      userInfoStorageRepository: userInfoStorage,
    );
  },
);
