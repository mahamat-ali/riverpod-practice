import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_practice/features/user/models/user_info_payload.dart';
import 'package:instagram_practice/shared/constants/firebase_collection_name.dart.dart';
import 'package:instagram_practice/shared/constants/firebase_field_name.dart';
import 'package:instagram_practice/shared/stypedefs/user_id.dart';

final userInfoStorageRepositoryProvider = Provider((ref) {
  return UserInfoStorageRepository(
    firebaseFirestoreInstance: FirebaseFirestore.instance,
  );
});

@immutable
class UserInfoStorageRepository {
  final FirebaseFirestore firebaseFirestoreInstance;

  const UserInfoStorageRepository({
    required this.firebaseFirestoreInstance,
  });

  Future<bool> saveUserInfo({
    required UserId userId,
    required String displayName,
    required String? email,
  }) async {
    try {
      // first check if we have this user's info from before
      final userInfo = await firebaseFirestoreInstance
          .collection(
            FirebaseCollectionName.users,
          )
          .where(
            FirebaseFieldName.userId,
            isEqualTo: userId,
          )
          .limit(1)
          .get();

      if (userInfo.docs.isNotEmpty) {
        // we already have this user's profile, save the new data instead
        await userInfo.docs.first.reference.update({
          FirebaseFieldName.displayName: displayName,
          FirebaseFieldName.email: email ?? '',
        });
        return true;
      }

      final payload = UserInfoPayload(
        userId: userId,
        displayName: displayName,
        email: email,
      );
      await firebaseFirestoreInstance
          .collection(
            FirebaseCollectionName.users,
          )
          .add(payload);
      return true;
    } catch (_) {
      return false;
    }
  }
}
