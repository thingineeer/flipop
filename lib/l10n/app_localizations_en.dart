// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FLIPOP';

  @override
  String get welcomeCharacters => 'Play with cute characters!';

  @override
  String get welcomeDescription =>
      'Tap blocks to change colors\nand complete a line!';

  @override
  String get welcomeCompete => 'Compete with players worldwide!';

  @override
  String get welcomeCompeteDesc =>
      'Sign in to save your scores\nand join the global ranking!';

  @override
  String get welcomeAccountHint =>
      'Link your account to keep\nyour records even if you delete the app';

  @override
  String get welcomeStart => 'Start now!';

  @override
  String get signInApple => 'Sign in with Apple';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get orDivider => 'or';

  @override
  String get signInGuest => 'Start without signing in';

  @override
  String get signInLaterHint => 'You can sign in anytime from Settings';

  @override
  String get startNow => 'Start Now';

  @override
  String get loginBenefitHint =>
      'Sign in to save records and join the ranking!';

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
    return '$remaining turns until new row';
  }

  @override
  String comboDisplay(int combo) {
    return 'COMBO x$combo';
  }

  @override
  String get tapHint => 'Tap to change nearby colors! Match rows or columns 🎯';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get newBest => '🎉 NEW BEST!';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get setNickname => 'Choose your nickname!';

  @override
  String get nicknameHint => 'Nickname (2–12 characters)';

  @override
  String get nicknameTaken => 'This nickname is already taken';

  @override
  String get noRecords => 'No records yet!';

  @override
  String myRank(int rank) {
    return 'My rank: #$rank';
  }

  @override
  String get settings => 'Settings';

  @override
  String get notLoggedIn => 'Not signed in';

  @override
  String get googleAccount => 'Google account';

  @override
  String get appleAccount => 'Apple account';

  @override
  String get guest => 'Guest';

  @override
  String get accountLinkHint =>
      'Link a social account to keep\nyour account even if you delete the app';

  @override
  String get linkAccount => 'Link Account';

  @override
  String get linkGoogle => 'Link with Google';

  @override
  String get linkApple => 'Link with Apple';

  @override
  String get changeCountry => 'Change Country';

  @override
  String get logout => 'Sign Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get change => 'Change';

  @override
  String get delete => 'Delete';

  @override
  String get logoutTitle => 'Sign Out';

  @override
  String get logoutMessage =>
      'Signing out will start a new guest session.\nYou can return by signing in again.';

  @override
  String get deleteTitle => 'Delete Account';

  @override
  String get deleteMessage =>
      'Deleting your account will permanently remove\nall game data and ranking records.\n\nThis action cannot be undone.';

  @override
  String get countryChanged => 'Country has been changed';

  @override
  String get googleLinked => 'Google account has been linked';

  @override
  String get appleLinked => 'Apple account has been linked';

  @override
  String get tutorialTapTitle => 'Tap a block!';

  @override
  String get tutorialTapDesc =>
      'Tapping changes the blocks\nabove, below, left, and right to the next color';

  @override
  String get tutorialTapHint => 'Tap → 4 adjacent blocks change color!';

  @override
  String get tutorialClearTitle => 'Complete a line!';

  @override
  String get tutorialClearDesc =>
      'Fill a row or column with\nthe same color to clear it!';

  @override
  String get tutorialComboTitle => 'Chain combo!';

  @override
  String get tutorialComboDesc =>
      'After clearing, blocks fall down\nand chain clears earn huge scores!';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialStart => 'Start!';

  @override
  String get moreTitle => 'More';

  @override
  String get gameSection => 'Game';

  @override
  String get ranking => 'Ranking';

  @override
  String get accountSection => 'Account';

  @override
  String get infoSection => 'Info';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get appVersion => 'App Version';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get avatarPicker => 'Choose Avatar';

  @override
  String get avatarBasic => 'Basic';

  @override
  String get avatarExtra => 'Extra';

  @override
  String get avatarSpecial => 'Special';

  @override
  String get save => 'Save';

  @override
  String get avatarChanged => 'Avatar has been changed';

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get comingSoon => 'COMING\nSOON';

  @override
  String googleSignInFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String appleSignInFailed(String error) {
    return 'Apple sign-in failed: $error';
  }

  @override
  String get watchAd => 'Watch Ad\nto Unlock';

  @override
  String get shareButton => 'Share';

  @override
  String shareScore(int score) {
    return 'I scored $score points in FLIPOP! Can you beat me?';
  }

  @override
  String get tutorialPuzzleTapTitle => 'Tap Effect';

  @override
  String get tutorialPuzzleTapDesc =>
      'Tap the center block to see\nhow surrounding colors change!';

  @override
  String get tutorialPuzzleTapSuccess =>
      'Great! Tapping changes nearby blocks!';

  @override
  String get tutorialPuzzleLineTitle => 'Match a Line';

  @override
  String get tutorialPuzzleLineDesc =>
      'Tap blocks to make\na row the same color!';

  @override
  String get tutorialPuzzleLineSuccess => 'Perfect! Line cleared!';

  @override
  String get tutorialPuzzleComboTitle => 'Combo Challenge';

  @override
  String get tutorialPuzzleComboDesc => 'Try to create a chain clear!';

  @override
  String get tutorialPuzzleComboSuccess => 'Amazing! Chain combo!';

  @override
  String get tutorialReady => 'Ready!';

  @override
  String get guidedHint => 'Complete the glowing row!';

  @override
  String get guidedStart => 'Ready? Let\'s go!';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get challengeTimeAttack => 'Time Attack';

  @override
  String get challengeLimitedMoves => 'Limited Moves';

  @override
  String get challengeComboMaster => 'Combo Master';

  @override
  String get challengeSpeedRun => 'Speed Run';

  @override
  String get challengeNormal => 'Free Mode';

  @override
  String attemptsLeft(int count) {
    return '$count attempts left';
  }

  @override
  String get tryAgainTomorrow => 'Try again tomorrow!';

  @override
  String movesLeft(int count) {
    return '$count moves left';
  }

  @override
  String targetScore(int score) {
    return 'Target: $score';
  }

  @override
  String get noAttemptsLeft => 'No attempts left for today';

  @override
  String get soundMusic => 'Music';

  @override
  String get soundSfx => 'Sound Effects';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get removeAdsPrice => '\$2.99';

  @override
  String get removeAdsDesc => 'Permanently remove banner and interstitial ads';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get adsRemoved => 'Ads Removed';

  @override
  String get purchaseFailed => 'Purchase Failed';

  @override
  String get purchaseSection => 'Purchase';

  @override
  String get avatarPack => 'Special Avatar Pack';

  @override
  String get avatarPackPrice => '\$1.99';

  @override
  String get avatarPackOwned => 'Avatar Pack Owned';

  @override
  String get ui_darkMode => 'Dark Mode';

  @override
  String get ui_newBest => 'NEW BEST!';

  @override
  String get ui_settingsSection => 'Settings';

  @override
  String get social_inviteFriends => 'Invite Friends';

  @override
  String get social_inviteMessage => 'Let\'s play FLIPOP! 🎮';

  @override
  String get social_challengeMe => 'Can you beat this?';

  @override
  String get infraForceUpdate => 'Update Required';

  @override
  String get infraForceUpdateDesc =>
      'A new version is available. Please update to continue.';

  @override
  String get infraMaintenance => 'Under Maintenance';

  @override
  String get infraMaintenanceDesc =>
      'We are currently under maintenance for a better experience. Please wait.';

  @override
  String get infraUpdateButton => 'Update';

  @override
  String get meta_achievements => 'Achievements';

  @override
  String get meta_coins => 'Coins';

  @override
  String meta_coinReward(int amount) {
    return '+$amount Coins';
  }

  @override
  String get meta_achFirstStep => 'First Step';

  @override
  String get meta_achFirstStepDesc => 'Complete your first game';

  @override
  String get meta_achTrainee => 'Trainee';

  @override
  String get meta_achTraineeDesc => 'Complete 10 games';

  @override
  String get meta_achFirstClear => 'First Clear';

  @override
  String get meta_achFirstClearDesc => 'Clear your first line';

  @override
  String get meta_achComboIntro => 'Combo Intro';

  @override
  String get meta_achComboIntroDesc => 'Achieve combo x2';

  @override
  String get meta_achTutorial => 'Tutorial Master';

  @override
  String get meta_achTutorialDesc => 'Complete the tutorial';

  @override
  String get meta_ach100 => '100 Club';

  @override
  String get meta_ach100Desc => 'Score 100+ points';

  @override
  String get meta_ach500 => '500 Club';

  @override
  String get meta_ach500Desc => 'Score 500+ points';

  @override
  String get meta_ach1000 => '1000 Club';

  @override
  String get meta_ach1000Desc => 'Score 1000+ points';

  @override
  String get meta_achComboMaster => 'Combo Master';

  @override
  String get meta_achComboMasterDesc => 'Achieve combo x5';

  @override
  String get meta_achChainReaction => 'Chain Reaction';

  @override
  String get meta_achChainReactionDesc => '3 chain combos';

  @override
  String get meta_ach3000 => '3000 Breakthrough';

  @override
  String get meta_ach3000Desc => 'Score 3000+ points';

  @override
  String get meta_achComboKing => 'Combo King';

  @override
  String get meta_achComboKingDesc => 'Achieve combo x10';

  @override
  String get meta_achSurvivor => 'Time Survivor';

  @override
  String get meta_achSurvivorDesc => 'Score 500+ in one game';

  @override
  String get meta_achPerfect => 'Perfect Game';

  @override
  String get meta_achPerfectDesc => 'Clear 10+ lines';

  @override
  String get meta_achBombMaster => 'Bomb Master';

  @override
  String get meta_achBombMasterDesc => 'Score 3000+ points';

  @override
  String get meta_achShareKing => 'Share King';

  @override
  String get meta_achShareKingDesc => 'Play 5 games';

  @override
  String get meta_achTop100 => 'Global Top 100';

  @override
  String get meta_achTop100Desc => 'Best score 2000+';

  @override
  String get meta_achChallenger => 'Challenger';

  @override
  String get meta_achChallengerDesc => '7-day login streak';

  @override
  String get meta_achZoo => 'Zoo';

  @override
  String get meta_achZooDesc => 'Unlock 8 avatars';

  @override
  String get meta_achFullCollection => 'Full Collection';

  @override
  String get meta_achFullCollectionDesc => 'Unlock 12 avatars';
}
