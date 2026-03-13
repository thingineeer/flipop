// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'FLIPOP';

  @override
  String get welcomeCharacters => 'かわいいキャラと一緒に！';

  @override
  String get welcomeDescription => 'ブロックをタップして色を変えて、\n一列を完成させよう！';

  @override
  String get welcomeCompete => '世界中のプレイヤーと競争！';

  @override
  String get welcomeCompeteDesc => 'ログインするとスコアが保存され\n世界ランキングに参加できます！';

  @override
  String get welcomeAccountHint => 'アカウントを連携すると\nアプリを削除しても記録が残ります';

  @override
  String get welcomeStart => '今すぐ始めよう！';

  @override
  String get signInApple => 'Appleで始める';

  @override
  String get signInGoogle => 'Googleで始める';

  @override
  String get orDivider => 'または';

  @override
  String get signInGuest => 'ログインなしで始める';

  @override
  String get signInLaterHint => '設定からいつでもログインできます';

  @override
  String get startNow => '今すぐスタート';

  @override
  String get loginBenefitHint => 'ログインすると記録が保存され、ランキングに参加できます！';

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
    return '新しい列まで$remainingターン';
  }

  @override
  String comboDisplay(int combo) {
    return 'COMBO x$combo';
  }

  @override
  String get tapHint => 'タップすると周りの色が変わる！一列を同じ色に 🎯';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get newBest => '🎉 NEW BEST!';

  @override
  String get continueWithAd => '続ける（広告）';

  @override
  String get timeBonus => '時間 +30秒（広告）';

  @override
  String get scoreDouble => 'スコア2倍（広告）';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get setNickname => 'ニックネームを決めよう！';

  @override
  String get nicknameHint => 'ニックネーム（2〜12文字）';

  @override
  String get nicknameTaken => 'このニックネームは既に使われています';

  @override
  String get noRecords => 'まだ記録がありません！';

  @override
  String myRank(int rank) {
    return '自分の順位: #$rank';
  }

  @override
  String get settings => '設定';

  @override
  String get notLoggedIn => '未ログイン';

  @override
  String get googleAccount => 'Googleアカウント';

  @override
  String get appleAccount => 'Appleアカウント';

  @override
  String get guest => 'ゲスト';

  @override
  String get accountLinkHint => 'ソーシャルアカウントを連携すると\nアプリを削除してもアカウントが維持されます';

  @override
  String get linkAccount => 'アカウント連携';

  @override
  String get linkGoogle => 'Googleで連携';

  @override
  String get linkApple => 'Appleで連携';

  @override
  String get changeCountry => '国を変更';

  @override
  String get logout => 'ログアウト';

  @override
  String get deleteAccount => 'アカウント削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get change => '変更';

  @override
  String get delete => '削除';

  @override
  String get logoutTitle => 'ログアウト';

  @override
  String get logoutMessage =>
      'ログアウトするとゲストとして新しいセッションが始まります。\nソーシャルログインで再び戻ることができます。';

  @override
  String get deleteTitle => 'アカウント削除';

  @override
  String get deleteMessage =>
      'アカウントを削除すると、すべてのゲームデータと\nランキング記録が永久に削除されます。\n\nこの操作は元に戻せません。';

  @override
  String get countryChanged => '国が変更されました';

  @override
  String get googleLinked => 'Googleアカウントが連携されました';

  @override
  String get appleLinked => 'Appleアカウントが連携されました';

  @override
  String get tutorialTapTitle => 'ブロックをタップ！';

  @override
  String get tutorialTapDesc => 'タップすると上下左右のブロックが\n次の色に変わります';

  @override
  String get tutorialTapHint => 'タップ → 周り4マスが次の色に！';

  @override
  String get tutorialClearTitle => '一列完成！';

  @override
  String get tutorialClearDesc => '横一列を同じ色で\n揃えるとクリア！';

  @override
  String get tutorialComboTitle => '連鎖コンボ！';

  @override
  String get tutorialComboDesc => 'クリア後にブロックが落ちて\n連鎖すると大量スコア！';

  @override
  String get tutorialNext => '次へ';

  @override
  String get tutorialStart => 'スタート！';

  @override
  String get moreTitle => 'その他';

  @override
  String get gameSection => 'ゲーム';

  @override
  String get ranking => 'ランキング';

  @override
  String get accountSection => 'アカウント';

  @override
  String get infoSection => '情報';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get appVersion => 'アプリバージョン';

  @override
  String get avatarPicker => 'アバター選択';

  @override
  String get avatarBasic => '基本';

  @override
  String get avatarExtra => '追加';

  @override
  String get avatarSpecial => '特別';

  @override
  String get save => '保存';

  @override
  String get avatarChanged => 'アバターが変更されました';

  @override
  String saveFailed(String error) {
    return '変更失敗: $error';
  }

  @override
  String get comingSoon => 'COMING\nSOON';

  @override
  String googleSignInFailed(String error) {
    return 'Googleログイン失敗: $error';
  }

  @override
  String appleSignInFailed(String error) {
    return 'Appleログイン失敗: $error';
  }
}
