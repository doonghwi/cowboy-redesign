# cowboy_redesign — 설계 문서 (살아있는 문서)

> Figma 주도(예정) 리디자인 프로토타입. **cowboy_party 본 앱과 완전 독립**(별도 폴더/repo/도메인).
> 목표: 카우보이 파티 게임을 처음부터 예쁜 디자인 시스템으로 다시 그린다.
> 최종 갱신: 2026-06-16 (Cycle 14 — 슈퍼빵야 풀스크린 플래시 · 캐릭터 PNG 16종 적용)
>
> **피벗(2026-06-16):** Figma 폐기. 이 레포는 이제 **아트+이펙트 랩**. 핵심 화면(Cycle1~7)은 베이스로 유지.
> 새 목표: (1) 코드 기반 이펙트 고도화, (2) 캐릭터 일러스트 통합. cowboy_party는 읽기 전용 레퍼런스.
> 이펙트 감사·설계는 `EFFECTS_AUDIT.md` / `EFFECTS_PLAN.md` 참조.

## 1. 디자인 시스템 — "Desert Dusk"
서부(spaghetti-western) + 모던. 가죽/모래/석양 오렌지 + 남서부 터콰이즈 액센트.

- **토큰**: `lib/design/tokens.dart`
  - `CColors` — 역할 기반 컬러(primary=terracotta, accent=turquoise, gold, ink/surface 중성, dusk 그라데이션, 텍스트 hi/mid/low, status).
  - `CSpace` — 엄격한 8pt 그리드(4pt half-step). xxs(4)~xxxl(64).
  - `CRadius` — sm10/md16/lg22/pill. `CShadow` — card/glow. `CMotion` — fast/base/slow + easeOutCubic.
- **타이포**: `lib/design/theme.dart` `CType` (google_fonts)
  - 워드마크/히어로 → **Rye**(우드타입 서부). 헤딩/숫자 → **Bitter**(따뜻한 슬랩 세리프). 본문/UI → **Inter**.
  - `buildCowboyTheme()` → 다크 M3 ThemeData(scheme, scaffold bg, Inter textTheme).
- **컴포넌트**: `lib/design/components.dart`
  - `DuskBackground` — 전 화면 공통 석양 그라데이션 + 라디얼 글로우 2개.
  - 전환: `lib/design/transitions.dart` `cowboyRoute<T>()` — 페이드 + 살짝 위로 슬라이드(MaterialPageRoute 대체, 홈 네비 전부 사용).
  - `CowboyButton` — primary(그라데이션+글로우)/secondary(터콰이즈 아웃라인)/ghost. 누름 애니메이션(scale 0.97).
  - `CowboyCard` — 가죽 패널(그라데이션+헤어라인 보더+그림자). 옵션 좌측 accent 스트라이프(IntrinsicHeight로 풀하이트).
  - `SectionLabel` — 작은 올캡스 eyebrow.

## 1.5 이펙트 시스템 (lib/effects/) — 이벤트→디스패처→프레젠테이션
- `game_event.dart` — sealed `GameEvent`(Bang/Defend/Trap/Smoke/Curse/Hit). 좌석 인덱스만, 좌표·색 무지.
- `effect_spec.dart` — `EffectKind` + `EffectSpec`(불변 데이터: kind·from·to·duration·curve·color·anchorRadius). **이펙트=데이터**.
- `effect_controller.dart` — `EffectController extends ChangeNotifier`. `AnchorResolver`(좌석→Offset) 주입. `dispatch(event)`→스펙 생성·추가·만료 제거. 게임상태 불침투.
- `effect_shaders.dart` — `EffectShaders.load()`로 `beam.frag`/`ring.frag` 프리로드(`ui.FragmentProgram`).
- `effect_overlay.dart` — `EffectOverlay`(IgnorePointer + AnimatedBuilder) active 스펙→프레젠터 매핑.
- `presenters/bang_tracer.dart` — 빵야/슈퍼빵야: **Canvas 다중 글로우 라인(베이스, 항상 보임) + 셰이더 블룸(origin-anchored picture를 회전 합성해 FlutterFragCoord 스크린좌표 함정 회피) + Flame ComputedParticle 머즐 버스트 + 화살촉 + 임팩트 플래시**. 슈퍼는 골드·두께·파티클↑.
- `presenters/smoke_puff.dart` — 연막: Flame 입자 구름(상승·확산·블러, 성장 후 페이드).
- `presenters/curse_aura.dart` — 저주: 흔들리는 보라 테더(caster→target) → 타겟에 맥동 오라 + 라이징 모트.
- `presenters/hit_burst.dart` — 히트/처치: Flame 방사 파편 + 확장 쇼크링.
- `presenters/super_flash.dart` — 슈퍼빵야 풀스크린 플래시: 골드 bolt + 스트로크 "SUPER BANG" 워드마크 + 비네트, 팝인(easeOutBack)→쉐이크→페이드. AnimationController 기반(헤드리스 캡처에도 안정). 슈퍼 BangEvent가 빔+플래시 동시 발사.
- **전 6종 + 슈퍼 플래시 구현 완료**(빵야·슈퍼빵야·방어·덫·연막·저주 + 히트).
- ⚠️ 함정: `TextStyle`에 color와 foreground 동시 지정 불가(스트로크 텍스트는 color 없는 스타일로). flutter_animate는 헤드리스 캡처에서 진행 안 될 수 있어 핵심 연출은 AnimationController로.
- 셰이더 `shaders/beam.frag`(빔 블룸·헤드 트래블), `shaders/ring.frag`(링 쇼크웨이브) — pubspec `flutter: shaders:` 등록.
- 검증: `lib/screens/effects_lab_screen.dart`(`/lab`) — 좌석 토큰 링 + Bang/Super/Hit/Clear 버튼. URL에 `auto` 포함 시 주기 발사(스크린샷용, `?auto=1#/lab`). 샷 `shots/effects/`.

## 1.6 캐릭터 일러스트 (아트 통합)
- 프롬프트: `art/CHARACTER_PROMPTS.md`(16종, 공통 스타일 블록 + 캐릭터별). **이미지 생성 스크립트 없음** — PNG는 사장님이 직접 생성해 `assets/characters/<id>.png`로 투입.
- `lib/widgets/character_portrait.dart` `CharacterPortrait` — `Image.asset('assets/characters/<id>.png')` 로드, **`errorBuilder`/`frameBuilder`로 PNG 없으면 이모지 코드 플레이스홀더**(레어리티/역할색 틴트 메달리온)로 폴백. 크래시 없음.
- 모델: `Character.id`(16종, catalog), `Player.charId`. id는 프롬프트/파일명과 1:1.
- 통합: **상점 카드**(`saloon_screen.dart` CharacterCard) + **게임 좌석**(`player_seat.dart` _Avatar) 모두 CharacterPortrait 사용. PNG 투입 시 자동 반영.

## 2. 화면
- `lib/screens/home_screen.dart` — 홈/타이틀. DuskBackground 위 워드마크(Cowboy/Party) + 태그라인 + PLAY CTA(→ /table) + 보조(How to play/Saloon) + 코인/스트릭/승수 스탯 스트립.
  - 레이아웃: SingleChildScrollView + Center + ConstrainedBox(maxWidth 520) + Padding + 명시적 간격(세로 Spacer/IntrinsicHeight 미사용 — 스크롤뷰 무한 높이 충돌 회피, LESSONS 참조).
- `lib/screens/game_table_screen.dart` — **게임 테이블(센터피스)**. DuskBackground + Column(상단바·아레나·ActionBar).
  - **이펙트 통합(Cycle13):** `EffectController`+`EffectOverlay`를 화면에 얹고, `_TableArena`가 Align 슬롯→픽셀 앵커(아바타 중심)로 변환해 `onLayout`으로 전달 → 컨트롤러 resolveAnchor가 실좌석 좌표 사용. 좌석 탭(`GestureDetector`)→선택 액션에 맞는 이벤트 발사(빵야 you→상대, 방어/덫 self, 연막 토글). `?auto`로 데모 자동 발사(스크린샷, shots/effects/table_effects.png).
  - `_TableArena`: 좌석을 `Align(Alignment)`로 배치(2~6인별 `_layouts` 맵, "You"=하단 중앙, 나머지=상단 호). trig+Positioned 대신 Align 사용(우측 좌석 누락 버그 회피). 중앙 `_FeltTable`(라디얼 펠트) + `_CenterTimer`(원형 진행바 + 카운트).
  - 좌석 위젯 `lib/widgets/player_seat.dart` `PlayerSeat`: 아바타 토큰(이모지)·이름·역할 라벨·탄약 핍·상태(방어/사망 닷). highlight=내 차례.
  - 액션바 `lib/widgets/action_bar.dart` `ActionBar`: parallel 토글(연막) 상단 스트립 + 코어 4행(Reload/Defend/Bang!/Trap). cowboy_party SpecialSlot 분류를 룩만 새로 반영. `GameAction` enum, 선택 상태 토글.
  - 모델 `lib/models/player.dart` `Player`(뷰모델, demoTable 6인). 로직은 추후 cowboy_party에서 이식.
- `lib/screens/saloon_screen.dart` — **상점(Saloon)**. DuskBackground + 헤더(코인 잔액) + 반응형 GridView(폰 2열, `maxWidth~/220` clamp 2~4).
  - `CharacterCard`: CowboyCard(accent=레어리티색) + 레어리티 라벨·이모지 링·이름·태그라인·`_BuyChip`(Owned 초록 / 가격 골드, 잔액 부족 시 흐림).
  - 모델 `lib/models/character.dart` `Character`(catalog 11종, cowboy_party 로스터 발췌) + `Rarity`(common/rare/epic/legend → 색·라벨).
- `lib/screens/ranking_screen.dart` — **랭킹/리더보드**. DuskBackground + 헤더 + Top3 포디움(2·1·3위 단상, 1위 골드 글로우) + ListView(4위~, 내 행 골드 accent 하이라이트).
  - 모델 `lib/models/ranking.dart` `RankEntry`(demo 8명, isYou 표시).
  - 홈 코인 스트립 탭 → 랭킹(`CowboyCard.onTap`).
- `lib/screens/result_screen.dart` — **결과/승리**. DuskBackground + Victory/Defeat 배너(`won` 플래그, 골드/레드) + 승자 배지(글로우 링) + 보상 카드(코인/랭크/XP) + 최종 순위(생존→사망 정렬, 내 행 하이라이트) + CTA(Play again / Back to town `popUntil first`).
- `lib/screens/how_to_play_screen.dart` — **How to play**. 동시 행동 규칙 인트로 + "Your moves"(Reload/Defend/Bang!/Super Bang/Idle) + "Ways to win"(Last standing/Pacifist/Duelist) 카드. 정적 콘텐츠. 홈 "How to play" 버튼 연결.
- 라우팅: `main.dart` `routes` `/`(home)·`/table`·`/saloon`·`/ranking`·`/result`·`/howto`. 홈에서 PLAY→table, Saloon→saloon, How to play→howto, 코인스트립→ranking. (table/result는 흐름상 추후 연결, 현재 라우트/딥링크로 접근).

## 3. 진입점 / 인프라
- `lib/main.dart` — `DailyAppStats.recordOpen(appId:'cowboy_redesign', ...)` fire-and-forget 핑 후 `CowboyRedesignApp`.
- `lib/dailyapp_stats.dart` — 공용 사용량 트래커 드롭인(`_shared`에서 복사).
- 테스트: `test/widget_test.dart` — 홈 워드마크/PLAY 렌더 스모크.

## 4. 진행 단계 (로드맵)
1. ✅ Cycle 1: 디자인 시스템 + 홈 화면.
2. ✅ Cycle 2: 게임 테이블(원형 좌석 Align 배치 + 액션 바 + 타이머).
3. ✅ Cycle 3: 상점(Saloon) — 레어리티 캐릭터 카드 그리드.
4. ✅ Cycle 4: 랭킹/리더보드 — Top3 포디움 + 리스트.
5. ✅ Cycle 5: 결과/승리 — 배너·승자 배지·보상·순위.
> **핵심 5화면 완성.** 다음 루프: 폴리시(애니메이션·전환·how-to-play 화면·다크/사운드 토글), 또는 Figma 연결 시 토큰 정렬.
> 본 게임 규칙은 `../cowboy_party/ARCHITECTURE.md` 참조(룩만 새로, 로직은 추후 이식 결정 사용자 몫).

## 5. 검증/배포
- `flutter analyze`(0) + `flutter test` 통과 후 커밋.
- web: `flutter build web` → headless Chrome 스크린샷 `shots/`.
- 배포: gh-pages `doonghwi/cowboy-redesign` (예정).
