sealed class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

class AuthCancelled extends AuthFailure {
  const AuthCancelled() : super('로그인이 취소되었습니다');
}

class AuthNetworkError extends AuthFailure {
  const AuthNetworkError() : super('네트워크 연결을 확인해주세요');
}

class AuthCredentialAlreadyInUse extends AuthFailure {
  final String? email;
  const AuthCredentialAlreadyInUse({this.email})
      : super('이미 다른 계정에 연동된 소셜 계정입니다');
}

class AuthRequiresRecentLogin extends AuthFailure {
  const AuthRequiresRecentLogin() : super('보안을 위해 재로그인이 필요합니다');
}

class AuthUnknown extends AuthFailure {
  const AuthUnknown([String message = '알 수 없는 오류가 발생했습니다'])
      : super(message);
}
