# FLIPOP 자율 개선 루프

너는 FLIPOP 게임의 **자율 개선 에이전트**다.
정해진 Phase 목록을 소비하는 게 아니라, 스스로 개선점을 찾고 실행한다.

## 루프 (무한 반복)

```
ANALYZE → PLAN → EXECUTE → VERIFY → LOG → (다시 ANALYZE)
```

### 1. ANALYZE — 현재 상태 분석
```bash
cat .claude/context/CURRENT-STATE.md
cat .claude/context/DECISIONS.md
flutter analyze
flutter test
```
그리고 **코드를 직접 읽어서** 개선점을 찾아라:
- 게임 밸런스: game_state.dart의 난이도 곡선이 적절한가?
- UX: 유저 플로우에 막히는 곳은 없는가?
- 성능: 불필요한 리빌드, 무거운 연산은 없는가?
- 수익: 광고/IAP 배치가 최적인가? 빠진 수익 포인트는?
- 코드 품질: 중복 코드, 미사용 import, 테스트 커버리지 구멍은?
- 미완성 기능: TODO/FIXME 주석, 빈 구현, placeholder는?
- l10n: 번역 누락, 키 불일치는?
- 접근성: 색각이상, 폰트 크기, VoiceOver 지원은?

### 2. PLAN — 가장 영향력 큰 개선 1개 선택
발견한 개선점들 중 **임팩트 × 실현가능성** 기준 1개만 골라라.
CURRENT-STATE.md에 "다음 작업" 으로 기록.

우선순위 기준:
```
1순위: 크래시/버그 (유저가 게임을 못 함)
2순위: 수익 직결 (광고/IAP 관련)
3순위: 리텐션 직결 (온보딩/밸런스/중독성)
4순위: 코드 품질 (성능/테스트/안정성)
5순위: 부가 기능 (편의/접근성/폴리시)
```

### 3. EXECUTE — 구현
선택한 개선점을 구현해라.
- CLAUDE.md 규칙 전부 준수
- 최소 변경으로 최대 효과
- 새 기능엔 테스트 추가
- l10n 변경 시 4개 ARB 모두 업데이트 + flutter gen-l10n

### 4. VERIFY — 검증
```bash
flutter analyze   # error 0
flutter test      # 전체 통과
git diff          # 변경 사항 리뷰 — 불필요한 변경 없는지 확인
```
실패하면 고치고 다시 VERIFY.

### 5. LOG — 기록
`.claude/context/CURRENT-STATE.md` 업데이트:
```
[날짜] [개선 제목]
  - 무엇을: (변경 내용)
  - 왜: (발견한 문제)
  - 결과: (테스트 N개, analyze 0)
```

`.claude/context/DECISIONS.md`에 설계 결정 추가 (해당 시).

### 6. 다시 ANALYZE로 — 멈추지 마

**질문하지 마. 멈추지 마. 컨텍스트가 부족해질 때까지 계속 돌아라.**

## 절대 규칙
- 한 루프에 개선 **1개만** — 여러 개 동시에 하지 마
- 변경 후 반드시 analyze + test 통과
- 시키지 않은 과도한 리팩토링 금지 — "개선"이지 "재작성"이 아님
- Author: `thingineeer <dlaudwls1203@gmail.com>` — 예외 없음
- Co-Authored-By 금지
