# FLIPOP 하네스 엔지니어링 — 마스터 오케스트레이션

> 이 파일은 Claude Code가 FLIPOP 프로젝트를 체계적으로 개선하기 위한 마스터 실행 가이드입니다.
> "작업 시작해"라고 말하면, 이 파일과 하위 Phase 파일들을 순서대로 읽고 실행합니다.

---

## 목표

| 지표 | 현재 | 목표 |
|------|------|------|
| 월 수익 | ~$0 | **$50/월** (1차) |
| Day-1 리텐션 | 미측정 | **40%+** |
| 평균 세션 | 미측정 | **3회/일, 5분+/세션** |
| 스토어 평점 | 없음 | **4.5+** |

---

## 실행 순서 (Phase)

**반드시 순서대로 실행**하고, 각 Phase 완료 후 `flutter analyze` + `flutter test` 통과 확인.

### Phase 1: 게임 밸런스 재설계 (핵심)
```
파일: .claude/phases/01-GAME-BALANCE.md
예상: 대규모 변경 (game_state.dart 중심)
의존: 없음
```
현재 문제: 너무 어렵고, 초반부터 막히며, 성취감 부족.
목표: "쉽게 시작 → 점진적 어려움 → 중독적 루프" 달성.

### Phase 2: 온보딩 완전 재설계
```
파일: .claude/phases/02-ONBOARDING.md
예상: UI 대규모 변경
의존: Phase 1 완료 후
```
현재 문제: 3단계 텍스트 튜토리얼만으로는 게임 이해 불가.
목표: "플레이하면서 배우는" 인터랙티브 온보딩.

### Phase 3: 수익화 전략 강화
```
파일: .claude/phases/03-MONETIZATION.md
예상: 서비스 + UI 변경
의존: Phase 1, 2 완료 후
```
현재 문제: 광고 3종만으로는 $50/월 달성 불가.
목표: 광고 최적화 + 소액 IAP + 일일 챌린지 → 복합 수익.

### Phase 4: 차별화 기능 (킬러 피처)
```
파일: .claude/phases/04-DIFFERENTIATION.md
예상: 새 기능 추가
의존: Phase 1~3 안정화 후
```
목표: 애니팡/블록블라스트와 다른 "FLIPOP만의 것" 구축.

### Phase 5: 기술 최적화 + 성장 ✅
```
파일: .claude/phases/05-TECH-GROWTH.md
예상: 인프라 + 마케팅 기반
의존: Phase 1~4 완료 후
```
목표: 퍼포먼스 최적화, ASO, 바이럴 장치.

### Phase 6: 사운드 + 햅틱 + 주스 🔴
```
파일: .claude/phases/06-SOUND-HAPTICS-JUICE.md
의존: 없음 (Phase 7, 9와 병렬 가능)
```
목표: 탭/클리어/콤보의 감각 피드백으로 중독성 10배.

### Phase 7: UI/UX 폴리시 🔴
```
파일: .claude/phases/07-UI-POLISH.md
의존: 없음 (Phase 6, 9와 병렬 가능)
```
목표: 블록 애니메이션, 게임오버 연출, 다크 모드.

### Phase 8: 소셜 + 바이럴 🟡
```
파일: .claude/phases/08-SOCIAL-VIRAL.md
의존: Phase 7 (게임오버 UI에 공유 카드 의존)
```
목표: 공유 카드, 푸시 알림, 앱 리뷰, 초대.

### Phase 9: 운영 인프라 🔴
```
파일: .claude/phases/09-INFRA-MONITORING.md
의존: 없음 (Phase 6, 7과 병렬 가능)
```
목표: Remote Config, Crashlytics, Analytics, 강제 업데이트.

### Phase 10: 캐릭터 성장 + 업적 🟡
```
파일: .claude/phases/10-CHARACTER-ACHIEVEMENT.md
의존: Phase 6, 7 (사운드/UI 이펙트 활용)
```
목표: 아바타 12종 성장, 업적 20개, 코인 샵.

---

## 병렬 실행 맵

```
[병렬 그룹 A]  Phase 6 + 7 + 9  ← 동시 진행
     ↓
[병렬 그룹 B]  Phase 8 + 10     ← 그룹 A 완료 후 동시 진행
```

실행 프롬프트: `.claude/KICKOFF-V2.md` 참조

---

## 실행 프로토콜 (Claude Code용)

### 작업 시작 전 항상 실행:
```bash
# 1. 현재 상태 확인
cd /path/to/flipop
git status
flutter analyze
flutter test

# 2. Phase 파일 읽기
cat .claude/phases/[현재-Phase].md

# 3. 컨텍스트 파일 읽기
cat .claude/context/CURRENT-STATE.md
cat .claude/context/DECISIONS.md
```

### 각 Phase 작업 완료 후:
```bash
# 1. 검증
flutter analyze  # error 0
flutter test     # 전체 통과

# 2. 컨텍스트 업데이트
# .claude/context/CURRENT-STATE.md에 완료 사항 기록
# .claude/context/DECISIONS.md에 설계 결정 기록

# 3. 커밋 (요청 시에만)
git add -A
git commit -m "Phase N: [설명]"
```

### 커밋 규칙 (CLAUDE.md 준수):
- Author: `thingineeer <dlaudwls1203@gmail.com>`
- Co-Authored-By 금지
- 한글 또는 conventional commits
- push는 명시적 요청 시에만

---

## 핵심 제약

1. **시키지 않은 작업 하지 말 것** — Phase 파일에 명시된 것만
2. **과도한 리팩토링 금지** — 최소 변경으로 최대 효과
3. **기존 아키텍처 존중** — Domain/Data/Services/UI 레이어 유지
4. **GameState 불변성 유지** — 모든 변환은 새 인스턴스 반환
5. **4개 언어 l10n 동기화** — 새 문자열 추가 시 ko/en/ja/zh 모두 업데이트

---

## 수익 $50/월 달성 로드맵

### 필요한 수치 (보수적 추정):
- AdMob eCPM: $2~5 (한국/일본 기준)
- 필요 DAU: **200~300명**
- 인당 세션: 3회/일
- 세션당 광고 노출: 배너 상시 + 인터스티셜 1회 + 리워드 0.5회

### 수익 구성 목표:
| 소스 | 월 수익 목표 |
|------|-------------|
| 배너 광고 | $15 |
| 인터스티셜 | $10 |
| 리워드 광고 | $10 |
| IAP (광고 제거) | $10 |
| IAP (코스메틱) | $5 |
| **합계** | **$50** |

---

## 파일 구조

```
.claude/
├── HARNESS.md                  ← 이 파일 (마스터)
├── KICKOFF.md                  ← Phase 1~5 실행 프롬프트
├── KICKOFF-V2.md               ← Phase 6~10 병렬 실행 프롬프트
├── phases/
│   ├── 01-GAME-BALANCE.md      ← ✅ 게임 밸런스
│   ├── 02-ONBOARDING.md        ← ✅ 온보딩
│   ├── 03-MONETIZATION.md      ← ✅ 수익화
│   ├── 04-DIFFERENTIATION.md   ← ✅ 차별화
│   ├── 05-TECH-GROWTH.md       ← ✅ ASO
│   ├── 06-SOUND-HAPTICS-JUICE.md ← 🔴 사운드/햅틱
│   ├── 07-UI-POLISH.md         ← 🔴 UI 폴리시
│   ├── 08-SOCIAL-VIRAL.md      ← 🟡 소셜/바이럴
│   ├── 09-INFRA-MONITORING.md  ← 🔴 인프라
│   └── 10-CHARACTER-ACHIEVEMENT.md ← 🟡 캐릭터/업적
└── context/
    ├── CURRENT-STATE.md         ← 현재 진행 상태
    └── DECISIONS.md             ← 설계 결정 로그
```
