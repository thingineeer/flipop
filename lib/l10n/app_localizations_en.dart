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
      'Tap blocks to change colors\nand complete a row!';

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
  String get tapHint => 'Tap to change nearby colors! Match a row 🎯';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get newBest => '🎉 NEW BEST!';

  @override
  String get continueWithAd => 'Continue (Ad)';

  @override
  String get timeBonus => 'Time +30s (Ad)';

  @override
  String get scoreDouble => 'Score x2 (Ad)';

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
  String get tutorialClearTitle => 'Complete a row!';

  @override
  String get tutorialClearDesc =>
      'Fill a horizontal row with\nthe same color to clear it!';

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
}
