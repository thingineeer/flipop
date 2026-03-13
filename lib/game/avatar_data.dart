import 'game_state.dart';

/// 아바타 데이터 (공통 상수)
class AvatarData {
  // 기본 아바타 (무료)
  static const List<String> basicAvatars = ['cat', 'puppy', 'bunny', 'frog'];

  // 추가 아바타 (무료)
  static const List<String> extraAvatars = [
    'penguin',
    'bear',
    'fox',
    'turtle',
  ];

  // 특별 아바타 (잠금 해제)
  static const List<String> specialAvatars = [
    'dragon',
    'unicorn',
    'phoenix',
    'robot',
  ];

  // 모든 아바타
  static const List<String> allAvatars = [
    ...basicAvatars,
    ...extraAvatars,
    ...specialAvatars,
  ];

  // 현재 이미지가 존재하는 아바타 (이미지 추가 시 업데이트)
  static const Set<String> availableAvatars = {
    'cat', 'puppy', 'bunny', 'frog', 'penguin',
  };

  // 아바타 → 이미지 경로
  static const Map<String, String> images = {
    'cat': 'assets/images/cat_red.png',
    'puppy': 'assets/images/puppy_blue.png',
    'bunny': 'assets/images/bunny_yellow.png',
    'frog': 'assets/images/frog_green.png',
    'penguin': 'assets/images/penguin_red.png',
    'bear': 'assets/images/bear_blue.png',
    'fox': 'assets/images/fox_yellow.png',
    'turtle': 'assets/images/turtle_green.png',
    'dragon': 'assets/images/dragon_red.png',
    'unicorn': 'assets/images/unicorn_blue.png',
    'phoenix': 'assets/images/phoenix_yellow.png',
    'robot': 'assets/images/robot_green.png',
  };

  // 아바타 → 배경색 (BlockColor 매핑)
  static const Map<String, BlockColor> avatarColors = {
    'cat': BlockColor.red,
    'puppy': BlockColor.blue,
    'bunny': BlockColor.yellow,
    'frog': BlockColor.green,
    'penguin': BlockColor.red,
    'bear': BlockColor.blue,
    'fox': BlockColor.yellow,
    'turtle': BlockColor.green,
    'dragon': BlockColor.red,
    'unicorn': BlockColor.blue,
    'phoenix': BlockColor.yellow,
    'robot': BlockColor.green,
  };

  // 아바타 → 색상 그룹 이름
  static const Map<String, String> colorGroup = {
    'cat': 'red',
    'penguin': 'red',
    'dragon': 'red',
    'puppy': 'blue',
    'bear': 'blue',
    'unicorn': 'blue',
    'bunny': 'yellow',
    'fox': 'yellow',
    'phoenix': 'yellow',
    'frog': 'green',
    'turtle': 'green',
    'robot': 'green',
  };

  // 특별 아바타 해제 조건
  static const Map<String, String> unlockConditions = {
    'dragon': '최고점 500점 달성',
    'unicorn': '30일 연속 플레이',
    'phoenix': '리워드 광고 10회 시청',
    'robot': '소셜 계정 연동 완료',
  };

  // 기본/추가 아바타인지 확인
  static bool isBasicOrExtra(String id) =>
      basicAvatars.contains(id) || extraAvatars.contains(id);

  // 특별 아바타인지 확인
  static bool isSpecial(String id) => specialAvatars.contains(id);
}
