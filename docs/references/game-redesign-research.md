# FLIPOP 재설계를 위한 학술/시장 리서치

> 작성일: 2026-03-14
> 목적: FLIPOP 캐주얼 퍼즐 게임의 장기 플레이 리텐션 문제 해결을 위한 학술적/시장 리서치

---

## 현재 문제 진단

FLIPOP은 5x7 그리드에서 블록을 탭하여 인접 블록의 색을 순환시키고, 가로줄을 같은 색으로 완성하면 POP되는 캐주얼 퍼즐 게임이다. 90초 타이머 기반이며, 사용자 피드백에서 "질린다"는 의견이 보고되었다.

이 리서치는 9가지 학술적/시장적 관점에서 문제의 원인과 해결 방향을 탐구한다.

---

## 1. Flow Theory in Games (게임 내 몰입 이론)

### 핵심 논문/연구

| 논문/저작 | 저자 | 연도 | 핵심 내용 |
|-----------|------|------|-----------|
| *Flow: The Psychology of Optimal Experience* | Mihaly Csikszentmihalyi | 1990 | Flow 이론의 원전. 도전과 능력의 균형이 몰입 상태를 만든다 |
| *Flow in Games* (MFA Thesis) | Jenova Chen | 2006 | Flow 이론을 게임 디자인에 적용한 최초의 체계적 논문. Player-centric DDA 방법론 제시 |
| *Using Flow Theory to Design Video Games as Experimental Stimuli* | David Sharek, Eric Wiebe | 2011 | Flow 이론 기반 게임 설계의 실험적 검증 |
| *Towards Finding Flow in Tetris* | (SpringerLink) | 2019 | 사례 기반 추론(CBR)을 활용한 Tetris DDA 구현, 40명 실험 참가자로 Flow 효과 검증 |
| *Measuring Control to Dynamically Induce Flow in Tetris* | (IEEE Transactions) | 2022 | Tetris에서 실시간으로 Flow를 유도하는 제어 측정 방법론 |
| *Rethinking Dynamic Difficulty Adjustment for Video Game Design* | (ScienceDirect) | 2024 | DDA의 Flow 이론 의존성을 비판하고 목표 기반 DDA 프레임워크 제안 |

### 핵심 발견/인사이트

**Flow의 3가지 조건:**
1. **도전-능력 균형 (Challenge-Skill Balance):** 도전이 능력보다 높으면 불안(anxiety), 낮으면 지루함(boredom)이 발생. 그 사이의 "퍼지 안전 지대"에서 Flow가 발생한다.
2. **명확한 목표 (Clear Goals):** 플레이어가 무엇을 해야 하는지 즉시 이해할 수 있어야 한다.
3. **즉각적 피드백 (Immediate Feedback):** 행동의 결과가 바로 보여야 한다.

**DDA의 두 가지 접근법 (Jenova Chen):**
- **시스템 지향 DDA:** 시스템이 자동으로 난이도를 조절. 반복 조절 시 몰입 파괴 위험이 있음.
- **플레이어 지향 DDA:** 플레이어가 무의식적으로 난이도를 선택. 자율성(autonomy) 감각을 보존하면서 Flow를 유지. Chen은 게임 *flOw*에서 플레이어가 자유롭게 깊이를 선택하도록 구현.

**최신 연구 동향 (2024):**
- DDA가 Flow 이론에 과도하게 의존한다는 비판이 제기됨.
- 6단계 DDA 설계 프로세스가 제안됨.
- 머신러닝 및 플레이어 모델링 기법이 DDA 설계에 적극 활용되는 추세.

### FLIPOP 적용 시사점

- **현재 문제:** 90초 고정 타이머 + 고정된 그리드 크기 = 도전-능력 균형의 정적 구조. 숙련 플레이어에게는 너무 쉽고, 초보자에게는 너무 어려울 수 있음.
- **개선 방향:**
  - 플레이어 지향 DDA 도입: 예를 들어, 게임 내에서 플레이어가 무의식적으로 난이도를 조절할 수 있는 메커니즘 (색상 수 증가, 그리드 확장 등)
  - 플레이어 성능에 따른 동적 난이도 조절: 콤보 빈도, 클리어 속도 등을 추적하여 다음 블록 배치를 조정
  - 난이도 곡선이 점진적으로 상승하되, 성취감을 주는 "쉬운 구간"을 주기적으로 배치

---

## 2. Long-term Engagement in Casual/Puzzle Games (캐주얼 퍼즐 게임의 장기 참여)

### 핵심 논문/연구

| 논문/저작 | 저자 | 연도 | 핵심 내용 |
|-----------|------|------|-----------|
| *Casual Games, Cognition, and Play across the Lifespan* | ACM Games: Research and Practice | 2023 | 캐주얼 게임의 인지적/사회적/정서적 효과에 대한 체계적 종합 |
| *Personalized content, engagement, and monetization in a mobile puzzle game* | ScienceDirect | 2024 | 개인화된 DDA가 이탈 위험 플레이어의 리텐션과 지출을 유의하게 증가시킴 |
| *Game Addiction and Game Design: Candy Crush Saga Players* | ResearchGate | 2022 | Candy Crush의 게임 디자인 요소가 중독적 참여를 유발하는 메커니즘 분석 |
| *Personalized game design for improved user retention and monetization in freemium games* | ScienceDirect | 2025 | 개인화 게임 디자인이 프리미엄 게임의 리텐션과 수익에 미치는 영향 |

### 사례 분석: 왜 질리지 않는가?

**Tetris - "영원한 Flow 머신"**
- 자동 난이도 상승: 블록이 점점 빨라지며 도전-능력 균형을 자동 유지
- 무한한 다양성: 매 게임마다 다른 블록 조합으로 신선함 유지
- 뇌의 적응: 4-8주 연습 후 뇌의 포도당 대사율이 정상화되면서 "인지 효율"이 향상, 마스터리 감각 형성
- 명확한 목표와 즉각적 피드백: 줄 클리어 시 즉각적인 보상감

**Candy Crush Saga - "행동 심리학의 교과서"**
- 변동비율 강화 스케줄(Variable Ratio Reinforcement): 슬롯머신과 유사한 랜덤 보상 구조로 도파민 반복 분비
- 에너지 시스템(Hearts): 생활 패턴에 게임을 습관적으로 편입시킴 (3시간마다 하트 재생)
- 소셜 비교: 친구 리더보드를 통한 경쟁심 자극
- 진행감(Progression): 맵 기반 레벨 구조로 "다음 레벨"에 대한 동기 부여
- 운과 실력의 균형: 실패가 "운이 나빴다"로 귀인되어 좌절감 최소화

**2048/Threes - "단순한 규칙, 창발적 복잡성"**
- Threes의 설계 철학: "단순한 게임 시스템에서 흥미로운 복잡성이 자연스럽게 생기도록" 설계
- 4x4 그리드와 4방향 입력이라는 극도의 단순함 속에 NP-hard 수준의 수학적 깊이
- 전 세계에서 6명만이 6144 타일을 본 적 있고, 아무도 Threes를 "클리어"하지 못함 = 무한한 도전 가능성
- 2048은 "2048 타일 도달"이라는 명확한 목표가 초기 동기를 강하게 부여

**Bejeweled - "캐스케이딩의 원조"**
- 2001년 출시 이후 Match-3 장르의 기초를 확립
- 캐스케이딩 콤보가 "예상치 못한 보상"으로 작용하여 도파민 분비 촉진
- 시간 제한 모드(Blitz)부터 무한 모드까지 다양한 플레이 스타일 지원

### FLIPOP 적용 시사점

- **핵심 문제:** FLIPOP은 고정 규칙 + 타이머 기반으로, "항상 같은 경험"을 제공. 변동성과 진행감이 부족.
- **개선 방향:**
  - **변동 보상 도입:** 탭 결과가 때때로 예상치 못한 대형 콤보로 이어지는 "럭키 모먼트" 추가
  - **진행 시스템:** 단순 점수 외에 "마일스톤"이나 레벨 언락 개념 도입
  - **습관 형성 장치:** 일일 도전, 스트릭 보상 등 정기적 복귀 동기 부여
  - **운-실력 균형:** 현재 순수 실력 기반이라 실패 시 좌절감이 클 수 있음. 약간의 랜덤 요소가 리플레이 동기를 높일 수 있음

---

## 3. Match-3 Game Design Patterns (매칭 퍼즐 게임 디자인 패턴)

### 핵심 논문/연구

| 논문/저작 | 저자/출처 | 핵심 내용 |
|-----------|-----------|-----------|
| *Design Analysis: Match-3* | SnoukDesignNotes | Match-3 장르의 핵심 디자인 패턴 체계적 분석 |
| *Bejeweled, Candy Crush and other Match-Three Games are (NP-)Hard* | ResearchGate, 2014 | Match-3 게임의 수학적 복잡도 증명 |
| *Match-3 Level Design Principles* | Gamigion | 레벨 디자인 원칙과 난이도 설계 가이드 |

### 핵심 디자인 패턴

**1. 캐스케이딩 (Cascading)**
- 매치된 블록이 사라지면 위에서 새 블록이 떨어지며, 이것이 새로운 매치를 촉발하는 연쇄 반응
- 플레이어의 한 번의 행동이 여러 번의 보상으로 증폭됨
- "점수는 절대 줄어들지 않고, 항상 올라간다" = 일관된 긍정적 강화

**2. 특수 타일/파워업 (Special Tiles & Power-ups)**
- 4개 매치 = Flame Gem (행/열 클리어)
- 5개 매치 = Star Gem (화면 전체 폭발)
- T자/L자 모양 = Wrapped Gem (주변 클리어)
- 특수 타일 조합 = 초대형 폭발 (보상의 극대화)

**3. 목표 다양화 (Objective Variety)**
- 점수 달성, 특정 아이템 수집, 장애물 제거, 보스 타일 파괴 등
- 같은 핵심 메커니즘이지만 매 레벨 다른 경험을 제공
- 초기 레벨은 관대하게, 중후반 레벨은 새로운 메커니즘과 장애물 추가

**4. 손실 회피 완화 (Loss Aversion Mitigation)**
- 무브가 라이프를 소모하지 않음
- "추가 무브"와 "하트 타이머"로 재도전 기회 제공
- 실패해도 "다음엔 될 거야"라는 낙관적 심리 유지

**5. 의식적 행동 패턴 (Ritual Behavior)**
- 하트 3시간 재생 등 시간 기반 메커니즘이 습관적 복귀 유도
- 예측 가능한 참여 시간대 형성

### FLIPOP 적용 시사점

- **현재 문제:** FLIPOP의 색 순환 메커니즘은 단일 패턴. 캐스케이딩은 있으나 특수 타일/파워업/목표 다양화가 없음.
- **개선 방향:**
  - **특수 블록 도입:** 대형 콤보 시 특수 블록 생성 (전체 행 클리어, 색상 변환 등)
  - **목표 다양화:** 매 게임/라운드마다 다른 목표 제시 ("빨간색 3줄 클리어", "30초 내 5콤보" 등)
  - **장애물 메커니즘:** 얼음 블록, 잠금 블록 등으로 전략적 깊이 추가
  - **"럭키 캐스케이드":** 클리어 후 떨어지는 블록이 추가 매치를 만들 때 보너스 강화

---

## 4. Procedural Content Generation (절차적 콘텐츠 생성)

### 핵심 논문/연구

| 논문/저작 | 저자 | 연도 | 핵심 내용 |
|-----------|------|------|-----------|
| *Procedural Content Generation in Games: A Survey with Insights on Emerging LLM Integration* | arXiv | 2024 | 207편 논문 분석, PCG 방법론 체계화, LLM 통합 동향 |
| *Procedural Content Generation for Games: A Survey* | ACM TOMM / Hendrikx et al. | 2013 | PCG의 기초 분류 체계 수립 |
| *Procedural Level Generation with Difficulty Level Estimation for Puzzle Games* | SpringerLink / ICCS 2021 | 퍼즐 게임 레벨의 절차적 생성 + 난이도 추정 |
| *Procedural Puzzle Generation: A Survey* | Academia.edu | 2019 | 절차적 퍼즐 생성의 포괄적 서베이 |
| *Improving Conditional Level Generation using Automated Validation in Match-3 Games* | arXiv | 2024 | Match-3 레벨의 조건부 생성과 자동 검증 (Avalon 방법) |
| *Puzzle-Level Generation With WFC Algorithms* | ResearchGate | 2025 | WaveFunctionCollapse를 활용한 퍼즐 레벨 생성과 풀이 가능성 학습 |
| *Efficient Difficulty Level Balancing in Match-3 Puzzle Games* | MDPI Electronics | 2023 | PPO와 SAC 강화학습 알고리즘을 활용한 Match-3 난이도 밸런싱 |

### 핵심 PCG 방법론

1. **탐색 기반 (Search-based):** 진화 알고리즘, Monte Carlo Tree Search, WaveFunctionCollapse 등. 적합성 함수로 생성 품질 평가.
2. **머신러닝 기반:** GAN, RNN/LSTM, Transformer, 강화학습. 기존 레벨 데이터에서 패턴을 학습.
3. **제약 충족 (Constraint Satisfaction):** 풀이 가능성, 난이도 범위 등의 제약 조건을 만족하는 레벨 생성.
4. **LLM 기반 (최신):** 2023년에만 13편의 논문 발표. MarioGPT (텍스트 프롬프트 기반 마리오 레벨 생성), Dungeon 2 (무한 텍스트 어드벤처) 등.

### 핵심 발견

- Match-3에서는 "충분한 무브가 주어지면 거의 모든 레이아웃이 풀이 가능"하지만, 제한된 무브 수에서의 풀이 가능성이 핵심 설계 과제.
- 풀이 가능한 퍼즐을 "바람직하지 않은 풀이가 없이" 생성하는 것은 NP-complete 탐색 문제로 공식화됨.
- 레벨 생성과 3D 게임 적용 사이에 큰 연구 격차 존재. 산업-학계 간 갭도 큰 문제.

### FLIPOP 적용 시사점

- **현재 문제:** 매 게임이 동일한 5x7 그리드에서 랜덤 색상 배치로 시작. 구조적 다양성 부족.
- **개선 방향:**
  - **그리드 변형:** 매 라운드마다 그리드 형태를 변경 (L자, T자, 십자 등)
  - **장애물 배치 생성:** 절차적으로 얼음 블록, 잠금 블록 위치 결정
  - **난이도 적응형 생성:** 플레이어 성능 데이터를 기반으로 다음 게임의 초기 배치 조정
  - **일일 퍼즐:** PCG로 매일 새로운 "오늘의 퍼즐" 생성. Wordle처럼 공유 가능한 결과
  - **제약 충족 기반 검증:** 생성된 퍼즐이 반드시 풀이 가능하도록 보장

---

## 5. Intrinsic vs Extrinsic Motivation (내재적 vs 외재적 동기)

### 핵심 논문/연구

| 논문/저작 | 저자 | 연도 | 핵심 내용 |
|-----------|------|------|-----------|
| *Self-Determination Theory and the Facilitation of Intrinsic Motivation, Social Development, and Well-Being* | Richard M. Ryan, Edward L. Deci | 2000 | SDT 이론의 핵심 논문. 3가지 기본 심리적 욕구(자율성, 유능감, 관계성) 제시 |
| *Intrinsic Motivation and Self-Determination in Human Behavior* | Deci & Ryan | 1985 | SDT 이론의 기초 저서 |
| *The Motivational Pull of Video Games: A Self-Determination Theory Approach* | Ryan, Rigby, Przybylski | 2006 | SDT를 비디오 게임에 적용한 최초의 실증 연구. PENS 모델 개발 |
| *A Motivational Model of Video Game Engagement* | Przybylski, Rigby, Ryan | 2010 | 비디오 게임 참여의 동기 모델 확장 |

### Self-Determination Theory (SDT)의 3가지 기본 욕구

1. **자율성 (Autonomy):** 자기 행동을 스스로 조절할 수 있다는 감각. 게임에서는 선택의 자유, 비선형 진행 등으로 구현.
2. **유능감 (Competence):** 환경과의 상호작용에서 효과성과 마스터리를 인지하는 것. 게임에서는 기술 향상, 난이도 곡선, 명확한 피드백으로 구현.
3. **관계성 (Relatedness):** 의미 있는 사회적 연결과 소속감에 대한 욕구. 게임에서는 멀티플레이어, 소셜 기능, 길드 등으로 구현.

### 핵심 발견

- **외재적 보상의 역설:** 외재적 보상(돈, 점수)은 내재적 동기를 약화시킬 수 있다 (Deci & Ryan, 원전).
- **게임에서의 SDT 적용 (Ryan, Rigby, Przybylski 2006):**
  - 자율성과 유능감이 게임 즐거움, 선호도, 웰빙 변화와 유의하게 연관
  - 직관적 게임 컨트롤이 유능감/자율성 인지와 관련
  - 성공적인 게임은 자율성, 유능감, 관계성의 욕구를 강하게 충족
  - PENS (Player Experience of Need Satisfaction) 측정 도구 개발
- **내재적 동기가 지속적 참여의 핵심:** 내재적 동기는 "그 활동 자체가 흥미롭고 만족스럽기 때문에" 시작하는 것. 외재적 목표(외부 보상)와 대비됨.

### FLIPOP 적용 시사점

- **현재 문제:**
  - 자율성: 탭할 위치 선택만 가능. 전략적 선택의 폭이 좁음.
  - 유능감: 콤보와 점수로 피드백 제공하나, "마스터리 경로"가 불명확.
  - 관계성: 리더보드 외에 소셜 기능 부재.
- **개선 방향:**
  - **자율성 강화:** 탭 대상 선택 외에도, "어떤 특수 능력을 사용할지", "어떤 목표를 추구할지" 등 전략적 선택지 확대
  - **유능감 강화:** 명확한 스킬 진행 경로 (초보 → 중급 → 고급 전략), 마스터리 표시 (달성 뱃지, 스킬 레벨)
  - **관계성 강화:** 일일 퍼즐 공유, 친구와 점수 비교, 비동기 대전
  - **외재적 보상 최소화:** 리워드 광고 의존을 줄이고, 게임 자체의 재미(내재적 동기)에 집중
  - **직관적 컨트롤:** 현재의 탭 메커니즘은 이미 직관적이므로 유지하되, 새로운 메커니즘 추가 시 학습 곡선 최소화

---

## 6. Fairness in Competitive Casual Games (경쟁적 캐주얼 게임의 공정성)

### 핵심 논문/연구

| 논문/저작 | 저자 | 연도 | 핵심 내용 |
|-----------|------|------|-----------|
| *Pay to Win or Pay to Cheat: How Players of Competitive Online Games Perceive Fairness of In-Game Purchases* | Yvette Wohn et al. | 2022 | ACM CHI PLAY 발표. 경쟁 게임 내 구매의 공정성 인식 연구 |
| *Playing to Pay: Interplay of Monetization and Retention Strategies in Korean Games* | arXiv | 2024 | 한국 게임의 수익화와 리텐션 전략 상호작용 분석 |
| Skill-Based Matchmaking 연구 (262,000+ 플레이어, 6백만 매치 분석) | 2024 | 실력 격차가 이탈률에 미치는 영향 실증 분석 |

### 핵심 발견

**공정성 인식의 구조:**
- 플레이어 대다수는 공정성을 "프리미엄 콘텐츠가 경쟁 능력이나 승리 확률에 영향을 미치지 않아야 한다"로 정의
- **수용 가능한 구매:** 코스메틱 아이템, 편의 기능 (게임플레이에 영향 없는 것)
- **거부되는 구매:** 경쟁 우위를 제공하는 아이템 ("pay-to-win = pay-to-cheat"으로 인식)
- 장르별 차이: 스포츠 게임은 성능 영향 구매에 관대, 경쟁 온라인 게임은 가장 엄격한 공정성 기준 적용

**스킬 기반 매칭의 중요성:**
- 262,000명 플레이어, 600만 매치 분석 결과: 큰 실력 격차가 이탈을 유의하게 증가시킴
- 균형 잡힌 매칭이 리텐션 개선에 핵심적

**Pay-to-Win의 파괴적 효과:**
- 리더보드가 "경매장"으로 전락
- 실력에 의존하는 플레이어가 이탈
- 커뮤니티 신뢰 침식과 이탈률 급증
- 수익화 불균형이 "돈을 쓸 수 있는 사람만 핵심 콘텐츠를 즐기는" 피드백 루프 생성

### FLIPOP 적용 시사점

- **현재 강점:** FLIPOP은 리워드 광고(이어하기, 시간 추가, 점수 2배)를 각 게임당 1회로 제한. Pay-to-win 요소가 최소화되어 있음.
- **주의 사항:**
  - 리워드 광고로 얻는 "이어하기"와 "점수 2배"가 리더보드 공정성에 영향을 줄 수 있음
  - 리더보드에서 광고 시청 여부를 표시하거나, "순수 실력 리더보드"와 "광고 사용 리더보드"를 분리하는 것을 고려
- **개선 방향:**
  - 리더보드의 의미와 가치를 강화: 시즌제, 티어 시스템, 주간 랭킹 등
  - 공정한 경쟁 환경 명시적 보장: "이 리더보드는 순수 실력 기반입니다" 같은 메시지
  - 코스메틱 요소를 통한 수익화: 블록 스킨, 테마, 이펙트 등 게임플레이에 영향 없는 아이템

---

## 7. Player Retention and Churn (플레이어 리텐션과 이탈)

### 핵심 논문/연구 및 데이터

| 출처 | 연도 | 핵심 내용 |
|------|------|-----------|
| GameAnalytics Q1 2024 Report | 2024 | 모바일 게임 D1/D7/D30 벤치마크 (26-28% / 8% / 3%) |
| Solsten Blog: True Drivers of D1, D7, D30 | 2024 | 각 리텐션 단계별 핵심 요인 분석 |
| Business of Apps: Mobile Game Retention Rates | 2025 | iOS vs Android 리텐션 차이 (iOS D1: 35.7%, Android: 27.5%) |
| Mistplay: Mobile Game Retention Benchmarks | 2024 | 장르별 리텐션 벤치마크 |
| Segwise: Mobile Gaming User Retention Strategies | 2024 | 리텐션 개선 전략 체계화 |

### 리텐션 벤치마크 (2024)

| 지표 | 전체 평균 | 캐주얼 게임 (중앙값) | 상위 25% | 전통적 목표 |
|------|-----------|---------------------|----------|------------|
| **D1** | 26-28% | ~20% | 31-33% (iOS) | 40% |
| **D7** | ~8% | 3-4% | 5-11% | 20% |
| **D30** | ~3% | <1-4% | 1-5% | 10% |

- iOS가 Android보다 일관되게 높은 리텐션: D1에서 iOS 35.7% vs Android 27.5%
- D1 80-90% 이탈, D30까지 97-99% 이탈이 업계 표준

### 각 단계별 핵심 드라이버

**D1 리텐션 (첫인상):**
- 순간순간의 게임플레이 품질
- 마케팅 메시지와 실제 게임 경험의 일치
- 첫 사용자 경험(FTUE)과 튜토리얼의 효과
- D1이 모든 후속 리텐션의 천장을 결정 (D1 20% = D7 최대 4%)

**D7 리텐션 (진행 시스템):**
- 의미 있는 보상이 있는 진행 시스템
- 소셜 기능과 멀티플레이어 메커니즘
- 튜토리얼 너머의 핵심 게임플레이 접근
- D1 높고 D7 낮으면 = 콘텐츠 소진, 진행 보상 부족, 반복 작업 느낌

**D30 리텐션 (장기 생존):**
- 시간적/금전적 투자의 일상 통합
- 한시적 이벤트의 긴급감
- 소셜 압력 메커니즘
- 게임플레이 다양성과 흥분감
- "보통 D20 중반에서 리텐션 곡선이 평탄해짐" = D30이 1년 참여의 강한 예측 변수

### FLIPOP 적용 시사점

- **현재 추정 리텐션 위치:** 캐주얼 퍼즐의 평균 이하일 가능성 (단일 게임 모드, 진행 시스템 부재)
- **D1 개선:** FTUE 최적화 (첫 게임에서 확실한 성취감), 튜토리얼 개선
- **D7 개선 (가장 중요):**
  - 진행 시스템 도입: 레벨/마일스톤/언락 요소
  - 일일 도전과 연속 플레이 보상 (스트릭)
  - "7일차에도 새로운 것이 있다"는 느낌
- **D30 개선:**
  - 시즌/이벤트 시스템
  - 소셜 기능 (친구 초대, 비동기 대전)
  - 정기적 콘텐츠 업데이트 (새 모드, 테마)
  - 수집 시스템/메타 레이어 추가

---

## 8. Scoring System Design (점수 시스템 디자인)

### 핵심 논문/연구

| 논문/저작 | 저자 | 연도 | 핵심 내용 |
|-----------|------|------|-----------|
| *Design Aspects of Scoring Systems in Game* | SCIRP | 2017 | 점수 시스템의 3가지 핵심 설계 차원(인지 가능성, 통제 가능성, 성취 관계) 분석. 12가지 점수 메커니즘 분류 |
| *The Motivational Power of Levels and High Scores* | ACM Games: Research and Practice | 2025 | 레벨과 하이스코어가 사용자 경험과 지속성에 미치는 영향 |

### 점수 시스템의 3가지 설계 차원

1. **인지 가능성 (Perceivability):** 플레이어가 점수를 얼마나 잘 인식하는가. 퍼즐 게임은 높은 인지 가능성이 효과적 (Tetris처럼 점수가 항상 표시).
2. **통제 가능성 (Controllability):** 플레이어가 점수를 얼마나 의도적으로 조작할 수 있는가. 높은 통제 가능성은 전략적 깊이를 부여.
3. **성취 관계 (Relation to Achievement):** 점수가 플레이어 목표에 얼마나 의미 있게 연결되는가. 성취 지향적 시스템이 반복 플레이를 유도.

### 핵심 발견

- **"점수 기록은 게임 플레이를 즐거운 경험으로 만드는 중요한 부분"**
- **성과 진행 (Performance Progression):** 아케이드/캐주얼 게임에서 가장 효과적. 이전 기록을 뛰어넘으려는 시도가 자연스러운 난이도 상승과 진행감을 제공.
- **Tetris의 역설:** 하이스코어 달성이 게임의 주요 목표가 아님에도, 많은 플레이어가 하이스코어에 게임 목표보다 더 큰 중요성을 부여.
- **변동 보상의 우월성:** 예측 가능한 보상은 시간이 지나면 습관화되어 동기 부여 효과 감소. 예측 불가능한 보상(variable rewards)이 더 강한 도파민 분비를 유발하여 동기 유지.

### 12가지 점수 메커니즘

최고 점수(top score), 체력(health), 평가(evaluation), 경험치(XP), 능력(abilities), 재능(talents), 자원(resources), 도덕 계산(moral calculus), 거래(trade), 플롯(plot), Pong형, 타이머

### FLIPOP 적용 시사점

- **현재 문제:** 단일 점수 + 타이머 = 단조로운 보상 구조. "하이스코어 갱신" 외에 목표가 없음.
- **개선 방향:**
  - **다층 점수 체계:** 기본 점수 외에 콤보 점수, 스피드 보너스, 특수 패턴 보너스 등 별도 추적
  - **마일스톤 시스템:** 특정 점수 도달 시 영구적 보상 (스킨, 타이틀, 뱃지)
  - **변동 보상 통합:** 때때로 "보너스 타임", "더블 스코어 존" 등 예측 불가능한 보상 이벤트 발생
  - **비교 지표 다양화:** 총 점수 외에 "최고 콤보", "한 게임 최다 클리어", "가장 빠른 첫 클리어" 등 다양한 기록 추적
  - **점수 통제 가능성 강화:** 의도적 전략(큰 콤보를 위해 기다리기 vs 빠른 소규모 클리어)이 점수에 차별적 영향을 미치도록

---

## 9. Game Feel / Juice (게임 감각 / 주스)

### 핵심 논문/연구

| 논문/저작 | 저자 | 연도 | 핵심 내용 |
|-----------|------|------|-----------|
| *Designing Game Feel: A Survey* | Martin Pichlmair, Mads Johansen | 2021 | IEEE Transactions on Games 발표. 200+ 소스 분석. Game Feel의 3가지 도메인(물리성, 증폭, 지원) 정의 |
| *How does Juicy Game Feedback Motivate? Testing Curiosity, Competence, and Effectance* | Hicks et al. | 2024 | ACM CHI 2024 발표. 40+32명 대상 실험. Juice의 호기심/유능감/효과감 영향 검증 |
| *That Sound's Juicy! Exploring Juicy Audio Effects in Video Games* | HAL/INRIA | 2023 | 주시(Juicy) 오디오의 존재감과 몰입에 대한 유의한 효과 검증 |
| *Juicy Game Design: Understanding the Impact of Visual Embellishments on Player Experience* | ACM CHI PLAY | 2019 | 시각적 장식이 플레이어 경험에 미치는 영향 |
| *Good Game Feel: An Empirically Grounded Framework for Juicy Design* | Hicks, Dickinson | Semantic Scholar | 경험적으로 근거한 Juicy 디자인 프레임워크 |
| Screen Shake & Hit Stop 연구 | Oreate AI | 2024 | 화면 흔들림과 히트스톱의 메커니즘과 체감 영향 정량 분석 |

### Game Feel의 3가지 도메인 (Pichlmair & Johansen)

1. **물리성 (Physicality):** 게임 오브젝트의 물리적 느낌. 폴리싱 방법 = **튜닝(Tuning)**. 결과: 일관성, 예측 가능성, 움직임 기반 레벨 디자인.
2. **증폭 (Amplification):** 행동 결과의 과장된 피드백. 폴리싱 방법 = **주싱(Juicing)**. 결과: 임파워먼트(empowerment)와 피드백 명확성.
3. **지원 (Support):** 플레이어 행동을 돕는 시스템. 폴리싱 방법 = **스트림라이닝(Streamlining)**.

### Juice의 핵심 구성 요소

**화면 흔들림 (Screen Shake):**
- 전정기관 반응을 자극하여 공격 강도에 대한 직관적 이해 강화
- "두 세그먼트의 화면 흔들림 사이에 약 0.1초의 정지 프레임을 추가하면 인지 강도가 약 30% 증가"
- 타이밍 제어가 핵심

**히트스톱 (Hit Stop):**
- 충돌 시점에 게임플레이를 일시 정지하여 뇌의 ~100ms 인지 지연을 활용
- "떠다니는 느낌" 해소, 공격의 무게감과 견고함 강화
- 0.15초 초과 시 만족도 감소 (속도 지향 장르)

**파티클 이펙트:**
- 기본 화면 흔들림 + 파티클 + 오디오의 다층 피드백이 최대 효과

**오디오 (Juicy Audio):**
- Juicy 오디오가 존재감(presence)에 유의한 효과: 몰입과 감각적 충실도 모두 향상
- "과장된 중복 오디오/비주얼 피드백"이 더 나은 플레이어 경험 생성

**햅틱 피드백:**
- 72% 참가자가 진동 피드백이 게임 경험을 "대부분의 시간" 향상시킨다고 응답 (2006 설문)
- 중간 진동 지속 시간이 최대 보상 반응을 유발 (너무 짧거나 길면 효과 감소)
- 게임 내 몰입감 향상, 특히 환경 인식에 기여

### 실험적 발견

- **Hicks et al. (2024, CHI):** 3개 게임에서 40+32명 대상 실험.
  - 시각적 Juice가 미적 매력(aesthetic appeal)에 긍정적 효과 (모든 연구에서 일관)
  - 사용성(usability)이나 성능(performance)에는 영향 없음
  - 호기심(curiosity), 유능감(competence), 존재감(presence/immersion)은 하나의 게임에서만 효과 관찰
- **핵심 통찰:** Juice는 "양날의 검" — 긍정적/부정적 효과 모두 가능. **적정 수준**이 핵심이며, 과도한 Juice는 오히려 해로울 수 있음.
- 화면 흔들림 + 히트스톱 결합 시 최대 시너지 효과는 약 75% 강도에서 발생, 이후 수확 체감.

### FLIPOP 적용 시사점

- **현재 상태:** 기본적인 시각 피드백은 있으나, 체계적인 Juice 시스템 부재 가능성.
- **개선 방향:**
  - **블록 POP 시 Juice 강화:**
    - 화면 미세 흔들림 (0.05-0.1초)
    - 색상 파티클 폭발
    - 만족감 있는 효과음 (팝핑, 크리스탈 소리)
    - 햅틱 피드백 (짧고 선명한 진동)
  - **콤보 시 스케일링 Juice:**
    - 2콤보: 기본 파티클 + 효과음
    - 3콤보: 화면 흔들림 + 강화 파티클
    - 5+콤보: 풀스크린 이펙트 + 강한 햅틱 + 특수 사운드
  - **인터랙션 Juice:**
    - 블록 탭 시 "눌림" 애니메이션
    - 색 변경 시 부드러운 전환 이펙트
    - 매치 가능한 상태에서 블록 미세 발광
  - **과도한 Juice 경계:** 75% 강도 규칙 준수. 퍼즐 게임에서는 명확성이 최우선이므로, 이펙트가 게임 판독성을 해치지 않도록 주의

---

## 종합 권고사항

FLIPOP의 "질림" 문제는 단일 원인이 아닌 복합적 요인에서 비롯된다. 리서치 결과를 종합하면:

### 1순위 (즉시 개선 가능)
| 영역 | 조치 | 근거 |
|------|------|------|
| Game Feel / Juice | POP, 콤보, 인터랙션에 다층 피드백 추가 | "Low Cost, High Impact" — 개발 비용 낮고 체감 효과 큼 (Section 9) |
| 점수 시스템 | 다층 점수, 마일스톤, 변동 보상 도입 | 변동 보상이 예측 가능 보상보다 더 강한 동기 유지 (Section 8) |
| 난이도 곡선 | 플레이어 성능 추적 기반 동적 조절 | Flow 이론: 도전-능력 균형이 몰입의 핵심 (Section 1) |

### 2순위 (중기 개선)
| 영역 | 조치 | 근거 |
|------|------|------|
| 목표 다양화 | 매 게임 다른 목표/미션 제시 | Match-3 패턴: 같은 메커니즘, 다른 목표 = 신선함 (Section 3) |
| 진행 시스템 | 레벨, 마일스톤, 언락, 수집 시스템 | D7 리텐션의 핵심 드라이버 (Section 7), 메타 레이어가 리텐션 70% 향상 (Section 2) |
| 특수 블록/파워업 | 대형 매치 시 특수 블록 생성 | Match-3 디자인 패턴의 핵심 요소 (Section 3) |

### 3순위 (장기 개선)
| 영역 | 조치 | 근거 |
|------|------|------|
| PCG 일일 퍼즐 | 매일 새로운 퍼즐 자동 생성 | 무한 리플레이 가치 + 소셜 공유 (Section 4) |
| 소셜 기능 | 비동기 대전, 일일 퍼즐 공유, 친구 비교 | 관계성 욕구 충족 (Section 5), D30 리텐션 핵심 (Section 7) |
| 시즌/이벤트 | 주기적 테마, 한시적 이벤트 | D30+ 리텐션의 핵심 드라이버 (Section 7) |
| 공정성 보장 | 순수 실력 리더보드 분리, 코스메틱 수익화 | 공정성 인식이 리텐션에 직결 (Section 6) |

---

## 참고 문헌 및 출처

### 학술 논문
- Csikszentmihalyi, M. (1990). *Flow: The Psychology of Optimal Experience*
- [Chen, J. (2006). *Flow in Games* (MFA Thesis, USC)](https://www.jenovachen.com/flowingames/Flow_in_games_final.pdf)
- [Ryan, R.M., Deci, E.L. (2000). *Self-Determination Theory and the Facilitation of Intrinsic Motivation*](https://selfdeterminationtheory.org/SDT/documents/2000_RyanDeci_SDT.pdf)
- [Ryan, R.M., Rigby, C.S., Przybylski, A. (2006). *The Motivational Pull of Video Games: A Self-Determination Theory Approach*](https://link.springer.com/article/10.1007/s11031-006-9051-8)
- [Przybylski, A., Rigby, C.S., Ryan, R.M. (2010). *A Motivational Model of Video Game Engagement*](https://journals.sagepub.com/doi/abs/10.1037/a0019440)
- [Pichlmair, M., Johansen, M. (2021). *Designing Game Feel: A Survey*. IEEE Transactions on Games](https://ieeexplore.ieee.org/document/9399794/)
- [Hicks et al. (2024). *How does Juicy Game Feedback Motivate?* ACM CHI 2024](https://dl.acm.org/doi/10.1145/3613904.3642656)
- [Wohn, Y. et al. (2022). *Pay to Win or Pay to Cheat*. ACM CHI PLAY](https://dl.acm.org/doi/abs/10.1145/3549510)
- [PCG Survey with LLM Integration (2024). arXiv](https://arxiv.org/html/2410.15644v1)
- [Procedural Level Generation with Difficulty Estimation (2021). SpringerLink/ICCS](https://link.springer.com/chapter/10.1007/978-3-030-77977-1_9)
- [Avalon: Improving Conditional Level Generation in Match-3 (2024). arXiv](https://arxiv.org/html/2409.06349v2)
- [Efficient Difficulty Balancing in Match-3 with PPO/SAC (2023). MDPI](https://www.mdpi.com/2079-9292/12/21/4456)
- [Towards Finding Flow in Tetris (2019). SpringerLink](https://link.springer.com/chapter/10.1007/978-3-030-29249-2_18)
- [DDA in Computer Games: A Review (2018). Wiley](https://onlinelibrary.wiley.com/doi/10.1155/2018/5681652)
- [Exploring DDA Methods for Video Games (2024). MDPI](https://www.mdpi.com/2813-2084/3/2/12)
- [Rethinking DDA for Video Game Design (2024). ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0262407914610691)
- [Casual Games, Cognition, and Play across the Lifespan (2023). ACM](https://dl.acm.org/doi/10.1145/3594534)
- [Personalized content, engagement, and monetization in mobile puzzle games (2024). ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0167718724000833)
- [Design Aspects of Scoring Systems in Game (2017). SCIRP](https://www.scirp.org/html/3-1250124_73535.htm)
- [Threes!, Fives, 1024!, and 2048 are Hard. ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0304397518301798)
- [Juicy Audio Effects in Video Games (2023). HAL/INRIA](https://inria.hal.science/hal-04144377/document)
- [Haptic Feedback in First Person Shooter Games. ACM](https://dl.acm.org/doi/fullHtml/10.1145/3552327.3552333)
- [Haptic Rewards: Mobile Vibrations and Consumer Choice (2025). Oxford Academic](https://academic.oup.com/jcr/advance-article/doi/10.1093/jcr/ucaf025/8120234)
- [Playing to Pay: Monetization and Retention in Korean Games (2024). arXiv](https://arxiv.org/pdf/2504.10714)
- [Dopamine Loops and Player Retention. JCM](https://jcoma.com/index.php/JCM/article/download/352/192)

### 업계 리포트/분석
- [GameAnalytics Q1 2024: Mobile Games Benchmarks](https://www.gameanalytics.com/reports/mobile-games-benchmarks-q1-2024)
- [Solsten: True Drivers of D1, D7, D30 Retention](https://solsten.io/blog/d1-d7-d30-retention-in-gaming)
- [Business of Apps: Mobile Game Retention Rates 2025](https://www.businessofapps.com/data/mobile-game-retention-rates/)
- [Mistplay: Mobile Game Retention Benchmarks](https://business.mistplay.com/resources/mobile-game-retention-benchmarks)
- [GameAnalytics: Reducing User Churn](https://www.gameanalytics.com/blog/reducing-user-churn)
- [Segwise: Mobile Gaming Retention Strategies](https://segwise.ai/blog/mobile-gaming-app-user-retention-strategies)
- [Rethinking Progression in Mobile Puzzle Games. Gamasutra](https://www.gamedeveloper.com/design/rethinking-progression-in-mobile-puzzle-games)
- [6 Games with Successful Meta Mechanics. GameAnalytics](https://www.gameanalytics.com/blog/six-games-that-successfully-layer-in-meta-mechanics)

### 디자인 분석/블로그
- [Match-3 Design Analysis. SnoukDesignNotes](https://snoukdesignnotes.blog/2018/06/21/design-analysis-match-3/)
- [Juice in Game Design. Blood Moon Interactive](https://www.bloodmooninteractive.com/articles/juice.html)
- [Screen Shake and Hit Stop Effects Research. Oreate AI](https://www.oreateai.com/blog/research-on-the-mechanism-of-screen-shake-and-hit-stop-effects-on-game-impact/decf24388684845c565d0cc48f09fa24)
- [Candy Crush Addiction Analysis. Yukai Chou](https://yukaichou.com/gamification-study/game-mechanics-research-candy-crush-addicting/)
- [Threes Design Emails (Design Process)](https://asherv.com/threes/threemails/)
- [Udonis: Progression Systems in Mobile Games](https://www.blog.udonis.co/mobile-marketing/mobile-games/progression-systems)
- [Udonis: Collection Systems in Mobile Games](https://www.blog.udonis.co/mobile-marketing/mobile-games/collection-systems-mobile-games)
