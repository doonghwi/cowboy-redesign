# cowboy_redesign — 설계 문서 (살아있는 문서)

> Figma 주도(예정) 리디자인 프로토타입. **cowboy_party 본 앱과 완전 독립**(별도 폴더/repo/도메인).
> 목표: 카우보이 파티 게임을 처음부터 예쁜 디자인 시스템으로 다시 그린다.
> 최종 갱신: 2026-06-16 (Cycle 4 — 랭킹/리더보드 화면)

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
  - `CowboyButton` — primary(그라데이션+글로우)/secondary(터콰이즈 아웃라인)/ghost. 누름 애니메이션(scale 0.97).
  - `CowboyCard` — 가죽 패널(그라데이션+헤어라인 보더+그림자). 옵션 좌측 accent 스트라이프(IntrinsicHeight로 풀하이트).
  - `SectionLabel` — 작은 올캡스 eyebrow.

## 2. 화면
- `lib/screens/home_screen.dart` — 홈/타이틀. DuskBackground 위 워드마크(Cowboy/Party) + 태그라인 + PLAY CTA(→ /table) + 보조(How to play/Saloon) + 코인/스트릭/승수 스탯 스트립.
  - 레이아웃: SingleChildScrollView + Center + ConstrainedBox(maxWidth 520) + Padding + 명시적 간격(세로 Spacer/IntrinsicHeight 미사용 — 스크롤뷰 무한 높이 충돌 회피, LESSONS 참조).
- `lib/screens/game_table_screen.dart` — **게임 테이블(센터피스)**. DuskBackground + Column(상단바·아레나·ActionBar).
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
- 라우팅: `main.dart` `routes` `/`(home)·`/table`·`/saloon`·`/ranking`. 스크린샷 딥링크용(`#/table`, `#/saloon`, `#/ranking`).

## 3. 진입점 / 인프라
- `lib/main.dart` — `DailyAppStats.recordOpen(appId:'cowboy_redesign', ...)` fire-and-forget 핑 후 `CowboyRedesignApp`.
- `lib/dailyapp_stats.dart` — 공용 사용량 트래커 드롭인(`_shared`에서 복사).
- 테스트: `test/widget_test.dart` — 홈 워드마크/PLAY 렌더 스모크.

## 4. 진행 단계 (로드맵)
1. ✅ Cycle 1: 디자인 시스템 + 홈 화면.
2. ✅ Cycle 2: 게임 테이블(원형 좌석 Align 배치 + 액션 바 + 타이머).
3. ✅ Cycle 3: 상점(Saloon) — 레어리티 캐릭터 카드 그리드.
4. ✅ Cycle 4: 랭킹/리더보드 — Top3 포디움 + 리스트.
5. ⬜ 결과/쇼다운.
> 본 게임 규칙은 `../cowboy_party/ARCHITECTURE.md` 참조(룩만 새로, 로직은 추후 이식 결정 사용자 몫).

## 5. 검증/배포
- `flutter analyze`(0) + `flutter test` 통과 후 커밋.
- web: `flutter build web` → headless Chrome 스크린샷 `shots/`.
- 배포: gh-pages `doonghwi/cowboy-redesign` (예정).
