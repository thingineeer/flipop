// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FLIPOP';

  @override
  String get welcomeCharacters => '和可爱的角色一起玩！';

  @override
  String get welcomeDescription => '点击方块改变颜色，\n完成一整行！';

  @override
  String get welcomeCompete => '与全球玩家竞争！';

  @override
  String get welcomeCompeteDesc => '登录后分数会被保存，\n参与世界排名！';

  @override
  String get welcomeAccountHint => '绑定账号后即使删除应用\n记录也会保留';

  @override
  String get welcomeStart => '现在开始！';

  @override
  String get signInApple => '使用Apple登录';

  @override
  String get signInGoogle => '使用Google登录';

  @override
  String get orDivider => '或';

  @override
  String get signInGuest => '无需登录直接开始';

  @override
  String get signInLaterHint => '之后可以随时在设置中登录';

  @override
  String get startNow => '立即开始';

  @override
  String get loginBenefitHint => '登录后可以保存记录并参与排名！';

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
    return '距离新行还有$remaining回合';
  }

  @override
  String comboDisplay(int combo) {
    return 'COMBO x$combo';
  }

  @override
  String get tapHint => '点击改变周围颜色！将一行变为相同颜色 🎯';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get newBest => '🎉 NEW BEST!';

  @override
  String get continueWithAd => '继续（广告）';

  @override
  String get timeBonus => '时间 +30秒（广告）';

  @override
  String get scoreDouble => '分数翻倍（广告）';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get setNickname => '请设置昵称！';

  @override
  String get nicknameHint => '昵称（2~12个字符）';

  @override
  String get nicknameTaken => '该昵称已被使用';

  @override
  String get noRecords => '还没有记录！';

  @override
  String myRank(int rank) {
    return '我的排名：#$rank';
  }

  @override
  String get settings => '设置';

  @override
  String get notLoggedIn => '未登录';

  @override
  String get googleAccount => 'Google账号';

  @override
  String get appleAccount => 'Apple账号';

  @override
  String get guest => '游客';

  @override
  String get accountLinkHint => '绑定社交账号后即使删除应用\n账号也会保留';

  @override
  String get linkAccount => '绑定账号';

  @override
  String get linkGoogle => '绑定Google';

  @override
  String get linkApple => '绑定Apple';

  @override
  String get changeCountry => '更改国家';

  @override
  String get logout => '退出登录';

  @override
  String get deleteAccount => '删除账号';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get change => '更改';

  @override
  String get delete => '删除';

  @override
  String get logoutTitle => '退出登录';

  @override
  String get logoutMessage => '退出登录后将以游客身份开始新会话。\n您可以通过社交登录重新登录。';

  @override
  String get deleteTitle => '删除账号';

  @override
  String get deleteMessage => '删除账号后，所有游戏数据和\n排名记录将被永久删除。\n\n此操作无法撤销。';

  @override
  String get countryChanged => '国家已更改';

  @override
  String get googleLinked => 'Google账号已绑定';

  @override
  String get appleLinked => 'Apple账号已绑定';

  @override
  String get tutorialTapTitle => '点击方块！';

  @override
  String get tutorialTapDesc => '点击后上下左右的方块\n会变成下一个颜色';

  @override
  String get tutorialTapHint => '点击 → 周围4格变为下一个颜色！';

  @override
  String get tutorialClearTitle => '完成一行！';

  @override
  String get tutorialClearDesc => '将横排一行填满\n相同颜色即可消除！';

  @override
  String get tutorialComboTitle => '连锁连击！';

  @override
  String get tutorialComboDesc => '消除后方块下落，\n连锁消除可获得超高分数！';

  @override
  String get tutorialNext => '下一步';

  @override
  String get tutorialStart => '开始！';

  @override
  String get moreTitle => '更多';

  @override
  String get gameSection => '游戏';

  @override
  String get ranking => '排名';

  @override
  String get accountSection => '账号';

  @override
  String get infoSection => '信息';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '使用条款';

  @override
  String get appVersion => '应用版本';

  @override
  String get avatarPicker => '选择头像';

  @override
  String get avatarBasic => '基础';

  @override
  String get avatarExtra => '额外';

  @override
  String get avatarSpecial => '特别';

  @override
  String get save => '保存';

  @override
  String get avatarChanged => '头像已更改';

  @override
  String saveFailed(String error) {
    return '更改失败: $error';
  }

  @override
  String get startButton => 'START';

  @override
  String get leaderboardAll => '全部';

  @override
  String get leaderboardCountry => '国家';

  @override
  String get comboInfo1 => 'COMBO x1  →  +100分  +3秒';

  @override
  String get comboInfo2 => 'COMBO x2  →  +200分  +5秒';

  @override
  String get comboInfo3 => 'COMBO x3  →  +300分  +7秒 🔥';

  @override
  String get comingSoon => 'COMING\nSOON';

  @override
  String googleSignInFailed(String error) {
    return 'Google登录失败: $error';
  }

  @override
  String appleSignInFailed(String error) {
    return 'Apple登录失败: $error';
  }
}
