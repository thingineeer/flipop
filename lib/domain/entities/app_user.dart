enum SignInProvider { anonymous, google, apple }

class AppUser {
  final String uid;
  final String? email;
  final SignInProvider provider;
  final String? nickname;
  final String? avatarId;

  const AppUser({
    required this.uid,
    this.email,
    required this.provider,
    this.nickname,
    this.avatarId,
  });

  bool get isAnonymous => provider == SignInProvider.anonymous;
  bool get isLinked => provider != SignInProvider.anonymous;
  bool get hasProfile => nickname != null && nickname!.isNotEmpty;

  AppUser copyWith({
    String? uid,
    String? email,
    SignInProvider? provider,
    String? nickname,
    String? avatarId,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      provider: provider ?? this.provider,
      nickname: nickname ?? this.nickname,
      avatarId: avatarId ?? this.avatarId,
    );
  }
}
