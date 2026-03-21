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
  String get welcomeDescription => 'ブロックをタップして色を変えて、\nラインを完成させよう！';

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
  String get tapHint => 'タップすると周りの色が変わる！縦横のラインを揃えよう 🎯';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get newBest => '🎉 NEW BEST!';

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
  String get tutorialClearTitle => 'ライン完成！';

  @override
  String get tutorialClearDesc => '横または縦のラインを同じ色で\n揃えるとクリア！';

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
  String get openSourceLicenses => 'オープンソースライセンス';

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

  @override
  String get watchAd => '広告を見て\n解除';

  @override
  String get shareButton => 'シェア';

  @override
  String shareScore(int score) {
    return 'FLIPOPで$score点達成！挑戦してみて！';
  }

  @override
  String get tutorialPuzzleTapTitle => 'タップの効果';

  @override
  String get tutorialPuzzleTapDesc => '真ん中のブロックをタップして\n周りの色が変わるのを確認！';

  @override
  String get tutorialPuzzleTapSuccess => 'よくできました！タップで周りが変わる！';

  @override
  String get tutorialPuzzleLineTitle => 'ライン揃え';

  @override
  String get tutorialPuzzleLineDesc => 'ブロックをタップして\n横ラインを同じ色に揃えよう！';

  @override
  String get tutorialPuzzleLineSuccess => '完璧！ラインクリア成功！';

  @override
  String get tutorialPuzzleComboTitle => 'コンボに挑戦';

  @override
  String get tutorialPuzzleComboDesc => '連鎖クリアを作ってみよう！';

  @override
  String get tutorialPuzzleComboSuccess => 'すごい！連鎖コンボ！';

  @override
  String get tutorialReady => '準備完了！';

  @override
  String get guidedHint => '光っているラインを完成させよう！';

  @override
  String get guidedStart => '準備はいい？ゲームスタート！';

  @override
  String get dailyChallenge => 'デイリーチャレンジ';

  @override
  String get challengeTimeAttack => 'タイムアタック';

  @override
  String get challengeLimitedMoves => '限定タッチ';

  @override
  String get challengeComboMaster => 'コンボマスター';

  @override
  String get challengeSpeedRun => 'スピードラン';

  @override
  String get challengeNormal => 'フリーモード';

  @override
  String attemptsLeft(int count) {
    return '残り$count回';
  }

  @override
  String get tryAgainTomorrow => '明日また挑戦しよう！';

  @override
  String movesLeft(int count) {
    return '残りタッチ: $count';
  }

  @override
  String targetScore(int score) {
    return '目標: $score点';
  }

  @override
  String get noAttemptsLeft => '今日の挑戦回数を使い切りました';

  @override
  String get soundMusic => '音楽';

  @override
  String get soundSfx => '効果音';

  @override
  String get removeAds => '広告を削除';

  @override
  String get removeAdsPrice => '\$2.99';

  @override
  String get removeAdsDesc => 'バナー・インタースティシャル広告を永久に削除します';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get adsRemoved => '広告削除済み';

  @override
  String get purchaseFailed => '購入に失敗しました';

  @override
  String get purchaseSection => '購入';

  @override
  String get avatarPack => 'スペシャルアバターパック';

  @override
  String get avatarPackPrice => '\$1.99';

  @override
  String get avatarPackOwned => 'アバターパック保有中';

  @override
  String get ui_darkMode => 'ダークモード';

  @override
  String get ui_newBest => '新記録!';

  @override
  String get ui_settingsSection => '設定';

  @override
  String get social_inviteFriends => '友達を招待';

  @override
  String get social_inviteMessage => 'FLIPOPやろう！🎮';

  @override
  String get social_challengeMe => 'この点数超えられる？';

  @override
  String get infraForceUpdate => 'アップデート必要';

  @override
  String get infraForceUpdateDesc => '新しいバージョンがリリースされました。アップデートしてください。';

  @override
  String get infraMaintenance => 'メンテナンス中';

  @override
  String get infraMaintenanceDesc => 'より良いサービスのためメンテナンス中です。しばらくお待ちください。';

  @override
  String get infraUpdateButton => 'アップデート';

  @override
  String get meta_achievements => '実績';

  @override
  String get meta_coins => 'コイン';

  @override
  String meta_coinReward(int amount) {
    return '+$amount コイン';
  }

  @override
  String get meta_achFirstStep => 'はじめの一歩';

  @override
  String get meta_achFirstStepDesc => '初めてのゲームクリア';

  @override
  String get meta_achTrainee => '練習生';

  @override
  String get meta_achTraineeDesc => '10ゲームクリア';

  @override
  String get meta_achFirstClear => '初クリア';

  @override
  String get meta_achFirstClearDesc => '初めてのラインクリア';

  @override
  String get meta_achComboIntro => 'コンボ入門';

  @override
  String get meta_achComboIntroDesc => 'コンボ x2 達成';

  @override
  String get meta_achTutorial => 'チュートリアルマスター';

  @override
  String get meta_achTutorialDesc => 'チュートリアル完了';

  @override
  String get meta_ach100 => '100点クラブ';

  @override
  String get meta_ach100Desc => 'スコア100+達成';

  @override
  String get meta_ach500 => '500点クラブ';

  @override
  String get meta_ach500Desc => 'スコア500+達成';

  @override
  String get meta_ach1000 => '1000点クラブ';

  @override
  String get meta_ach1000Desc => 'スコア1000+達成';

  @override
  String get meta_achComboMaster => 'コンボマスター';

  @override
  String get meta_achComboMasterDesc => 'コンボ x5 達成';

  @override
  String get meta_achChainReaction => '連鎖反応';

  @override
  String get meta_achChainReactionDesc => '3連鎖達成';

  @override
  String get meta_ach3000 => '3000点突破';

  @override
  String get meta_ach3000Desc => 'スコア3000+達成';

  @override
  String get meta_achComboKing => 'コンボキング';

  @override
  String get meta_achComboKingDesc => 'コンボ x10 達成';

  @override
  String get meta_achSurvivor => 'タイムサバイバー';

  @override
  String get meta_achSurvivorDesc => '1ゲームでスコア500+';

  @override
  String get meta_achPerfect => 'パーフェクトゲーム';

  @override
  String get meta_achPerfectDesc => '10ライン以上クリア';

  @override
  String get meta_achBombMaster => 'ボムマスター';

  @override
  String get meta_achBombMasterDesc => 'スコア3000+達成';

  @override
  String get meta_achShareKing => 'シェア王';

  @override
  String get meta_achShareKingDesc => '5ゲームプレイ';

  @override
  String get meta_achTop100 => 'グローバルトップ100';

  @override
  String get meta_achTop100Desc => '最高スコア2000+';

  @override
  String get meta_achChallenger => 'チャレンジャー';

  @override
  String get meta_achChallengerDesc => '7日連続ログイン';

  @override
  String get meta_achZoo => '動物園';

  @override
  String get meta_achZooDesc => 'アバター8種解除';

  @override
  String get meta_achFullCollection => 'フルコレクション';

  @override
  String get meta_achFullCollectionDesc => 'アバター12種解除';
}
