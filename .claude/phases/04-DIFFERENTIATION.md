# Phase 4: 차별화 기능 (킬러 피처)

> **목표**: "FLIPOP만의 것" — 애니팡/블록블라스트와 확실히 다른 경험
> **의존**: Phase 1~3 안정화 후
> **원칙**: 기존 "탭으로 색 순환 + 줄 맞추기" 코어를 강화하는 방향

---

## 경쟁작 분석 vs FLIPOP 차별점

| 요소 | 애니팡 | 블록블라스트 | FLIPOP (현재) | FLIPOP (목표) |
|------|--------|-------------|--------------|--------------|
| 조작 | 스와이프 매칭 | 블록 배치 | **탭 → 주변 변환** | 동일 (유니크) |
| 목표 | 3-match | 줄 채우기 | 가로줄 동일색 | **가로+세로+특수패턴** |
| 소셜 | 친구 랭킹 | 없음 | 글로벌 랭킹 | **실시간 대결** |
| 진행 | 스테이지 | 무한 | 무한(점수) | **데일리 챌린지 + 무한** |
| 캐릭터 | 동물 | 없음 | 동물 4종 | **동물 12종 + 성장** |

---

## 킬러 피처 1: 데일리 챌린지

매일 다른 "퍼즐" 제공 → 전 세계 동일 문제 → 랭킹

```
구조:
  - 매일 00:00 UTC에 새 챌린지 생성
  - 고정 시드(seed)로 동일 그리드 → 공정한 경쟁
  - 3번의 시도 제한 (최고 점수 기록)
  - 추가 시도: 리워드 광고 시청 (수익화 연계)

챌린지 유형 (요일별 로테이션):
  월: "타임어택" — 60초 내 최고점
  화: "제한 터치" — 20회 터치만 가능
  수: "콤보 마스터" — 콤보 x3 이상만 점수 인정
  목: "무중력" — 블록이 안 떨어짐 (전략적)
  금: "컬러 블라인드" — 중간에 색상이 바뀜
  토: "스피드런" — 500점 도달 최단 시간
  일: "자유 챌린지" — 일반 모드, 글로벌 1위 도전
```

### 구현:
```
신규 파일:
  - lib/game/daily_challenge.dart — 시드 기반 그리드 생성, 챌린지 룰
  - lib/services/daily_challenge_service.dart — Firestore 연동, 시도 관리
  - lib/ui/daily_challenge_screen.dart — 챌린지 전용 UI
  - lib/ui/daily_result_screen.dart — 결과 + 글로벌 순위

Firestore:
  - dailyChallenges/{date}/entries/{uid} — 점수, 시도 횟수
  - dailyChallenges/{date}/config — 시드, 룰, 난이도
```

---

## 킬러 피처 2: 실시간 1v1 대결 (WebSocket 또는 Firestore Realtime)

```
플로우:
  1. "대결" 버튼 → 매칭 큐 진입
  2. 상대 매칭 (Firestore 실시간 리스너 or Cloud Functions)
  3. 동일 시드 그리드 → 동시 플레이
  4. 상대 점수 실시간 표시 (상단 작은 바)
  5. 90초 후 승패 결정 → 트로피 포인트

기술 선택지:
  A) Firestore Realtime (간단, 기존 스택 활용)
     - 장점: 추가 인프라 없음
     - 단점: 지연시간 0.5~1초
     - 적합: 턴제 느낌이라 실시간 동기화 정밀도 불필요

  B) WebSocket (Firebase Realtime Database 또는 별도 서버)
     - 장점: 빠른 동기화
     - 단점: 추가 비용

→ **A안 추천** (Firestore Realtime): 이 게임은 각자 자기 그리드를 플레이하고
  점수만 공유하면 되므로 0.5초 지연 무관.

구현:
  신규 파일:
    - lib/services/matchmaking_service.dart — 매칭 로직
    - lib/ui/battle_screen.dart — 대결 UI (내 그리드 + 상대 점수바)
    - lib/ui/battle_result_screen.dart — 승패 결과
    - functions/src/matchmaking.ts — 매칭 Cloud Function

Firestore:
  - matchQueue/{uid} — 매칭 대기
  - battles/{battleId} — 시드, 참가자, 점수 실시간 업데이트
```

---

## 킬러 피처 3: 캐릭터 성장 시스템

기존 12종 아바타를 "수집 + 레벨업" 시스템으로 확장:

```
아바타 성장:
  - 레벨 1~5
  - 레벨업 조건: 해당 아바타 사용 시 게임 N회 플레이
  - 레벨업 보상: 특수 블록 스킨, 프로필 프레임, 이모지 리액션

아바타 해금:
  - 기본 4종 (cat, puppy, bunny, frog): 무료
  - Extra 4종 (penguin, bear, fox, turtle): 게임 플레이로 해금
    - 10게임, 50게임, 100게임, 200게임
  - Special 4종 (dragon, unicorn, phoenix, robot): IAP 또는 데일리 보너스

프로필 꾸미기:
  - 아바타 + 프레임 + 칭호
  - 리더보드에서 표시 → 소셜 동기 부여
```

### 구현:
```
수정 파일:
  - lib/game/avatar_data.dart — 레벨 시스템 추가
  - lib/services/avatar_service.dart — 신규, 해금/레벨업 관리
  - lib/ui/avatar_collection_screen.dart — 신규, 컬렉션 뷰
  - lib/ui/nickname_screen.dart — 프로필 꾸미기 확장

Firestore:
  - users/{uid}/avatars/{avatarId} — level, exp, unlockedAt
```

---

## 킬러 피처 4: 특수 블록 (Phase 1 밸런스와 연계)

score 3000+ 에서 등장하는 특수 블록:

```
1. 잠금 블록 (🔒): 2회 탭해야 변환 가능
2. 폭탄 블록 (💣): 클리어 시 주변 3×3 모두 제거
3. 무지개 블록 (🌈): 모든 색과 매칭 가능
4. 얼음 블록 (🧊): 인접 탭에 영향 안 받음, 직접 탭해야 변환

출현 규칙:
  - 새 줄 추가 시 10% 확률로 1개 포함
  - score 3000+ 부터만
  - 한 줄에 특수 블록 최대 1개
```

### 구현:
```
수정 파일:
  - lib/game/game_state.dart — Cell에 BlockType 추가 (normal, locked, bomb, rainbow, ice)
  - lib/game/game_state.dart — 탭 로직에 특수 블록 처리
  - lib/ui/block_widget.dart — 특수 블록 렌더링
  - test/game_state_test.dart — 특수 블록 테스트
```

---

## 우선순위 (MVP → 확장)

```
🔴 Must (Phase 4 내):
  1. 데일리 챌린지 — 리텐션 핵심
  2. 특수 블록 — 게임 깊이

🟡 Should (Phase 4 이후):
  3. 캐릭터 성장 — 장기 동기부여
  4. 1v1 대결 — 소셜/바이럴

🟢 Nice-to-have:
  5. 시즌제 (월간 리셋 + 보상)
  6. 길드/클랜 시스템
```

---

## 구현 순서 (Must만)

```
1. lib/game/daily_challenge.dart — 시드 기반 그리드 + 챌린지 룰
2. lib/services/daily_challenge_service.dart — Firestore 연동
3. lib/ui/daily_challenge_screen.dart — 챌린지 UI
4. lib/ui/main_screen.dart — 탭 추가 (게임/챌린지/랭킹/설정)
5. lib/game/game_state.dart — 특수 블록 (Cell 확장, 탭 로직)
6. lib/ui/block_widget.dart — 특수 블록 렌더링
7. test/ — 데일리 챌린지 + 특수 블록 테스트
8. l10n — 4개 언어 업데이트
9. flutter gen-l10n
10. flutter analyze + flutter test
```
