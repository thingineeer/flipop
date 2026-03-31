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
  String get tapHint => '点击改变周围颜色！完成横排或竖排 🎯';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get newBest => '🎉 NEW BEST!';

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
  String get tutorialClearDesc => '将横排或竖排填满\n相同颜色即可消除！';

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
  String get openSourceLicenses => '开源许可证';

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
  String get comingSoon => 'COMING\nSOON';

  @override
  String googleSignInFailed(String error) {
    return 'Google登录失败: $error';
  }

  @override
  String appleSignInFailed(String error) {
    return 'Apple登录失败: $error';
  }

  @override
  String get watchAd => '看广告\n解锁';

  @override
  String get shareButton => '分享';

  @override
  String shareScore(int score) {
    return '我在FLIPOP中获得了$score分！来挑战吧！';
  }

  @override
  String get tutorialPuzzleTapTitle => '点击效果';

  @override
  String get tutorialPuzzleTapDesc => '点击中间的方块\n看看周围颜色的变化！';

  @override
  String get tutorialPuzzleTapSuccess => '很好！点击会改变周围的方块！';

  @override
  String get tutorialPuzzleLineTitle => '凑齐一行';

  @override
  String get tutorialPuzzleLineDesc => '点击方块，让\n一整行变成相同颜色！';

  @override
  String get tutorialPuzzleLineSuccess => '完美！成功消除一行！';

  @override
  String get tutorialPuzzleComboTitle => '连击挑战';

  @override
  String get tutorialPuzzleComboDesc => '试试创造连锁消除！';

  @override
  String get tutorialPuzzleComboSuccess => '太厉害了！连锁连击！';

  @override
  String get tutorialReady => '准备完毕！';

  @override
  String get guidedHint => '完成闪烁的那一行！';

  @override
  String get guidedStart => '准备好了吗？开始吧！';

  @override
  String get dailyChallenge => '每日挑战';

  @override
  String get challengeTimeAttack => '限时挑战';

  @override
  String get challengeLimitedMoves => '限制触碰';

  @override
  String get challengeComboMaster => '连击大师';

  @override
  String get challengeSpeedRun => '竞速挑战';

  @override
  String get challengeNormal => '自由模式';

  @override
  String attemptsLeft(int count) {
    return '剩余$count次';
  }

  @override
  String get tryAgainTomorrow => '明天再来挑战吧！';

  @override
  String movesLeft(int count) {
    return '剩余触碰: $count';
  }

  @override
  String targetScore(int score) {
    return '目标: $score分';
  }

  @override
  String get noAttemptsLeft => '今天的挑战次数已用完';

  @override
  String get soundMusic => '音乐';

  @override
  String get soundSfx => '音效';

  @override
  String get removeAds => '移除广告';

  @override
  String get removeAdsPrice => '\$2.99';

  @override
  String get removeAdsDesc => '永久移除横幅和插页广告';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get adsRemoved => '广告已移除';

  @override
  String get purchaseFailed => '购买失败';

  @override
  String get purchaseSection => '购买';

  @override
  String get avatarPack => '特别头像包';

  @override
  String get avatarPackPrice => '\$1.99';

  @override
  String get avatarPackOwned => '已拥有头像包';

  @override
  String get ui_darkMode => '深色模式';

  @override
  String get ui_newBest => '新纪录!';

  @override
  String get ui_settingsSection => '设置';

  @override
  String get social_inviteFriends => '邀请好友';

  @override
  String get social_inviteMessage => '一起玩FLIPOP吧！🎮';

  @override
  String get social_challengeMe => '你能超过这个分数吗？';

  @override
  String get infraForceUpdate => '需要更新';

  @override
  String get infraForceUpdateDesc => '新版本已发布，请更新后继续使用。';

  @override
  String get infraMaintenance => '维护中';

  @override
  String get infraMaintenanceDesc => '为了提供更好的服务，正在进行维护。请稍候。';

  @override
  String get infraUpdateButton => '更新';

  @override
  String get meta_achievements => '成就';

  @override
  String get meta_coins => '金币';

  @override
  String meta_coinReward(int amount) {
    return '+$amount 金币';
  }

  @override
  String get meta_achFirstStep => '第一步';

  @override
  String get meta_achFirstStepDesc => '完成第一局游戏';

  @override
  String get meta_achTrainee => '练习生';

  @override
  String get meta_achTraineeDesc => '完成10局游戏';

  @override
  String get meta_achFirstClear => '首次消除';

  @override
  String get meta_achFirstClearDesc => '首次消除一行';

  @override
  String get meta_achComboIntro => '连击入门';

  @override
  String get meta_achComboIntroDesc => '达成连击 x2';

  @override
  String get meta_achTutorial => '教程大师';

  @override
  String get meta_achTutorialDesc => '完成教程';

  @override
  String get meta_ach100 => '100分俱乐部';

  @override
  String get meta_ach100Desc => '得分100+';

  @override
  String get meta_ach500 => '500分俱乐部';

  @override
  String get meta_ach500Desc => '得分500+';

  @override
  String get meta_ach1000 => '1000分俱乐部';

  @override
  String get meta_ach1000Desc => '得分1000+';

  @override
  String get meta_achComboMaster => '连击大师';

  @override
  String get meta_achComboMasterDesc => '达成连击 x5';

  @override
  String get meta_achChainReaction => '连锁反应';

  @override
  String get meta_achChainReactionDesc => '达成3连锁';

  @override
  String get meta_ach3000 => '3000分突破';

  @override
  String get meta_ach3000Desc => '得分3000+';

  @override
  String get meta_achComboKing => '连击之王';

  @override
  String get meta_achComboKingDesc => '达成连击 x10';

  @override
  String get meta_achSurvivor => '时间幸存者';

  @override
  String get meta_achSurvivorDesc => '单局得分500+';

  @override
  String get meta_achPerfect => '完美游戏';

  @override
  String get meta_achPerfectDesc => '消除10行以上';

  @override
  String get meta_achBombMaster => '炸弹大师';

  @override
  String get meta_achBombMasterDesc => '得分3000+';

  @override
  String get meta_achShareKing => '分享达人';

  @override
  String get meta_achShareKingDesc => '玩5局游戏';

  @override
  String get meta_achTop100 => '全球前100';

  @override
  String get meta_achTop100Desc => '最高分2000+';

  @override
  String get meta_achChallenger => '挑战者';

  @override
  String get meta_achChallengerDesc => '连续登录7天';

  @override
  String get meta_achZoo => '动物园';

  @override
  String get meta_achZooDesc => '解锁8种头像';

  @override
  String get meta_achFullCollection => '全收集';

  @override
  String get meta_achFullCollectionDesc => '解锁12种头像';

  @override
  String get tabGame => '游戏';

  @override
  String get tabChallenge => '挑战';

  @override
  String get tabRanking => '排行榜';

  @override
  String get tabMore => '更多';

  @override
  String get errorNetwork => '请检查网络连接';

  @override
  String get errorLoginCancelled => '登录已取消';

  @override
  String get errorGeneric => '发生临时错误';

  @override
  String get errorPermission => '权限错误';

  @override
  String get errorSaveFailed => '保存失败，请重试';

  @override
  String get restoreComplete => '购买恢复成功';

  @override
  String get labelStart => 'START';

  @override
  String get labelSkip => '跳过';

  @override
  String get labelReset => '重置';

  @override
  String get labelMoves => '触摸';

  @override
  String get labelDailyBonus => '每日奖励';

  @override
  String get labelCoins => '金币';

  @override
  String get labelBest => '最佳';

  @override
  String get watchAdAndClaim => '看广告领取';

  @override
  String get labelLater => '稍后';

  @override
  String get labelRanking => '排行榜';

  @override
  String get labelTap => '点击';

  @override
  String labelDay(int day) {
    return '第$day天';
  }
}
