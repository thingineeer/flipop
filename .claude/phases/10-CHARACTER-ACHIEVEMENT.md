# Phase 10: 캐릭터 성장 + 업적 시스템

> **목표**: 장기 리텐션 — "모으고 키우는 재미"
> **핵심**: 게임을 할수록 아바타가 성장하고, 업적을 달성하는 메타 게임

---

## A. 캐릭터 성장 시스템

### 기존 아바타 (avatar_data.dart):
```
기본 4종: cat, puppy, bunny, frog (무료)
Extra 4종: penguin, bear, fox, turtle (게임 플레이로 해금)
Special 4종: dragon, unicorn, phoenix, robot (IAP 또는 업적)
```

### 해금 조건:
```
penguin:  총 10게임 플레이
bear:     총 50게임 플레이
fox:      최고점수 1000+ 달성
turtle:   7일 연속 접속

dragon:   데일리 챌린지 1위 1회
unicorn:  콤보 x10 달성
phoenix:  총 100게임 플레이
robot:    IAP "스페셜 아바타 팩" 구매 ($1.99)
```

### 아바타 레벨 (1~5):
```
각 아바타를 "사용 중"으로 설정한 상태에서 게임 플레이 시 경험치 획득.

Level 1: 기본 (해금 시)
Level 2: 10게임 → 프로필 프레임 (브론즈)
Level 3: 30게임 → 프로필 프레임 (실버) + 특수 클리어 이펙트
Level 4: 70게임 → 프로필 프레임 (골드)
Level 5: 150게임 → 프로필 프레임 (다이아) + 칭호

레벨업 보상:
  - 프로필 프레임 색상 변경 (리더보드에서 표시)
  - 레벨업 시 코인 보너스 (50/100/200/500)
```

### 구현:
```
수정:
  - lib/game/avatar_data.dart — level, exp, unlockCondition 필드 추가
  - lib/services/avatar_service.dart (신규) — 해금/레벨업 로직
  - lib/domain/entities/avatar_progress.dart (신규) — 아바타 진행 엔티티

신규 UI:
  - lib/ui/avatar_collection_screen.dart — 12종 아바타 컬렉션 뷰
    - 해금된 것: 풀 컬러 + 레벨 표시
    - 잠긴 것: 그레이스케일 + 해금 조건 표시
    - 탭 → 상세 (레벨 진행도, 보상 미리보기)
  - lib/ui/nickname_screen.dart 확장 — 해금된 아바타만 선택 가능

저장:
  - SecureStorage: avatarProgress (JSON)
  - Firestore: users/{uid}/avatars/{avatarId}
```

---

## B. 업적 시스템

### 업적 목록 (20개):

#### 입문 (5개)
```
🏅 첫 걸음        — 첫 게임 완료
🏅 연습생         — 10게임 완료
🏅 첫 클리어      — 첫 줄 클리어
🏅 콤보 입문      — 콤보 x2 달성
🏅 튜토리얼 마스터 — 튜토리얼 완료
```

#### 숙련 (5개)
```
🏅 100점 클럽    — 점수 100+ 달성
🏅 500점 클럽    — 점수 500+ 달성
🏅 1000점 클럽   — 점수 1000+ 달성
🏅 콤보 마스터    — 콤보 x5 달성
🏅 연쇄 반응      — 중력 후 자동 클리어 3연속
```

#### 도전 (5개)
```
🏅 3000점 돌파   — 점수 3000+ 달성
🏅 콤보 킹       — 콤보 x10 달성
🏅 타임 서바이버  — 5분 이상 생존
🏅 퍼펙트 게임    — 한 게임에서 10줄 이상 클리어
🏅 폭탄 마스터    — 폭탄 블록으로 3줄 동시 클리어
```

#### 소셜 (3개)
```
🏅 공유왕        — 스코어 5회 공유
🏅 글로벌 탑100   — 리더보드 100위 이내
🏅 챌린지 도전자  — 데일리 챌린지 7일 연속 참여
```

#### 수집 (2개)
```
🏅 동물원        — 아바타 8종 해금
🏅 풀 컬렉션      — 아바타 12종 전부 해금
```

### 구현:
```
lib/services/achievement_service.dart (신규)
  - 싱글톤, 게임 이벤트 감지 → 업적 달성 체크
  - 달성 시: 팝업 노티피케이션 + 코인 보상
  - SecureStorage에 달성 상태 저장
  - Firestore에 백업

lib/domain/entities/achievement.dart (신규)
  - id, title, description, condition, reward, isUnlocked, unlockedAt

lib/ui/achievement_screen.dart (신규)
  - 전체 업적 목록 (달성/미달성 구분)
  - 진행도 표시 (예: "3000점 돌파 — 현재 2,150점")
  - 달성된 업적: 골드 배경 + 날짜
  - 미달성: 그레이스케일 + 잠금 아이콘

lib/ui/achievement_popup.dart (신규)
  - 게임 중 업적 달성 시 상단에서 슬라이드 다운
  - 2초 표시 후 자동 사라짐
  - 업적 아이콘 + 제목 + 보상 코인
```

---

## C. 코인 샵

업적/레벨업/데일리 보너스로 모은 코인을 사용하는 곳:

```
코인 사용처:
  - 아바타 해금 가속 (Extra 4종): 500 코인
  - 게임 내 파워업 (힌트 1회): 100 코인
  - 게임 내 파워업 (색변환 1회): 150 코인

코인 획득처:
  - 데일리 보너스: 50~200/일
  - 업적 달성: 50~500/개
  - 아바타 레벨업: 50~500/레벨
  - 리워드 광고 시청: 30/회
  - IAP 코인팩: $0.99 = 500코인

lib/ui/coin_shop_screen.dart (신규)
  - 코인 잔액 표시
  - 파워업 구매 목록
  - IAP 코인팩 구매 버튼
```

---

## D. MoreScreen → 프로필 허브 확장

```
현재 MoreScreen 구조:
  - 프로필 편집
  - 소셜 연동
  - 로그아웃
  - 탈퇴

추가:
  - [아바타 컬렉션] → avatar_collection_screen.dart
  - [업적] → achievement_screen.dart
  - [코인 샵] → coin_shop_screen.dart
  - 사운드/음악 토글 (Phase 6에서 추가)
  - 다크 모드 (Phase 7에서 추가)
  - 알림 설정 (Phase 8에서 추가)
  - 개인정보/이용약관 (Phase 9에서 추가)
```

---

## 구현 순서

```
1. lib/game/avatar_data.dart — 레벨/해금 조건 확장
2. lib/domain/entities/avatar_progress.dart — 아바타 진행 엔티티
3. lib/services/avatar_service.dart — 해금/레벨업 로직
4. lib/ui/avatar_collection_screen.dart — 컬렉션 UI
5. lib/domain/entities/achievement.dart — 업적 엔티티
6. lib/services/achievement_service.dart — 업적 달성 로직
7. lib/ui/achievement_screen.dart — 업적 목록 UI
8. lib/ui/achievement_popup.dart — 달성 팝업
9. lib/ui/coin_shop_screen.dart — 코인 샵
10. lib/ui/more_screen.dart — 프로필 허브 확장
11. lib/ui/game_screen.dart — 게임 중 업적 체크 연결
12. l10n — 업적/아바타/코인 텍스트 4개 언어 (대량)
13. flutter gen-l10n
14. test/ — 아바타 서비스 + 업적 서비스 테스트
15. flutter analyze + flutter test
16. .claude/context/ 업데이트
```

---

## l10n 키 예상 (대량 — 40+ 키)

업적 20개 × (title + description) = 40키
아바타 12개 × (name + unlock_desc) = 24키
코인 샵 아이템 5개 = 5키
UI 텍스트 10키

**총 ~80키 × 4개 언어 = 320개 번역**

→ 한국어 먼저 작성 후 나머지 3개 언어 일괄 번역
