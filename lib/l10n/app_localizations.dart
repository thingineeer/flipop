import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'FLIPOP'**
  String get appTitle;

  /// No description provided for @welcomeCharacters.
  ///
  /// In ko, this message translates to:
  /// **'귀여운 캐릭터와 함께!'**
  String get welcomeCharacters;

  /// No description provided for @welcomeDescription.
  ///
  /// In ko, this message translates to:
  /// **'블록을 탭해서 색을 바꾸고,\n한 줄을 완성하세요!'**
  String get welcomeDescription;

  /// No description provided for @welcomeCompete.
  ///
  /// In ko, this message translates to:
  /// **'전 세계 플레이어와 경쟁!'**
  String get welcomeCompete;

  /// No description provided for @welcomeCompeteDesc.
  ///
  /// In ko, this message translates to:
  /// **'로그인하면 점수가 저장되고\n세계 랭킹에 참여!'**
  String get welcomeCompeteDesc;

  /// No description provided for @welcomeAccountHint.
  ///
  /// In ko, this message translates to:
  /// **'계정을 연동하면 앱을 삭제해도\n기록이 유지됩니다'**
  String get welcomeAccountHint;

  /// No description provided for @welcomeStart.
  ///
  /// In ko, this message translates to:
  /// **'지금 시작하세요!'**
  String get welcomeStart;

  /// No description provided for @signInApple.
  ///
  /// In ko, this message translates to:
  /// **'Apple로 시작'**
  String get signInApple;

  /// No description provided for @signInGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 시작'**
  String get signInGoogle;

  /// No description provided for @orDivider.
  ///
  /// In ko, this message translates to:
  /// **'또는'**
  String get orDivider;

  /// No description provided for @signInGuest.
  ///
  /// In ko, this message translates to:
  /// **'로그인 없이 시작하기'**
  String get signInGuest;

  /// No description provided for @signInLaterHint.
  ///
  /// In ko, this message translates to:
  /// **'나중에 설정에서 언제든 로그인할 수 있어요'**
  String get signInLaterHint;

  /// No description provided for @startNow.
  ///
  /// In ko, this message translates to:
  /// **'바로 시작하기'**
  String get startNow;

  /// No description provided for @loginBenefitHint.
  ///
  /// In ko, this message translates to:
  /// **'로그인하면 기록이 저장되고 랭킹에 참여할 수 있어요!'**
  String get loginBenefitHint;

  /// No description provided for @scoreLabel.
  ///
  /// In ko, this message translates to:
  /// **'SCORE'**
  String get scoreLabel;

  /// No description provided for @rankingLabel.
  ///
  /// In ko, this message translates to:
  /// **'RANKING'**
  String get rankingLabel;

  /// No description provided for @bestLabel.
  ///
  /// In ko, this message translates to:
  /// **'BEST'**
  String get bestLabel;

  /// No description provided for @timeLabel.
  ///
  /// In ko, this message translates to:
  /// **'TIME'**
  String get timeLabel;

  /// No description provided for @turnsUntilNewRow.
  ///
  /// In ko, this message translates to:
  /// **'새 줄까지 {remaining}턴'**
  String turnsUntilNewRow(int remaining);

  /// No description provided for @comboDisplay.
  ///
  /// In ko, this message translates to:
  /// **'COMBO x{combo}'**
  String comboDisplay(int combo);

  /// No description provided for @tapHint.
  ///
  /// In ko, this message translates to:
  /// **'탭하면 주변 색이 바뀌어요! 한 줄을 같은 색으로 🎯'**
  String get tapHint;

  /// No description provided for @gameOver.
  ///
  /// In ko, this message translates to:
  /// **'GAME OVER'**
  String get gameOver;

  /// No description provided for @newBest.
  ///
  /// In ko, this message translates to:
  /// **'🎉 NEW BEST!'**
  String get newBest;

  /// No description provided for @continueWithAd.
  ///
  /// In ko, this message translates to:
  /// **'이어하기 (광고)'**
  String get continueWithAd;

  /// No description provided for @timeBonus.
  ///
  /// In ko, this message translates to:
  /// **'시간 +30초 (광고)'**
  String get timeBonus;

  /// No description provided for @scoreDouble.
  ///
  /// In ko, this message translates to:
  /// **'점수 2배 (광고)'**
  String get scoreDouble;

  /// No description provided for @playAgain.
  ///
  /// In ko, this message translates to:
  /// **'PLAY AGAIN'**
  String get playAgain;

  /// No description provided for @setNickname.
  ///
  /// In ko, this message translates to:
  /// **'닉네임을 정해주세요!'**
  String get setNickname;

  /// No description provided for @nicknameHint.
  ///
  /// In ko, this message translates to:
  /// **'닉네임 (2~12자)'**
  String get nicknameHint;

  /// No description provided for @nicknameTaken.
  ///
  /// In ko, this message translates to:
  /// **'이미 사용 중인 닉네임입니다'**
  String get nicknameTaken;

  /// No description provided for @noRecords.
  ///
  /// In ko, this message translates to:
  /// **'아직 기록이 없어요!'**
  String get noRecords;

  /// No description provided for @myRank.
  ///
  /// In ko, this message translates to:
  /// **'내 순위: #{rank}'**
  String myRank(int rank);

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @notLoggedIn.
  ///
  /// In ko, this message translates to:
  /// **'로그인 안 됨'**
  String get notLoggedIn;

  /// No description provided for @googleAccount.
  ///
  /// In ko, this message translates to:
  /// **'Google 계정'**
  String get googleAccount;

  /// No description provided for @appleAccount.
  ///
  /// In ko, this message translates to:
  /// **'Apple 계정'**
  String get appleAccount;

  /// No description provided for @guest.
  ///
  /// In ko, this message translates to:
  /// **'게스트'**
  String get guest;

  /// No description provided for @accountLinkHint.
  ///
  /// In ko, this message translates to:
  /// **'소셜 계정을 연동하면 앱을 삭제해도\n계정이 유지됩니다'**
  String get accountLinkHint;

  /// No description provided for @linkAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정 연동'**
  String get linkAccount;

  /// No description provided for @linkGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 연동'**
  String get linkGoogle;

  /// No description provided for @linkApple.
  ///
  /// In ko, this message translates to:
  /// **'Apple로 연동'**
  String get linkApple;

  /// No description provided for @changeCountry.
  ///
  /// In ko, this message translates to:
  /// **'국가 변경'**
  String get changeCountry;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정 삭제'**
  String get deleteAccount;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @change.
  ///
  /// In ko, this message translates to:
  /// **'변경'**
  String get change;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @logoutTitle.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃하면 게스트로 새 세션이 시작됩니다.\n소셜 로그인으로 다시 돌아올 수 있습니다.'**
  String get logoutMessage;

  /// No description provided for @deleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'계정 삭제'**
  String get deleteTitle;

  /// No description provided for @deleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'계정을 삭제하면 모든 게임 데이터와\n랭킹 기록이 영구적으로 삭제됩니다.\n\n이 작업은 되돌릴 수 없습니다.'**
  String get deleteMessage;

  /// No description provided for @countryChanged.
  ///
  /// In ko, this message translates to:
  /// **'국가가 변경되었습니다'**
  String get countryChanged;

  /// No description provided for @googleLinked.
  ///
  /// In ko, this message translates to:
  /// **'Google 계정이 연동되었습니다'**
  String get googleLinked;

  /// No description provided for @appleLinked.
  ///
  /// In ko, this message translates to:
  /// **'Apple 계정이 연동되었습니다'**
  String get appleLinked;

  /// No description provided for @tutorialTapTitle.
  ///
  /// In ko, this message translates to:
  /// **'블록을 탭!'**
  String get tutorialTapTitle;

  /// No description provided for @tutorialTapDesc.
  ///
  /// In ko, this message translates to:
  /// **'탭하면 상하좌우 블록이\n다음 색으로 바뀌어요'**
  String get tutorialTapDesc;

  /// No description provided for @tutorialTapHint.
  ///
  /// In ko, this message translates to:
  /// **'탭 → 주변 4칸이 다음 색으로!'**
  String get tutorialTapHint;

  /// No description provided for @tutorialClearTitle.
  ///
  /// In ko, this message translates to:
  /// **'한 줄 완성!'**
  String get tutorialClearTitle;

  /// No description provided for @tutorialClearDesc.
  ///
  /// In ko, this message translates to:
  /// **'가로 한 줄을 같은 색으로\n채우면 클리어!'**
  String get tutorialClearDesc;

  /// No description provided for @tutorialComboTitle.
  ///
  /// In ko, this message translates to:
  /// **'연쇄 콤보!'**
  String get tutorialComboTitle;

  /// No description provided for @tutorialComboDesc.
  ///
  /// In ko, this message translates to:
  /// **'클리어 후 블록이 떨어져서\n연쇄가 터지면 대박 점수!'**
  String get tutorialComboDesc;

  /// No description provided for @tutorialNext.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get tutorialNext;

  /// No description provided for @tutorialStart.
  ///
  /// In ko, this message translates to:
  /// **'시작하기!'**
  String get tutorialStart;

  /// No description provided for @moreTitle.
  ///
  /// In ko, this message translates to:
  /// **'더보기'**
  String get moreTitle;

  /// No description provided for @gameSection.
  ///
  /// In ko, this message translates to:
  /// **'게임'**
  String get gameSection;

  /// No description provided for @ranking.
  ///
  /// In ko, this message translates to:
  /// **'랭킹'**
  String get ranking;

  /// No description provided for @accountSection.
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get accountSection;

  /// No description provided for @infoSection.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get infoSection;

  /// No description provided for @privacyPolicy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get termsOfService;

  /// No description provided for @appVersion.
  ///
  /// In ko, this message translates to:
  /// **'앱 버전'**
  String get appVersion;

  /// No description provided for @avatarPicker.
  ///
  /// In ko, this message translates to:
  /// **'아바타 선택'**
  String get avatarPicker;

  /// No description provided for @avatarBasic.
  ///
  /// In ko, this message translates to:
  /// **'기본'**
  String get avatarBasic;

  /// No description provided for @avatarExtra.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get avatarExtra;

  /// No description provided for @avatarSpecial.
  ///
  /// In ko, this message translates to:
  /// **'특별'**
  String get avatarSpecial;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @avatarChanged.
  ///
  /// In ko, this message translates to:
  /// **'아바타가 변경되었습니다'**
  String get avatarChanged;

  /// No description provided for @saveFailed.
  ///
  /// In ko, this message translates to:
  /// **'변경 실패: {error}'**
  String saveFailed(String error);

  /// No description provided for @startButton.
  ///
  /// In ko, this message translates to:
  /// **'START'**
  String get startButton;

  /// No description provided for @leaderboardAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get leaderboardAll;

  /// No description provided for @leaderboardCountry.
  ///
  /// In ko, this message translates to:
  /// **'국가'**
  String get leaderboardCountry;

  /// No description provided for @comboInfo1.
  ///
  /// In ko, this message translates to:
  /// **'COMBO x1  →  +100점  +3초'**
  String get comboInfo1;

  /// No description provided for @comboInfo2.
  ///
  /// In ko, this message translates to:
  /// **'COMBO x2  →  +200점  +5초'**
  String get comboInfo2;

  /// No description provided for @comboInfo3.
  ///
  /// In ko, this message translates to:
  /// **'COMBO x3  →  +300점  +7초 🔥'**
  String get comboInfo3;

  /// No description provided for @comingSoon.
  ///
  /// In ko, this message translates to:
  /// **'COMING\nSOON'**
  String get comingSoon;

  /// No description provided for @googleSignInFailed.
  ///
  /// In ko, this message translates to:
  /// **'Google 로그인 실패: {error}'**
  String googleSignInFailed(String error);

  /// No description provided for @appleSignInFailed.
  ///
  /// In ko, this message translates to:
  /// **'Apple 로그인 실패: {error}'**
  String appleSignInFailed(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
