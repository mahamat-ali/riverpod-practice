import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_practice/features/auth/models/auth_result.dart';
import 'package:instagram_practice/features/auth/models/auth_state.dart';
import 'package:instagram_practice/features/auth/repository/auth_ripository.dart';
import 'package:instagram_practice/features/user/repository/user_info_storage.dart';
import 'package:instagram_practice/shared/stypedefs/user_id.dart';



class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final UserInfoStorageRepository userInfoStorageRepository;

  AuthStateNotifier({
    required this.userInfoStorageRepository,
    required this.authRepository,
  }) : super(const AuthState.unknown()) {
    if (authRepository.isAlreadyLoggedIn) {
      state = AuthState(
        result: AuthResult.success,
        isLoading: false,
        userId: authRepository.userId,
      );
    }
  }

  Future<void> logOut() async {
    state = state.copiedWithIsLoading(true);
    await authRepository.logOut();
    state = const AuthState.unknown();
  }

  Future<void> loginWithGoogle() async {
    state = state.copiedWithIsLoading(true);
    final result = await authRepository.loginWithGoogle();
    final userId = authRepository.userId;
    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(userId: userId);
    }
    state = AuthState(
      result: result,
      isLoading: false,
      userId: authRepository.userId,
    );
  }

  Future<void> loginWithFacebook() async {
    state = state.copiedWithIsLoading(true);
    final result = await authRepository.loginWithFacebook();
    final userId = authRepository.userId;
    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(userId: userId);
    }
    state = AuthState(
      result: result,
      isLoading: false,
      userId: authRepository.userId,
    );
  }

  Future<void> saveUserInfo({
    required UserId userId,
  }) =>
      userInfoStorageRepository.saveUserInfo(
        userId: userId,
        displayName: authRepository.displayName,
        email: authRepository.email,
      );
}
