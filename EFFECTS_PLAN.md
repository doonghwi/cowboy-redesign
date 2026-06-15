# EFFECTS_PLAN — 코드 기반 이펙트 아키텍처 (cowboy_redesign)

> EFFECTS_AUDIT.md 결과 위에서 설계. 목표: **게임로직과 완전 분리된 이펙트 레이어** — 이펙트를
> **데이터(타입·지속·커브·색·앵커)** 로 정의하고, **이벤트 → 디스패처 → 프레젠테이션** 으로 흐른다.
> cowboy_party의 깨끗한 순수함수 패턴을 그대로 계승.

## 1. 3계층 분리
```
[게임/시뮬]  GameEvent (무엇이 일어났나; 좌표·로직 무지)
     │  emit
     ▼
[디스패처]  EffectController (event → EffectSpec 목록으로 매핑; 앵커 좌표 주입)
     │  schedule
     ▼
[프레젠테이션]  EffectOverlay (활성 EffectSpec들을 위젯/페인터/파티클로 렌더, 끝나면 자동 폐기)
```
- 게임 코드는 `GameEvent`만 던진다(예: `BangEvent(shooter, target, isSuper)`). 좌표·색·시간 모름.
- 디스패처가 좌석 앵커(Offset)와 테마 색을 붙여 `EffectSpec`(데이터)로 변환.
- 오버레이는 스펙 리스트를 구독해 그린다. 로직 침투 0, 폴링 0.

## 2. 핵심 타입 (lib/effects/)
- `GameEvent`(sealed): `BangEvent`, `SuperBangEvent`, `DefendEvent`, `TrapEvent`, `SmokeEvent`, `CurseEvent`, `CurseKillEvent`, `HitEvent`. 좌석 인덱스만 담는다.
- `EffectSpec`(불변 데이터): `EffectKind kind; Offset from; Offset to; Duration duration; Curve curve; Color color; double anchorRadius; int id;` — **이펙트=데이터** 원칙.
- `EffectController extends ChangeNotifier`: `List<EffectSpec> active`. `dispatch(GameEvent, AnchorResolver)` → 스펙 생성·추가, `Future.delayed`로 만료 제거 후 notify. `AnchorResolver` = `Offset Function(int seat)`(좌석→화면좌표).
- `EffectOverlay`: `AnimatedBuilder(controller)`로 active 스펙을 종류별 프레젠터로 렌더.
- `EffectPresenter`(종류별): `BangTracer`(셰이더 글로우 라인+파티클 머즐), `ShieldRing`(flutter_animate 팝인+링 셰이더), `TrapRing`, `SmokePuff`(Flame 파티클 구름), `CurseAura`.

## 3. 렌더 기술 선택 (근거)
- **Flame `ParticleSystemComponent`** — 머즐 플래시 스파크, 연막 구름, 히트 디브리. 다수 입자·수명·중력에 최적. (vs 직접 Canvas 루프: 보일러플레이트↑)
- **Fragment shader(.frag, `ui.FragmentProgram`)** — 트레이서 빔의 부드러운 블룸/코어 그라데이션, 실드 링의 굴절감. GPU 블룸이 `MaskFilter.blur`보다 풍부. Flutter 3.44 안정 지원.
- **flutter_animate** — 위젯 단 팝인/페이드/쉐이크/셰이크(실드·트랩 링, 라벨)를 선언형 체인으로. cowboy_party의 `TweenAnimationBuilder`를 대체·강화.
- **Canvas/CustomPainter** — 화살촉, 별 스타버스트 등 단순 벡터는 그대로.

## 4. 디렉터리
```
lib/effects/
  game_event.dart        # sealed GameEvent
  effect_spec.dart       # EffectKind, EffectSpec (데이터)
  effect_controller.dart # 디스패처(ChangeNotifier) + AnchorResolver
  effect_overlay.dart    # 활성 스펙 렌더 스택
  presenters/
    bang_tracer.dart     # 셰이더 빔 + Flame 머즐 파티클
    shield_ring.dart     # flutter_animate 팝인 + 링
    trap_ring.dart
    smoke_puff.dart      # Flame 구름
    curse_aura.dart
shaders/
  beam.frag             # 트레이서 블룸
  ring.frag             # 실드/트랩 링
```

## 5. 검증·통합
- `lib/screens/effects_lab_screen.dart` — 버튼으로 각 이벤트를 수동 발사해 오버레이 위에서 확인(스크린샷용). `/lab` 라우트.
- 추후 `GameTableScreen`에 `EffectController`+`EffectOverlay`를 얹어 좌석 앵커로 실제 연출.
- 사이클마다 `shots/effects/<effect>.png` 캡처 → analyze 0 + test → 커밋·배포 → notes 로그.

## 6. 우선순위 (루프 A)
빵야(셰이더 빔+파티클) → 방어(링 팝인) → 덫(링) → 연막(Flame 구름) → 저주(오라). 각 1사이클.
