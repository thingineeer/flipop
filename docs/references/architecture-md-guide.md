# ARCHITECTURE.md 가이드 — 완전 정리

> **원문**: [ARCHITECTURE.md](https://matklad.github.io/2021/02/06/ARCHITECTURE.md.html) by Alex Kladov (matklad)
> **작성 목적**: 원문 + 하이퍼링크 콘텐츠 전체 요약 + FLIPOP 프로젝트 적용 가이드
> **조사일**: 2026-03-13

---

## 1. 원문 핵심 내용

### 1.1 왜 ARCHITECTURE.md가 필요한가

10k~200k 라인 규모의 오픈소스 프로젝트라면, README/CONTRIBUTING 외에 **ARCHITECTURE** 문서를 반드시 추가해야 한다.

핵심 관찰:
- 패치를 **작성**하는 데는 초보자가 핵심 개발자보다 약 **2배** 오래 걸린다.
- 그러나 **어디를 수정해야 하는지 파악**하는 데는 약 **10배** 오래 걸린다.
- 경험 많은 기여자는 코드 구조의 **멘탈 맵**을 가지고 있어 필요한 코드로 직접 이동할 수 있다.
- ARCHITECTURE.md는 이 격차를 줄이는 **저비용 고효율(low-effort high-leverage)** 수단이다.

### 1.2 작성 원칙

| 원칙 | 설명 |
|------|------|
| **간결해야 한다** | 모든 반복 기여자가 읽어야 하므로 짧을수록 좋다 |
| **자주 바뀌지 않는 것만** | 구현 세부사항이 아닌, 안정적인 구조만 기술 |
| **구현 세부사항 배제** | 별도 문서 또는 인라인 주석에 위임 |
| **심볼 검색 지원** | 직접 링크 대신 **파일/모듈/타입 이름을 명시**하여 심볼 검색으로 찾게 한다 |

### 1.3 문서 구조 권장사항

1. **고수준 개요(High-level Overview)**: 이 프로젝트가 해결하는 문제 설명
2. **코드맵(Codemap)**: 거칠게(coarse-grained) 모듈과 그 관계를 나열
   - "X를 하는 것은 어디에 있는가?" 에 답해야 한다
   - "이것은 무엇을 하는가?" 에 답해야 한다
3. **아키텍처 불변 규칙(Architectural Invariants)**:
   - 특히 **"부재(absence)" 제약** 을 명시적으로 강조
   - 예: "이 레이어는 절대로 X에 의존하지 않는다"
4. **레이어 경계(Layer Boundaries)**: 시스템과 레이어 사이의 경계를 강조
5. **횡단 관심사(Cross-cutting Concerns)**: 에러 처리, 로깅, 테스트 전략 등

---

## 2. 참조 링크 콘텐츠 전체 요약

### 2.1 rust-analyzer의 ARCHITECTURE.md (실전 예시)

> **URL**: [rust-analyzer/docs/dev/architecture.md](https://github.com/rust-analyzer/rust-analyzer/blob/d7c99931d05e3723d878bea5dc26766791fa4e69/docs/dev/architecture.md)

matklad가 "모범 사례"로 직접 언급한 문서. rust-analyzer(~200k 라인)의 전체 구조를 기술한다.

#### 핵심 설계 원칙

> "On the highest level, rust-analyzer is a thing which accepts input source code from the client and produces a structured semantic model of the code."

- 입력 데이터(소스 파일 + `CrateGraph`)를 메모리에 유지하고, 완전한 시맨틱 모델을 파생한다.
- 모든 표현식이 타입을 갖고, 모든 참조가 선언에 바인딩되는 구조.

#### 주요 컴포넌트 맵

| 영역 | 크레이트/디렉토리 | 역할 |
|------|-------------------|------|
| 빌드/인프라 | `xtask` | 릴리스 관리 등 비cargo 작업 |
| 에디터 | `editors/code` | VS Code 플러그인 |
| 파싱 | `crates/parser`, `crates/syntax` | 수작성 재귀 하강 파서, rowan 기반 타입-세이프 AST |
| DB 레이어 | `crates/base_db` | salsa 기반 증분 계산 |
| 시맨틱 분석 | `crates/hir_expand`, `hir_def`, `hir_ty`, `hir` | 이름 해석, 매크로 확장, 타입 추론 |
| IDE 기능 | `crates/ide` | 자동완성, 정의 이동 등 고수준 기능 |
| LSP 서버 | `crates/rust-analyzer` | 바이너리 진입점, LSP 구현 |
| 매크로 | `crates/mbe`, `crates/tt`, `crates/proc_macro_*` | 토큰 트리 변환 |
| 가상 파일시스템 | `crates/vfs` | 일관된 파일 스냅샷 |

#### 아키텍처 불변 규칙

- **증분 계산**: "함수 본체 내부 타이핑은 전역 파생 데이터를 무효화하지 않는다"
- **구문 독립성**: 구문 트리는 노드 내용만으로 완전히 결정되는 값 타입, 전역 컨텍스트 불필요
- **파일 단위 파싱**: 파일별 독립 파싱으로 병렬 처리 가능
- **불완전성 허용**: AST 메서드가 Option을 반환하면 문법이 금지하더라도 런타임에 None일 수 있다
- **견고성**: 분석은 `Result<T, Error>` 대신 `(T, Vec<Error>)`를 생산하여 깨진 코드도 처리

#### 횡단 관심사

- **코드 생성**: `cargo xtask codegen`으로 처리, 부트스트랩 문제 회피
- **취소(Cancellation)**: salsa의 리비전 카운터 기반 panic 취소, `ide` 경계에서 잡아서 Result로 변환
- **테스트**: LSP(무거운 테스트), `ide`(스냅샷 테스트), `hir`(정교한 테스트) 세 경계에서 테스트
- **에러 처리**: 핵심 컴포넌트는 외부 시스템과 상호작용 안 함, LSP 접점 코드만 IO 수행
- **관측성**: 명시적 이벤트 루프 + `RA_PROFILE` 환경변수 기반 계층적 프로파일링

---

### 2.2 One Hundred Thousand Lines of Rust (시리즈 개요)

> **URL**: [Rust100k](https://matklad.github.io/2021/09/05/Rust100k.html)

ARCHITECTURE.md는 이 시리즈의 첫 번째 글. 중규모 Rust 프로젝트 유지보수에서 배운 교훈 6편:

1. **ARCHITECTURE.md** — 프로젝트 구조 문서화
2. **Delete Cargo Integration Tests** — 테스트 바이너리 통합
3. **How to Test** — 테스트 전략
4. **Inline In Rust** — 인라이닝 최적화
5. **Large Rust Workspaces** — 워크스페이스 구조
6. **Fast Rust Builds** — 빌드 속도 최적화

---

### 2.3 Large Rust Workspaces — 대규모 코드베이스 구조화

> **URL**: [large-rust-workspaces.html](https://matklad.github.io/2021/08/22/large-rust-workspaces.html)

#### 핵심 권장사항: **Flat Layout**

10k~1M 라인 프로젝트에서 **flat(평탄한) 구조**가 최적이다.

```
crates/
├── parser/
├── syntax/
├── hir/
├── ide/
└── ...
```

#### 이유

1. **네임스페이스 일관성**: 패키지 네임스페이스 자체가 flat이므로, 폴더 계층이 실제 의존성 구조와 불일치를 만든다
2. **인지적 단순성**: flat 목록은 한눈에 파악 가능
3. **낮은 유지보수 비용**: 크레이트 추가/분리가 간단, 트리 구조에서는 "어디에 놓을까" 결정이 필요

#### 추가 Best Practice

- 워크스페이스 루트는 virtual manifest만
- 폴더 이름 = 크레이트 이름 일치
- 자동화는 전용 `xtask` 크레이트로
- 미발행 내부 크레이트는 `version = "0.0.0"`

---

### 2.4 How to Test — 테스트 전략

> **URL**: [how-to-test.html](https://matklad.github.io/2021/05/31/how-to-test.html)

#### 핵심 철학

효과적인 테스트는 **구현 세부사항이 아닌 기능(feature)** 을 테스트한다. 이래야 리팩토링에 견고하다.

#### 주요 원칙

| 원칙 | 설명 |
|------|------|
| **테스트 마찰 줄이기** | 중앙화된 `check` 함수로 API 결합도 낮추기 |
| **뉴럴 네트워크 테스트** | "소프트웨어를 불투명한 뉴럴넷으로 교체해도 테스트 스위트를 재사용할 수 있는가?" |
| **경계에서 테스트** | 라이브러리는 공개 API, 앱은 사용자가 관찰하는 것을 테스트 |
| **데이터 주도** | 절차적 단계 대신 직렬화 가능한 데이터 중심 테스트 |
| **Expect 테스트** | 기대값을 코드 안에 직접 유지, 의도적 변경 시 자동 업데이트 |

#### 아키텍처 고려사항

레이어별로 테스트를 배치:
```
L1 <- Tests
L1 <- L2 <- Tests
L1 <- L2 <- L3 <- L4 <- Tests
```

하위 레이어 수정 시 재컴파일 범위를 최소화한다.

#### 핵심 정리

1. 테스트는 안전한 리팩토링을 가능하게 한다 — 이 속성을 최우선으로
2. IO-free인 통합 테스트가 뛰어나다
3. 데이터 직렬화가 테스트 자동화를 가능하게 한다
4. Flaky 테스트는 누적된다 — CI 봇으로 엄격히 관리
5. "좋은 테스트는 대규모 설계에 도움이 된다" — 데이터 모델을 명확하게

---

### 2.5 Delete Cargo Integration Tests — 테스트 구조 최적화

> **URL**: [delete-cargo-integration-tests.html](https://matklad.github.io/2021/02/27/delete-cargo-integration-tests.html)

#### 핵심 문제

`tests/` 디렉토리의 각 파일이 **별도 바이너리**로 컴파일된다. 라이브러리를 매 파일마다 다시 링킹하므로 오버헤드가 크다.

#### 해결책

```
# Before (느림)
tests/foo.rs
tests/bar.rs

# After (빠름)
tests/it/main.rs
tests/it/foo.rs
```

단일 바이너리로 통합하면 중복 링킹 제거. CPU 병렬화는 바이너리 내에서도 작동.

#### 실측 결과

- Cargo 프로젝트 재구성 후: 컴파일 시간 **3배 단축**, 디스크 아티팩트 **5배 감소**
- 다른 프로젝트: 테스트 런타임 20초 → 13초

#### 프로젝트 유형별 가이드라인

- **소규모**: 이미 빠르면 구조 무관
- **대규모**: 선제적 구성 필수
- **발행 라이브러리**: `it`이라는 단일 통합 테스트로 공개 API 검증
- **내부 라이브러리**: `#[cfg(test)] mod tests;`로 유닛 테스트 선호

---

### 2.6 Fast Rust Builds — 빌드 속도 최적화

> **URL**: [fast-rust-builds.html](https://matklad.github.io/2021/09/04/fast-rust-builds.html)

#### 왜 빌드 시간이 중요한가

빌드 시간은 생산성 승수(multiplier). 비선형적 영향 — 컴파일 대기로 인한 컨텍스트 스위칭 손실이 실제 빌드 시간보다 크다.

> "if you let them grow, it might be rather hard to get them back in check later."

#### 주요 최적화 전략

1. **CI로 측정 표준화**: 로컬 증분 빌드는 벤치마크로 부적절, CI가 일관된 비교 기준
2. **캐싱 전략 정교화**: `./target` 전체가 아닌 의존성만 선택적 캐싱
3. **CI 워크플로우 개선**: 컴파일(`--no-run`)과 테스트 실행 분리, CI에서 증분 컴파일 비활성화
4. **의존성 감사**: `Cargo.lock` 비판적 검토, 각 의존성이 실제로 필요한지 확인
5. **프로파일 우선**: `cargo build -Z timings`로 병목 시각화

#### 아키텍처 수준 고려사항

- **크레이트 그래프 설계**: 선형 체인(A→B→C→D→E) 대신 넓은 그래프로 병렬 컴파일 극대화
- **프로시저 매크로 비용**: 파이프라이닝을 차단하므로 정당성 있을 때만 사용
- **단형화(Monomorphization) 관리**: 제네릭은 크레이트 간 코드 중복 유발, 크레이트 경계에서 비제네릭 사용

#### 모든 프로젝트에 적용 가능한 원칙

1. 문제 발생 전에 **모니터링 시스템** 구축
2. 로컬이 아닌 **표준화된 환경(CI)** 에서 측정
3. **의존성 감사** — 프로젝트 범위 내 실제 필요성 검증
4. **빌드 구조 시각화** — 병렬화 기회 식별
5. **비용이 큰 작업**(직렬화, 매크로)은 시스템 경계로 밀어내기
6. **정기적 프로파일링** — 회귀 조기 포착

#### 기준선

> "200k 라인 Rust 프로젝트를 합리적으로 최적화하면 GitHub Actions CI에서 약 10분 걸려야 한다"

---

### 2.7 Inline In Rust — 인라이닝 최적화

> **URL**: [inline-in-rust.html](https://matklad.github.io/2021/07/09/inline-in-rust.html)

#### 핵심 긴장 관계

인라이닝은 분리 컴파일(separate compilation)과 충돌한다. 모듈은 독립적으로 컴파일되어야 하지만, 인라이닝은 모듈 경계를 넘어 함수 본체에 접근해야 한다.

#### 실용 가이드라인

| 대상 | 권장사항 |
|------|---------|
| **애플리케이션** | 무분별한 `#[inline]` 대신 `lto = true` 사용. 프로파일링으로 병목 식별 후 반응적 적용 |
| **라이브러리** | 작은 비제네릭 public 함수에 선제적으로 `#[inline]` 추가 |
| **일반 원칙** | 크레이트 내부에서는 컴파일러가 좋은 인라인 결정을 내리므로 명시적 어노테이션 불필요 |

#### Flutter/Dart 적용 관점

Dart는 AOT 컴파일(Flutter release) 시 자체적으로 인라이닝을 수행한다. Rust와 다르게 별도 어노테이션이 필요하지 않지만, **함수 크기를 작게 유지**하면 컴파일러가 더 효과적으로 인라이닝한다는 원칙은 동일.

---

### 2.8 저자 정보

> **URL**: [about.html](https://matklad.github.io/about.html)

**Alex Kladov** (matklad) — 리스본 거주 프로그래머. "간단한 코드와 프로그래밍 언어를 사랑한다." rust-analyzer의 핵심 개발자이며 GitHub에서 활발히 활동 중.

---

## 3. ARCHITECTURE.md 유지보수 가이드라인

원문과 참조 링크에서 추출한, 프로젝트에서 ARCHITECTURE.md를 유지보수하기 위한 구체적 지침.

### 3.1 작성 시점

- 프로젝트가 **몇 천 라인을 넘어서면** 작성 시작
- README와 CONTRIBUTING이 있다면 ARCHITECTURE가 다음 우선순위
- **기여자가 "어디를 수정해야 하는지 모르겠다"는 질문을 2번 이상 받으면** 반드시 작성

### 3.2 포함해야 할 것

1. **한 문장 프로젝트 설명**: 이 프로젝트가 무엇을 하는가
2. **코드맵 테이블**: 디렉토리/파일 → 역할 매핑
3. **불변 규칙**: "이것은 절대로 X를 하지 않는다" 형태의 부재 제약
4. **레이어 다이어그램**: 의존성 방향을 ASCII로
5. **횡단 관심사 섹션**: 에러 처리, 테스트, 로깅, 국제화 전략

### 3.3 포함하지 말아야 할 것

- 구현 세부사항 (함수 내부 로직, 알고리즘 단계)
- 자주 바뀌는 내용 (UI 텍스트, 상수값, 설정 파라미터)
- 파일에 대한 직접 링크 (대신 이름을 적어 심볼 검색 유도)
- API 문서 (별도 문서 또는 인라인 주석에 위임)

### 3.4 유지보수 규칙

| 규칙 | 이유 |
|------|------|
| **새 모듈 추가 시 코드맵 업데이트** | 멘탈 맵 동기화 |
| **레이어 경계 변경 시 즉시 반영** | 불변 규칙 신뢰성 유지 |
| **분기별 1회 전체 검토** | 오래된 정보 제거 |
| **PR 리뷰에서 ARCHITECTURE 영향 확인** | 구조 변경이 문서에 반영되는지 게이트키핑 |
| **문서 길이 제한 (A4 2~3페이지)** | 간결성 = 모든 기여자가 실제로 읽음 |

---

## 4. FLIPOP 프로젝트 적용

### 4.1 현재 FLIPOP의 상태 분석

FLIPOP은 이미 `CLAUDE.md`에서 아키텍처 개요를 기술하고 있으며, matklad의 권장사항을 **상당 부분 충족**하고 있다:

| 권장사항 | FLIPOP 현황 | 상태 |
|---------|------------|------|
| 고수준 개요 | "블록을 탭해서 색을 순환시키고..." | 충족 |
| 코드맵 | 핵심 파일 맵 테이블 존재 | 충족 |
| 불변 규칙 | Domain Flutter 의존성 금지 등 4가지 | 충족 |
| 레이어 다이어그램 | `Domain → Data → Services → UI` | 충족 |
| 횡단 관심사 | l10n, 배포, Git 규칙 | 부분 충족 |

### 4.2 FLIPOP ARCHITECTURE.md 개선 제안

현재 `CLAUDE.md`가 ARCHITECTURE 역할을 겸하고 있다. matklad의 원칙에 따라 개선할 수 있는 부분:

#### (a) 부재 제약(Absence Constraints) 강화

현재 불변 규칙에 추가 권장:

```
- Services 레이어는 UI 위젯을 직접 참조하지 않는다
- game/ 디렉토리는 Firebase/네트워크 의존성이 없다 (순수 게임 로직)
- l10n 생성 파일은 수동 편집하지 않는다
- data/ 레이어의 구현체는 domain/ 인터페이스만 구현하며, UI를 알지 못한다
```

#### (b) 횡단 관심사 섹션 추가

```
## 횡단 관심사

### 에러 처리
- Domain: sealed class AuthFailure로 타입-세이프 에러 표현
- UI: 에러를 사용자 친화적 메시지로 변환 (l10n 키 사용)

### 상태 관리
- GameState: 불변 객체, copyWith 패턴
- 인증 상태: AuthService가 StreamController로 관리

### 광고
- AdService: 싱글톤, 인터스티셜/리워드 통합 관리
- 각 광고 유형은 게임당 1회 제한 (비즈니스 규칙)

### 의존성 주입
- service_locator.dart에서 수동 DI
- 모든 서비스는 factory 패턴 싱글톤
```

#### (c) 데이터 흐름 명시

```
## 데이터 흐름

사용자 탭 → GameScreen → GameState.tapBlock()
  → 새 GameState 반환 → setState() → UI 리렌더링
  → 줄 클리어 시: 점수 업데이트 + 파티클 효과
  → 게임 오버 시: LeaderboardService.submitScore()
    → Firestore에 저장
```

#### (d) 플랫폼별 경계

```
## 플랫폼 경계

| 플랫폼 | 경로 | 역할 |
|--------|------|------|
| iOS | ios/ | Xcode 프로젝트, AdMob Info.plist 설정 |
| Android | android/ | Gradle, AdMob AndroidManifest 설정 |
| Web | web/ | Firebase Hosting 대상 |
| Functions | functions/ | Cloud Functions (onUserDeleted 트리거) |
```

### 4.3 Flutter 모바일 게임에서의 ARCHITECTURE.md 핵심 포인트

Flutter 프로젝트에 matklad의 원칙을 적용할 때 특히 중요한 점:

1. **레이어 의존성 방향은 단방향**: `Domain ← Data ← Services ← UI` — 역방향 의존성은 아키텍처 불변 규칙으로 금지해야 한다

2. **게임 로직의 순수성 보장**: `game/` 디렉토리는 Flutter 프레임워크 import 없이 순수 Dart로 유지. 이것이 테스트 가능성과 이식성의 핵심이다 (matklad의 "IO-free 통합 테스트" 원칙과 일치)

3. **flat 구조 유지**: FLIPOP의 `lib/` 하위 디렉토리가 한 단계 깊이로 유지되는 것은 matklad의 "Large Workspaces" 권장과 일치. 불필요한 중첩 디렉토리를 만들지 않는다

4. **심볼 검색 친화적**: 문서에서 `GameState`, `AuthService`, `AdService` 같은 타입 이름을 명시하면 IDE에서 바로 검색 가능. 파일 경로 링크보다 효과적

5. **게임 메커닉은 ARCHITECTURE에 포함**: 게임 프로젝트 특성상 게임 규칙(그리드 크기, 색 순환, 타이머)은 아키텍처 수준의 불변 규칙이다. 구현 세부사항이 아니라 "이 게임이 무엇인가"를 정의하므로 ARCHITECTURE에 속한다

6. **광고/수익화 정책은 횡단 관심사**: 광고 타입, 호출 빈도 제한, 보상 구조 등은 여러 레이어에 걸치므로 횡단 관심사 섹션에서 다뤄야 한다

---

## 5. 참조 링크 전체 목록

| # | 제목 | URL | 유형 |
|---|------|-----|------|
| 1 | ARCHITECTURE.md (원문) | https://matklad.github.io/2021/02/06/ARCHITECTURE.md.html | 원문 |
| 2 | rust-analyzer architecture.md | https://github.com/rust-analyzer/rust-analyzer/blob/d7c99931d05e3723d878bea5dc26766791fa4e69/docs/dev/architecture.md | 실전 예시 |
| 3 | One Hundred Thousand Lines of Rust | https://matklad.github.io/2021/09/05/Rust100k.html | 시리즈 목차 |
| 4 | Delete Cargo Integration Tests | https://matklad.github.io/2021/02/27/delete-cargo-integration-tests.html | 테스트 구조 |
| 5 | How to Test | https://matklad.github.io/2021/05/31/how-to-test.html | 테스트 전략 |
| 6 | Inline In Rust | https://matklad.github.io/2021/07/09/inline-in-rust.html | 최적화 |
| 7 | Large Rust Workspaces | https://matklad.github.io/2021/08/22/large-rust-workspaces.html | 프로젝트 구조 |
| 8 | Fast Rust Builds | https://matklad.github.io/2021/09/04/fast-rust-builds.html | 빌드 최적화 |
| 9 | matklad About | https://matklad.github.io/about.html | 저자 정보 |
| 10 | matklad GitHub | https://github.com/matklad | 저자 GitHub |
| 11 | Fix typo (원문 소스) | https://github.com/matklad/matklad.github.io/edit/master/content/posts/2021-02-06-ARCHITECTURE.md.dj | 원문 소스 |
