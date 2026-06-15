# EFFECTS_AUDIT — cowboy_party 이펙트 코드 감사 (읽기 전용)

> 목적: `cowboy_party`(본 앱, **수정 금지**)의 현재 비주얼 이펙트가 어디서/어떤 기술로 그려지고
> 게임로직과 얼마나 분리돼 있는지 감사하여, `cowboy_redesign`(이펙트 랩)의 코드 기반 고도화 토대 마련.
> 최종 갱신: 2026-06-16. 참조 커밋 기준 cowboy_party 현행.

## 요약 (결론)
- **로직/프레젠테이션 분리: 매우 우수.** `party_logic.dart`의 `resolvePartyTurn()`은 **순수 함수** — 위젯 import 0, 부수효과 0, 시드 결정적. 결과를 **불변 데이터 `TurnOutcome`(플래그 배열 16+종) + `PartyState`(지속 상태)** 로 반환하고, UI는 이를 좌석 투영 모델 `TableSeat`로 받아 **반응형 렌더**만 한다. 폴링 없음, 콜백 없음.
- **렌더 기술: 100% Flutter 코어 프리미티브.** `CustomPainter`+`Canvas`, `TweenAnimationBuilder`, `AnimationController`, `Transform`, `TextStyle.foreground`(stroke). **flame/flutter_animate/셰이더 의존성 없음.**
- 따라서 이벤트→디스패처→프레젠테이션 구조로 **재구현 난이도 낮음(2~5/10)**. 어려운 건 메커니즘이 아니라 **미감(글로우·스트로크·커브·팔레트)** 재현.

## 데이터 계약 (UI가 읽는 핵심 필드)
`party_logic.dart` `resolvePartyTurn()` → `TurnOutcome`:
- `fired: List<bool>`, `superFired: List<bool>`, `firedTarget: List<int>`, `firedTarget2: List<int>` — 발사/슈퍼/대상
- `hit`, `evaded`, `trapSet`, `reflectKill`, `curseKill`, `healed`, `pierced`, `doubleLoad`, `smoked`, `dualFired`, `voodooCast`, `resetActive: List<bool>`
- `status: GameStatus`, `winner: int?`, `stateAfter: PartyState`
`PartyState`(지속): `curseFuse: List<int>`(좌석별 저주 잔여턴, 0=없음), `curseCaster: List<int>`, `smokeLeft: List<int>`, `*Used: List<bool>`.
`TableSeat`(렌더 투영, offline_game_screen.dart에서 조립): 위 플래그 + `lastMove: Move`(`Move.kind: ActKind`).
트리거: 턴 해석 후 `setState`로 `reveal=true` 플립 → `CircularTable`이 플래그 읽어 페인터/이펙트 렌더.

## 이펙트별 상세 (파일:라인)

### 1) BANG (빵야) / TRACER — 동일 구현
- **위치:** `lib/widgets/circular_table.dart` `_TracerPainter`(클래스 433–534, paint 439–472, 호출 146–150).
- **기술:** `Canvas.drawLine`(red 0.85α, 3px, round cap) + 화살촉 Path(`_arrow`, 519–530). **애니메이션 없음**(reveal 시 즉시 표시, 정적).
- **입력:** `seats[s].fired`, `firedTarget` (로직 `party_logic.dart:406–459`, 일반 `fired[i]=true; firedTarget[i]=m.target`).
- **분리:** 완전 분리(페인터에 로직 0). **이식 난이도 3/10.**

### 2) SUPER BANG (슈퍼빵야) — 2파트
- **테이블 볼트:** `circular_table.dart` `_superBolt`(476–517), `_burst`(497) — 3중 라인(글로우 13px MaskFilter blur, 코어 6px nova gold, 이너 2px white) + 8각 별 스타버스트. 정적.
- **풀스크린 플래시:** `lib/widgets/super_flash.dart` `SuperBbangyaFlash`(11–127) — `AnimationController`(1300ms) 절차적 단계(pop 0–22% easeOutBack / hold 22–70% / exit 70–100% fade+scale / shake 0–45%). 텍스트 "슈 퍼 빵 야" stroke(11px)+fill(yellow), bolt 아이콘 듀얼 섀도. 트리거 `offline_game_screen.dart:312` `if (out.superFired.any(...)) _fireSuperFlash()`(154–161, Timer 1400ms).
- **분리:** 이벤트 기반(플래그→StatefulWidget 인스턴스, 내부 컨트롤러). **이식 5/10**(시계열 트윈 + stroke 텍스트 재현).

### 3) DEFENSE (방어) — 실드 링 팝인
- **위치:** `circular_table.dart` `_effects` `case ActKind.defend`(243–285).
- **기술:** `TweenAnimationBuilder<double>`(0.7→1.0, 380ms, **easeOutBack** 오버슈트) → `Transform.scale` → 원형 보더(sage 3.5px) + 글로우 섀도(blur12, 0.45α) + 상단 shield 아이콘.
- **입력:** `seats[s].lastMove.kind == ActKind.defend`. **분리 완전. 이식 2/10.**

### 4) TRAP (덫) — 트랩 링 팝인
- **위치:** `circular_table.dart` `_effects` `case ActKind.trap`(286–331). DEFENSE와 **구조 동일**, 색 brown(0xFF7A3E18) + `Icons.crisis_alert`.
- **입력:** `lastMove.kind==trap` (로직 `party_logic.dart:396–399`, `trapSet[i]=true`). **이식 2/10.**

### 5) SMOKE (연막) — **시각 이펙트 없음**
- 현재 **테이블 비주얼 0**. 리빌 배너 텍스트("…연막으로 회피!", `offline_game_screen.dart:425`) + SFX('shield', :363)만. `seat_card.dart`에 `evadedFx` 파라미터 존재하나 build에서 **미렌더**.
- **입력:** `Move.smoke`+`PartyState.smokeLeft`→`TurnOutcome.evaded`(로직 400–403, 473–476). **이식: 신규 비주얼 설계 필요 5/10**(연막 구름/디스토션 등).

### 6) CURSE (저주) — 2서브
- **카운트다운 배지(지속):** `lib/widgets/seat_card.dart`(194–220) 정적 Container — 보라(0xFF5B3A8E) 배지 💀+잔여턴. 입력 `PartyState.curseFuse[s]`(로직 559–590 `curseFuse[v]-=1`). 애니메이션 없음.
- **사망 라벨(리빌):** `seat_card.dart`(235–257) `TweenAnimationBuilder`(0.6→1.0, 320ms easeOutBack) "저주 사망!". 입력 `TurnOutcome.curseKill`(로직 502–512). **이식 3/10.**

## 이식 우선순위(이펙트 랩에서 고도화할 순서)
스펙 루프 A 순서대로: **빵야 → 방어 → 덫 → 연막 → 저주**.
- 빵야/방어/덫은 데이터·트리거가 단순·명확 → 먼저 코드 이펙트 시스템 위에 화려하게 재구현(파티클/셰이더/flutter_animate).
- 연막은 신규 비주얼 설계 여지(가장 창의적). 저주는 지속 상태 + 팝인 라벨.

## 미감 재현 체크리스트(고도화 시 유지/강화)
- 글로우 = `MaskFilter.blur` 또는 셰이더 블룸. 스트로크 텍스트 = `Paint..style=stroke`.
- 커브 팝인 = `easeOutBack`(오버슈트). 슈퍼 = nova gold 3중 레이어 + 스타버스트.
- 결정성 유지: 시드 기반(온라인 동기화). 이펙트는 **결과 데이터로부터 파생**, 로직에 침투 금지.
