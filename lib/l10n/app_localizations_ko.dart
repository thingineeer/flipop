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
  String get welcomeDescription => '블록을 탭해서 색을 바꾸고,\n한 줄을 완성하세요!';

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
  String get tapHint => '탭하면 주변 색이 바뀌어요! 한 줄을 같은 색으로 🎯';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get newBest => '🎉 NEW BEST!';

  @override
  String get continueWithAd => '이어하기 (광고)';

  @override
  String get timeBonus => '시간 +30초 (광고)';

  @override
  String get scoreDouble => '점수 2배 (광고)';

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
  String get tutorialClearTitle => '한 줄 완성!';

  @override
  String get tutorialClearDesc => '가로 한 줄을 같은 색으로\n채우면 클리어!';

  @override
  String get tutorialComboTitle => '연쇄 콤보!';

  @override
  String get tutorialComboDesc => '클리어 후 블록이 떨어져서\n연쇄가 터지면 대박 점수!';

  @override
  String get tutorialNext => '다음';

  @override
  String get tutorialStart => '시작하기!';
}
