import 'package:flutter_test/flutter_test.dart';
import 'package:flipop/domain/entities/app_user.dart';
import 'package:flipop/domain/failures/auth_failure.dart';

void main() {
  group('AppUser', () {
    test('isAnonymous: anonymous provider', () {
      const user = AppUser(
        uid: 'test-uid',
        provider: SignInProvider.anonymous,
      );
      expect(user.isAnonymous, true);
      expect(user.isLinked, false);
      expect(user.hasProfile, false);
    });

    test('isLinked: google provider', () {
      const user = AppUser(
        uid: 'test-uid',
        email: 'test@gmail.com',
        provider: SignInProvider.google,
        nickname: 'tester',
        avatarId: 'cat',
      );
      expect(user.isAnonymous, false);
      expect(user.isLinked, true);
      expect(user.hasProfile, true);
    });

    test('isLinked: apple provider', () {
      const user = AppUser(
        uid: 'test-uid',
        provider: SignInProvider.apple,
      );
      expect(user.isAnonymous, false);
      expect(user.isLinked, true);
    });

    test('hasProfile: nickname이 있으면 true', () {
      const user = AppUser(
        uid: 'test-uid',
        provider: SignInProvider.anonymous,
        nickname: 'player',
        avatarId: 'cat',
      );
      expect(user.hasProfile, true);
    });

    test('hasProfile: nickname이 빈 문자열이면 false', () {
      const user = AppUser(
        uid: 'test-uid',
        provider: SignInProvider.anonymous,
        nickname: '',
      );
      expect(user.hasProfile, false);
    });

    test('hasProfile: nickname이 null이면 false', () {
      const user = AppUser(
        uid: 'test-uid',
        provider: SignInProvider.anonymous,
      );
      expect(user.hasProfile, false);
    });

    test('copyWith: 부분 업데이트', () {
      const user = AppUser(
        uid: 'test-uid',
        provider: SignInProvider.anonymous,
      );
      final updated = user.copyWith(
        nickname: 'newName',
        provider: SignInProvider.google,
      );
      expect(updated.uid, 'test-uid');
      expect(updated.nickname, 'newName');
      expect(updated.provider, SignInProvider.google);
    });
  });

  group('AuthFailure', () {
    test('AuthCancelled message', () {
      const failure = AuthCancelled();
      expect(failure.message, '로그인이 취소되었습니다');
    });

    test('AuthNetworkError message', () {
      const failure = AuthNetworkError();
      expect(failure.message, '네트워크 연결을 확인해주세요');
    });

    test('AuthCredentialAlreadyInUse message + email', () {
      const failure = AuthCredentialAlreadyInUse(email: 'test@test.com');
      expect(failure.message, '이미 다른 계정에 연동된 소셜 계정입니다');
      expect(failure.email, 'test@test.com');
    });

    test('AuthRequiresRecentLogin message', () {
      const failure = AuthRequiresRecentLogin();
      expect(failure.message, '보안을 위해 재로그인이 필요합니다');
    });

    test('AuthUnknown default message', () {
      const failure = AuthUnknown();
      expect(failure.message, '알 수 없는 오류가 발생했습니다');
    });

    test('AuthUnknown custom message', () {
      const failure = AuthUnknown('커스텀 에러');
      expect(failure.message, '커스텀 에러');
    });

    test('sealed class exhaustive switch', () {
      const AuthFailure failure = AuthCancelled();
      final result = switch (failure) {
        AuthCancelled() => 'cancelled',
        AuthNetworkError() => 'network',
        AuthCredentialAlreadyInUse() => 'credential',
        AuthRequiresRecentLogin() => 'recent-login',
        AuthUnknown() => 'unknown',
      };
      expect(result, 'cancelled');
    });
  });
}
