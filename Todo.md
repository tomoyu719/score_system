# Todo

## 凡例

- `[P0]` MVP必須
- `[P1]` MVP対象（P0の次）
- `[P2]` MVP対象（後半）
- `[v1]` MVP完了後
- `[Future]` 将来対応

---

## Epic 1: 基盤整備

### E1-S1: monorepo構成
- [ ] T1: pubspec.yaml workspace設定 `[P0]`
- [ ] T2: melos.yaml設定 `[P0]`
- [ ] T3: analysis_options.yaml共有設定 `[P0]`
- [ ] T4: 各packageの骨格作成 `[P0]`
- [ ] T5: GitHub Actions CI設定 `[P0]`

### E1-S3: pre-commit hooks
- [ ] T8a: `.githooks/pre-commit` に `dart analyze && dart test` を追加 `[P0]`
- [ ] T8b: `git config core.hooksPath .githooks` をセットアップ手順に記載 `[P0]`

### E1-S2: dep_checker
- [ ] T6: dep_checker.dart実装 `[P0]`
- [ ] T7: CIにdep_checkスクリプト追加 `[P0]`

---

## Epic 2: score_core

### E2-S1: 基本モデル
- [ ] T8: Pitch / Duration / Fraction `[P0]`
- [ ] T9: Score / Part / Staff `[P0]`
- [ ] T10: Measure / Voice / MusicEvent `[P0]`
- [ ] T11: NoteEvent / RestEvent / ChordEvent `[P0]`
- [ ] T12: Clef / KeySignature / TimeSignature `[P0]`
- [ ] T13: Barline / MeasureHeader `[P0]`

### E2-S2: Edge要素
- [ ] T14: BeamGroup / Tuplet `[P0]`
- [ ] T15: Slur / Tie `[P0]`
- [ ] T16: Articulation / Dynamic / Lyric `[P1]`

### E2-S3: Command Engine
- [ ] T17: Command sealed class `[P0]`
- [ ] T18: AddNoteCommand / RemoveNoteCommand `[P0]`
- [ ] T19: CommandEngine.apply / dryRun `[P0]`
- [ ] T20: CommandHistory（Undo/Redo） `[P0]`
- [ ] T21: BatchCommand `[P0]`
- [ ] T22: AuditLog `[P0]`

### E2-S4: Validation
- [ ] T23: Validator基盤 `[P0]`
- [ ] T24: 拍子整合性ルール `[P0]`
- [ ] T25: 音域バリデーション `[P0]`
- [ ] T26: ValidationResult JSON serialize `[P0]`

### E2-S5: TAB model
- [ ] T27: TabConfig / TabFret `[P1]`
- [ ] T28: GuitarTechnique `[P1]`

### E2-S6: Percussion model
- [ ] T29: DrumMapping / DrumInstrument `[P1]`
- [ ] T30: PercussionNote `[P1]`

### E2-S7: Cross-staff model
- [ ] T31: CrossStaffRef `[P2]`
- [ ] T32: CrossStaffBeamGroup `[P2]`

### E2-S8: N Voice
- [ ] T33: VoiceConfig `[P1]`
- [ ] T34: VoicePriority policy `[P1]`

---

## Epic 3: score_io

### E3-S1: native format
- [ ] T35: Score.toJson / Score.fromJson `[P0]`
- [ ] T36: Fraction ↔ String変換 `[P0]`
- [ ] T37: schema migration基盤 `[P0]`

### E3-S2: MusicXML
- [ ] T38: MusicXML DOMパーサー `[P0]`
- [ ] T39: note / rest / chord import `[P0]`
- [ ] T40: beam / tuplet / slur / tie import `[P0]`
- [ ] T41: dynamic / lyric / articulation import `[P0]`
- [ ] T42: MusicXML export generator `[P0]`
- [ ] T43: roundtripテスト `[P0]`

### E3-S3: MIDI
- [ ] T44: MIDI SMF Type 1 encoder `[P0]`
- [ ] T45: MIDI JSON dump `[P0]`

### 将来対応（score_io）
- [ ] MIDI SMF Type 0 export（`--type 0` オプション） `[v1]`
- [ ] MusicXML 4.0 対応 `[v1]`
- [ ] MIDI import `[v1]`

---

## Epic 4: score_layout

### E4-S1: 基盤
- [ ] T46: BoundingBox `[P1]`
- [ ] T47: LayoutElement sealed class `[P1]`
- [ ] T48: LayoutTree `[P1]`

### E4-S2: spacing
- [ ] T49: NoteLayout（X/Y計算） `[P1]`
- [ ] T50: MeasureSpacingEngine `[P1]`
- [ ] T51: StaffSpacingEngine `[P1]`

### E4-S3: voice layout
- [ ] T52: StemDirection決定 `[P1]`
- [ ] T53: RestPositioning `[P1]`
- [ ] T54: SharedNotehead検出 `[P1]`

### E4-S4: collision
- [ ] T55: CollisionDetector `[P1]`
- [ ] T56: CollisionReport `[P1]`
- [ ] T57: CollisionResolver `[P1]`
- [ ] T58: ManualOverride対応 `[P1]`

### E4-S5: golden test
- [ ] T59: golden test基盤 `[P1]`
- [ ] T60: 主要golden JSON作成 `[P1]`
- [ ] T61: incremental layout基盤 `[P1]`

---

## Epic 5: score_cli

### E5-S1: コマンド
- [ ] T62: `score new` `[P0]`
- [ ] T63: `score validate` `[P0]`
- [ ] T64: `score import musicxml` / `score export musicxml` `[P0]`
- [ ] T65: `score export midi` `[P0]`
- [ ] T66: `score layout` / `score collisions` / `score fix-collisions` `[P1]`
- [ ] T67: `score inspect` / `score inspect --midi` `[P0]`
- [ ] T68: `score diff` `[P1]`
- [ ] T69: `score tui` / `score mcp serve` `[P1]`

---

## Epic 6: score_tui

### E6-S1: 基盤
- [ ] T70: ANSI terminal renderer `[P1]`
- [ ] T71: Mode管理（NORMAL / INSERT / VISUAL / COMMAND） `[P1]`
- [ ] T72: キーバインド管理 `[P1]`

### E6-S2: パネル
- [ ] T73: Score Tree パネル `[P1]`
- [ ] T74: Measure Grid パネル `[P1]`
- [ ] T75: Event List パネル `[P1]`
- [ ] T76: Collision Report パネル `[P1]`
- [ ] T77: Validation パネル `[P1]`
- [ ] T78: Command Palette `[P1]`

### E6-S3: editor
- [ ] T79: 音符入力（INSERT mode） `[P1]`
- [ ] T80: TAB Editor `[P2]`
- [ ] T81: Percussion Grid `[P2]`

### E6-S4: test
- [ ] T82: TUI snapshot test基盤 `[P1]`
- [ ] T83: 主要snapshot作成 `[P1]`

---

## Epic 7: score_mcp

### E7-S1: Server基盤
- [ ] T84: MCP stdio transport `[P1]`
- [ ] T85: Resource handler基盤 `[P1]`
- [ ] T86: Tool handler基盤 `[P1]`

### E7-S2: Resources
- [ ] T87: score / parts / measures resource `[P1]`
- [ ] T88: layout / collision / validation resource `[P1]`

### E7-S3: Tools
- [ ] T89: query tools `[P1]`
- [ ] T90: edit tools `[P1]`
- [ ] T91: layout / collision tools `[P1]`
- [ ] T92: import / export tools `[P1]`

### E7-S4: 安全性
- [ ] T93: Confirmation Handshake `[P1]`
- [ ] T94: Sandbox policy `[P1]`
- [ ] T95: Audit log `[P1]`

---

## 将来対応

- [ ] score_flutter package 骨格作成 `[v1]`
- [ ] 移調機能（transposing instrument） `[v1]`
- [ ] Flutter GUIエディタ（zoom / pan / gesture / touch） `[Future]`
- [ ] PDF / SVG / PNG export `[Future]`
- [ ] 段組・page layout（system break計算） `[Future]`
- [ ] MEI / LilyPond / Guitar Pro import/export `[Future]`
- [ ] Web対応（Wasm / dart2js） `[Future]`
- [ ] リアルタイム共同編集（CRDT / OT） `[Future]`
- [ ] クラウド同期 `[Future]`
- [ ] pub.dev 公開 `[Future]`
