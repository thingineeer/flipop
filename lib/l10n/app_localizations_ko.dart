// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'FLIPOP';

  @override
  String get welcomeCharacters => '귀여운 캐릭터와 함께!';

  @override
  String get welcomeDescription => '블록을 탭해서 색을 바꾸고,\n줄을 완성하세요!';

  @override
  String get welcomeCompete => '전 세계 플레이어와 경쟁!';

  @override
  String get welcomeCompeteDesc => '로그인하면 점수가 저장되고\n세계 랭킹에 참여!';

  @override
  String get welcomeAccountHint => '계정을 연동하면 앱을 삭제해도\n기록이 유지됩니다';

  @override
  String get welcomeStart => '지금 시작하세요!';

  @override
  String get signInApple => 'Apple로 시작';

  @override
  String get signInGoogle => 'Google로 시작';

  @override
  String get orDivider => '또는';

  @override
  String get signInGuest => '로그인 없이 시작하기';

  @override
  String get signInLaterHint => '나중에 설정에서 언제든 로그인할 수 있어요';

  @override
  String get startNow => '바로 시작하기';

  @override
  String get loginBenefitHint => '로그인하면 기록이 저장되고 랭킹에 참여할 수 있어요!';

  @override
  String get scoreLabel => 'SCORE';

  @override
  String get rankingLabel => 'RANKING';

  @override
  String get bestLabel => 'BEST';

  @override
  String get timeLabel => 'TIME';

  @override
  String turnsUntilNewRow(int remaining) {
    return '새 줄까지 $remaining턴';
  }

  @override
  String comboDisplay(int combo) {
    return 'COMBO x$combo';
  }

  @override
  String get tapHint => '탭하면 주변 색이 바뀌어요! 가로·세로 줄을 맞춰보세요 🎯';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get newBest => '🎉 NEW BEST!';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get setNickname => '닉네임을 정해주세요!';

  @override
  String get nicknameHint => '닉네임 (2~12자)';

  @override
  String get nicknameTaken => '이미 사용 중인 닉네임입니다';

  @override
  String get noRecords => '아직 기록이 없어요!';

  @override
  String myRank(int rank) {
    return '내 순위: #$rank';
  }

  @override
  String get settings => '설정';

  @override
  String get notLoggedIn => '로그인 안 됨';

  @override
  String get googleAccount => 'Google 계정';

  @override
  String get appleAccount => 'Apple 계정';

  @override
  String get guest => '게스트';

  @override
  String get accountLinkHint => '소셜 계정을 연동하면 앱을 삭제해도\n계정이 유지됩니다';

  @override
  String get linkAccount => '계정 연동';

  @override
  String get linkGoogle => 'Google로 연동';

  @override
  String get linkApple => 'Apple로 연동';

  @override
  String get changeCountry => '국가 변경';

  @override
  String get logout => '로그아웃';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get change => '변경';

  @override
  String get delete => '삭제';

  @override
  String get logoutTitle => '로그아웃';

  @override
  String get logoutMessage =>
      '로그아웃하면 게스트로 새 세션이 시작됩니다.\n소셜 로그인으로 다시 돌아올 수 있습니다.';

  @override
  String get deleteTitle => '계정 삭제';

  @override
  String get deleteMessage =>
      '계정을 삭제하면 모든 게임 데이터와\n랭킹 기록이 영구적으로 삭제됩니다.\n\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get countryChanged => '국가가 변경되었습니다';

  @override
  String get googleLinked => 'Google 계정이 연동되었습니다';

  @override
  String get appleLinked => 'Apple 계정이 연동되었습니다';

  @override
  String get tutorialTapTitle => '블록을 탭!';

  @override
  String get tutorialTapDesc => '탭하면 상하좌우 블록이\n다음 색으로 바뀌어요';

  @override
  String get tutorialTapHint => '탭 → 주변 4칸이 다음 색으로!';

  @override
  String get tutorialClearTitle => '줄 완성!';

  @override
  String get tutorialClearDesc => '가로 또는 세로 줄을 같은 색으로\n채우면 클리어!';

  @override
  String get tutorialComboTitle => '연쇄 콤보!';

  @override
  String get tutorialComboDesc => '클리어 후 블록이 떨어져서\n연쇄가 터지면 대박 점수!';

  @override
  String get tutorialNext => '다음';

  @override
  String get tutorialStart => '시작하기!';

  @override
  String get moreTitle => '더보기';

  @override
  String get gameSection => '게임';

  @override
  String get ranking => '랭킹';

  @override
  String get accountSection => '계정';

  @override
  String get infoSection => '정보';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get termsOfService => '이용약관';

  @override
  String get appVersion => '앱 버전';

  @override
  String get openSourceLicenses => '오픈소스 라이선스';

  @override
  String get avatarPicker => '아바타 선택';

  @override
  String get avatarBasic => '기본';

  @override
  String get avatarExtra => '추가';

  @override
  String get avatarSpecial => '특별';

  @override
  String get save => '저장';

  @override
  String get avatarChanged => '아바타가 변경되었습니다';

  @override
  String saveFailed(String error) {
    return '변경 실패: $error';
  }

  @override
  String get comingSoon => 'COMING\nSOON';

  @override
  String googleSignInFailed(String error) {
    return 'Google 로그인 실패: $error';
  }

  @override
  String appleSignInFailed(String error) {
    return 'Apple 로그인 실패: $error';
  }

  @override
  String get watchAd => '광고 보고\n해금';

  @override
  String get shareButton => '공유하기';

  @override
  String shareScore(int score) {
    return 'FLIPOP에서 $score점 달성했어요! 도전해보세요!';
  }

  @override
  String get tutorialPuzzleTapTitle => '탭의 효과';

  @override
  String get tutorialPuzzleTapDesc => '가운데 블록을 탭해서\n주변 색이 바뀌는 걸 확인하세요!';

  @override
  String get tutorialPuzzleTapSuccess => '잘했어요! 탭하면 주변이 바뀌어요!';

  @override
  String get tutorialPuzzleLineTitle => '줄 맞추기';

  @override
  String get tutorialPuzzleLineDesc => '블록을 탭해서\n가로줄을 같은 색으로 맞춰보세요!';

  @override
  String get tutorialPuzzleLineSuccess => '완벽해요! 줄 클리어 성공!';

  @override
  String get tutorialPuzzleComboTitle => '콤보 도전';

  @override
  String get tutorialPuzzleComboDesc => '연쇄 클리어를 만들어보세요!';

  @override
  String get tutorialPuzzleComboSuccess => '대단해요! 연쇄 콤보!';

  @override
  String get tutorialReady => '준비 완료!';

  @override
  String get guidedHint => '반짝이는 줄을 완성해보세요!';

  @override
  String get guidedStart => '준비됐나요? 게임 시작!';

  @override
  String get dailyChallenge => '데일리 챌린지';

  @override
  String get challengeTimeAttack => '타임어택';

  @override
  String get challengeLimitedMoves => '제한 터치';

  @override
  String get challengeComboMaster => '콤보 마스터';

  @override
  String get challengeSpeedRun => '스피드런';

  @override
  String get challengeNormal => '자유 모드';

  @override
  String attemptsLeft(int count) {
    return '남은 시도: $count회';
  }

  @override
  String get tryAgainTomorrow => '내일 다시 도전!';

  @override
  String movesLeft(int count) {
    return '남은 터치: $count';
  }

  @override
  String targetScore(int score) {
    return '목표: $score점';
  }

  @override
  String get noAttemptsLeft => '오늘 시도 횟수를 모두 사용했어요';

  @override
  String get soundMusic => '음악';

  @override
  String get soundSfx => '효과음';

  @override
  String get removeAds => '광고 제거';

  @override
  String get removeAdsPrice => '\$2.99';

  @override
  String get removeAdsDesc => '배너/전면 광고를 영구 제거합니다';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get adsRemoved => '광고 제거됨';

  @override
  String get purchaseFailed => '구매 실패';

  @override
  String get purchaseSection => '구매';

  @override
  String get avatarPack => '스페셜 아바타 팩';

  @override
  String get avatarPackPrice => '\$1.99';

  @override
  String get avatarPackOwned => '아바타 팩 보유 중';

  @override
  String get ui_darkMode => '다크 모드';

  @override
  String get ui_newBest => '신기록!';

  @override
  String get ui_settingsSection => '설정';

  @override
  String get social_inviteFriends => '친구 초대';

  @override
  String get social_inviteMessage => 'FLIPOP 같이 하자! 🎮';

  @override
  String get social_challengeMe => '이 점수 깰 수 있어?';

  @override
  String get infraForceUpdate => '업데이트 필요';

  @override
  String get infraForceUpdateDesc => '새 버전이 출시되었습니다. 업데이트 해주세요.';

  @override
  String get infraMaintenance => '점검 중';

  @override
  String get infraMaintenanceDesc => '더 좋은 서비스를 위해 점검 중입니다. 잠시만 기다려주세요.';

  @override
  String get infraUpdateButton => '업데이트';

  @override
  String get meta_achievements => '업적';

  @override
  String get meta_coins => '코인';

  @override
  String meta_coinReward(int amount) {
    return '+$amount 코인';
  }

  @override
  String get meta_achFirstStep => '첫 걸음';

  @override
  String get meta_achFirstStepDesc => '첫 게임 완료';

  @override
  String get meta_achTrainee => '연습생';

  @override
  String get meta_achTraineeDesc => '10게임 완료';

  @override
  String get meta_achFirstClear => '첫 클리어';

  @override
  String get meta_achFirstClearDesc => '첫 줄 클리어';

  @override
  String get meta_achComboIntro => '콤보 입문';

  @override
  String get meta_achComboIntroDesc => '콤보 x2 달성';

  @override
  String get meta_achTutorial => '튜토리얼 마스터';

  @override
  String get meta_achTutorialDesc => '튜토리얼 완료';

  @override
  String get meta_ach100 => '100점 클럽';

  @override
  String get meta_ach100Desc => '점수 100+ 달성';

  @override
  String get meta_ach500 => '500점 클럽';

  @override
  String get meta_ach500Desc => '점수 500+ 달성';

  @override
  String get meta_ach1000 => '1000점 클럽';

  @override
  String get meta_ach1000Desc => '점수 1000+ 달성';

  @override
  String get meta_achComboMaster => '콤보 마스터';

  @override
  String get meta_achComboMasterDesc => '콤보 x5 달성';

  @override
  String get meta_achChainReaction => '연쇄 반응';

  @override
  String get meta_achChainReactionDesc => '연쇄 3연속';

  @override
  String get meta_ach3000 => '3000점 돌파';

  @override
  String get meta_ach3000Desc => '점수 3000+ 달성';

  @override
  String get meta_achComboKing => '콤보 킹';

  @override
  String get meta_achComboKingDesc => '콤보 x10 달성';

  @override
  String get meta_achSurvivor => '타임 서바이버';

  @override
  String get meta_achSurvivorDesc => '한 게임에서 500점+ 달성';

  @override
  String get meta_achPerfect => '퍼펙트 게임';

  @override
  String get meta_achPerfectDesc => '10줄 이상 클리어';

  @override
  String get meta_achBombMaster => '폭탄 마스터';

  @override
  String get meta_achBombMasterDesc => '점수 3000+ 달성';

  @override
  String get meta_achShareKing => '공유왕';

  @override
  String get meta_achShareKingDesc => '5회 게임 플레이';

  @override
  String get meta_achTop100 => '글로벌 탑100';

  @override
  String get meta_achTop100Desc => '최고점수 2000+ 달성';

  @override
  String get meta_achChallenger => '챌린지 도전자';

  @override
  String get meta_achChallengerDesc => '7일 연속 접속';

  @override
  String get meta_achZoo => '동물원';

  @override
  String get meta_achZooDesc => '아바타 8종 해금';

  @override
  String get meta_achFullCollection => '풀 컬렉션';

  @override
  String get meta_achFullCollectionDesc => '아바타 12종 해금';

  @override
  String get tabGame => '게임';

  @override
  String get tabChallenge => '챌린지';

  @override
  String get tabRanking => '랭킹';

  @override
  String get tabMore => '더보기';

  @override
  String get errorNetwork => '네트워크 연결을 확인해주세요';

  @override
  String get errorLoginCancelled => '로그인이 취소되었습니다';

  @override
  String get errorGeneric => '일시적인 오류가 발생했습니다';

  @override
  String get errorPermission => '권한 오류가 발생했습니다';

  @override
  String get errorSaveFailed => '저장에 실패했습니다. 다시 시도해주세요';

  @override
  String get restoreComplete => '구매 복원이 완료되었습니다';

  @override
  String get labelStart => 'START';

  @override
  String get labelSkip => '건너뛰기';

  @override
  String get labelReset => '다시';

  @override
  String get labelMoves => '터치';

  @override
  String get labelDailyBonus => '데일리 보너스';

  @override
  String get labelCoins => '코인';

  @override
  String get labelBest => 'BEST';

  @override
  String get watchAdAndClaim => '광고 보고 받기';

  @override
  String get labelLater => '나중에';

  @override
  String get labelRanking => '랭킹';

  @override
  String get labelTap => '탭';

  @override
  String labelDay(int day) {
    return 'DAY $day';
  }
}
