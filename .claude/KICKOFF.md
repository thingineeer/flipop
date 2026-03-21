# FLIPOP 하네스 실행 프롬프트 (Claude Code에 복붙용)

> 아래 프롬프트를 Claude Code에 붙여넣으면 해당 Phase 작업이 시작됩니다.

---

## Phase 1 실행 프롬프트

```
FLIPOP 게임 밸런스를 재설계해야 해.

작업 전 반드시 이 순서대로 읽어:
1. .claude/context/CURRENT-STATE.md
2. .claude/context/DECISIONS.md
3. .claude/HARNESS.md
4. .claude/phases/01-GAME-BALANCE.md

그리고 현재 코드 상태 확인:
- flutter analyze
- flutter test

01-GAME-BALANCE.md의 "구현 순서"를 정확히 따라서 작업해.
각 단계마다 flutter analyze + flutter test 확인하고,
완료되면 .claude/context/CURRENT-STATE.md와 DECISIONS.md 업데이트해.

시키지 않은 작업 하지 마. 과도한 리팩토링 금지.
```

---

## Phase 2 실행 프롬프트

```
FLIPOP 온보딩을 재설계해야 해.

작업 전 반드시 이 순서대로 읽어:
1. .claude/context/CURRENT-STATE.md
2. .claude/context/DECISIONS.md
3. .claude/HARNESS.md
4. .claude/phases/02-ONBOARDING.md

Phase 1이 완료되었는지 CURRENT-STATE.md에서 확인해.
완료 안됐으면 Phase 1부터 해.

02-ONBOARDING.md의 "구현 순서"를 따라 작업해.
l10n 변경 시 4개 ARB 모두 업데이트 + flutter gen-l10n.
완료되면 context 파일들 업데이트해.
```

---

## Phase 3 실행 프롬프트

```
FLIPOP 수익화를 강화해야 해. 목표: 월 $50.

작업 전 반드시 읽어:
1. .claude/context/CURRENT-STATE.md
2. .claude/context/DECISIONS.md
3. .claude/HARNESS.md
4. .claude/phases/03-MONETIZATION.md

Phase 1, 2가 완료되었는지 확인해.
03-MONETIZATION.md의 "구현 순서"를 따라 작업해.
IAP는 in_app_purchase 패키지 사용, 영수증 검증은 Cloud Functions.
첫 3게임은 광고 없음 (온보딩 보호).
완료되면 context 파일들 업데이트해.
```

---

## Phase 4 실행 프롬프트

```
FLIPOP에 차별화 기능을 추가해야 해. 데일리 챌린지 + 특수 블록.

작업 전 반드시 읽어:
1. .claude/context/CURRENT-STATE.md
2. .claude/context/DECISIONS.md
3. .claude/HARNESS.md
4. .claude/phases/04-DIFFERENTIATION.md

Phase 1~3 완료 확인 후 작업 시작.
04-DIFFERENTIATION.md에서 🔴 Must 항목만 구현해.
(데일리 챌린지 + 특수 블록)
🟡 Should, 🟢 Nice-to-have는 하지 마.
완료되면 context 파일들 업데이트해.
```

---

## Phase 5 실행 프롬프트

```
FLIPOP 기술 최적화 + 성장 기반을 구축해야 해.

작업 전 반드시 읽어:
1. .claude/context/CURRENT-STATE.md
2. .claude/context/DECISIONS.md
3. .claude/HARNESS.md
4. .claude/phases/05-TECH-GROWTH.md

Phase 1~4 완료 확인 후 작업 시작.
05-TECH-GROWTH.md의 "구현 순서"를 따라 작업해.
퍼포먼스 측정은 flutter run --profile로.
완료되면 context 파일들 업데이트해.
```

---

## 전체 실행 프롬프트 (한 번에 Phase 1부터)

```
FLIPOP 게임을 전면 개선해야 해.

.claude/HARNESS.md를 읽고 Phase 1부터 순서대로 실행해.
각 Phase의 상세 지시는 .claude/phases/ 폴더에 있어.
작업 전 .claude/context/ 파일들로 현재 상태 확인하고,
작업 후 반드시 context 파일들 업데이트해.

Phase 순서: 1(밸런스) → 2(온보딩) → 3(수익화) → 4(차별화) → 5(최적화)
각 Phase마다 flutter analyze + flutter test 통과 필수.

목표: 월 $50 수익, Day-1 리텐션 40%+, 스토어 평점 4.5+

시작해.
```

---

## 팁: 컨텍스트가 길어질 때

Claude Code의 컨텍스트가 부족해지면:
1. 현재 Phase의 .md 파일만 읽기
2. CURRENT-STATE.md로 이전 Phase 결과 확인
3. 한 Phase씩 나눠서 실행 (위의 개별 프롬프트 사용)

ultrathink 키워드를 사용하면 더 깊은 추론 가능:
```
ultrathink. .claude/phases/01-GAME-BALANCE.md를 읽고
최적의 구현 계획을 세워줘.
```
