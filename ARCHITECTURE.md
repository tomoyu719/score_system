# score_system アーキテクチャ設計書

バージョン: 1.0.0  
対応要件: REQUIREMENTS.md v1.0.0

---

## 目次

1. [システム概要](#1-システム概要)
2. [パッケージ構成](#2-パッケージ構成)
3. [依存関係](#3-依存関係)
4. [データフロー](#4-データフロー)
5. [score_core 設計](#5-score_core-設計)
6. [score_layout 設計](#6-score_layout-設計)
7. [score_io 設計](#7-score_io-設計)
8. [score_cli 設計](#8-score_cli-設計)
9. [score_tui 設計](#9-score_tui-設計)
10. [score_mcp 設計](#10-score_mcp-設計)
11. [横断関心事](#11-横断関心事)
12. [設計上の決定（ADR）](#12-設計上の決定adr)

---

## 1. システム概要

score_system は **headless engine ファースト**の個人用楽譜編集システムである。  
GUI を持たず、CLI / TUI / MCP Server の 3 インターフェースを通じてスコアを操作する。

```
┌──────────────────────────────────────────────────────┐
│                   操作インターフェース                  │
│   score_cli (CLI)  │  score_tui (TUI)  │  score_mcp  │
└──────────┬─────────┴──────────┬────────┴──────┬──────┘
           │                    │               │
           └────────────────────┼───────────────┘
                                │
                    ┌───────────▼───────────┐
                    │      score_core        │
                    │  (Command Engine +     │
                    │   Data Model +         │
                    │   Validation)          │
                    └───────────┬───────────┘
                       ┌────────┴────────┐
            ┌──────────▼──────┐  ┌───────▼──────────┐
            │  score_layout   │  │    score_io       │
            │ (Layout計算 +   │  │ (MusicXML/MIDI/   │
            │  Collision)     │  │  native JSON)     │
            └─────────────────┘  └──────────────────┘
                                 （将来）
                    ┌───────────▼───────────┐
                    │     score_flutter      │
                    │   (Flutter GUI骨格)    │
                    └───────────────────────┘
```

**重要な設計原則:**
- `score_core` と `score_layout` は `dart:io` / Flutter / terminal に一切依存しない
- すべての状態変更は `CommandEngine` を通じて行う（直接ミューテーション禁止）
- 全 public API の戻り値は JSON serializable

---

## 2. パッケージ構成

```
score_system/                    # Pub workspace root
  pubspec.yaml                   # workspace 定義（sdk >=3.5.0 <4.0.0）
  analysis_options.yaml          # 共有 strict linter 設定
  melos.yaml                     # Melos スクリプト定義
  bin/
    score.dart                   # CLI エントリポイント
  packages/
    score_core/                  # 楽譜意味構造・編集エンジン（pure Dart）
    score_layout/                # レイアウト計算・衝突回避
    score_io/                    # ファイル形式変換
    score_cli/                   # CLI コマンド実装
    score_tui/                   # Terminal UI
    score_mcp/                   # MCP Server
    score_flutter/               # Flutter UI（骨格のみ・将来実装）
  apps/
    score_flutter_app/           # Flutter アプリ（将来実装）
  tools/
    dep_checker.dart             # パッケージ境界チェックスクリプト
  test/
    fixtures/musicxml/           # MusicXML roundtrip テスト用サンプル
```

### 各パッケージの責務

| パッケージ | 責務 | `dart:io` 依存 |
|-----------|------|---------------|
| `score_core` | データモデル・Command Engine・Validation・Query | 禁止 |
| `score_layout` | LayoutTree 計算・Collision 検出/解決 | 禁止 |
| `score_io` | MusicXML/MIDI/native JSON の読み書き | 許可（ファイル I/O） |
| `score_cli` | `args` パース・コマンドルーティング | 許可 |
| `score_tui` | ANSI terminal レンダリング・modal editing | 許可 |
| `score_mcp` | MCP stdio transport・tool/resource ハンドラー | 許可 |
| `score_flutter` | Flutter widget 骨格（将来） | 禁止 |

---

## 3. 依存関係

```
score_core  ←──────────────────────────────── (外部 pure Dart パッケージのみ)

score_layout ──depends on──▶ score_core
score_io     ──depends on──▶ score_core

score_cli    ──depends on──▶ score_core, score_layout, score_io
score_tui    ──depends on──▶ score_core, score_layout, score_io
score_mcp    ──depends on──▶ score_core, score_layout, score_io

score_flutter ─depends on──▶ score_core, score_layout          (Flutter 非依存層のみ)
apps/score_flutter_app ──▶ score_flutter, score_core, score_layout, score_io
```

**境界違反は CI で自動検出する（`tools/dep_checker.dart`）。**  
逆方向依存（例: score_core → score_layout）はエラーとして扱う。

### 使用外部パッケージ

| 用途 | パッケージ |
|------|-----------|
| XML parse/build | `xml` |
| Terminal 制御 | `dart_console` |
| UUID 生成 | `uuid` |
| Immutable collections | `fast_immutable_collections` |
| JSON serialize | `json_annotation` + `json_serializable` |
| CLI args | `args` |
| テスト | `test` + `test_coverage` |
| Property-based test | `glados` |

`dart:ffi` は全パッケージで使用禁止。

---

## 4. データフロー

### コマンド適用フロー

```
[TUI / CLI / MCP]
       │ Command（immutable）
       ▼
CommandEngine.apply(command, score)
       │
       ├─▶ Validator.validate(prospectiveScore)
       │         │
       │         ├─ errors あり ──▶ CommandFailure（score 不変）
       │         └─ errors なし ──▶ proceed
       │
       ▼
 Updated Score（immutable）
       │
       ├─▶ score_layout.calculateIncremental(score) ──▶ LayoutTree / CollisionReport
       ├─▶ score_io.exportMusicXml(score)           ──▶ XML string
       └─▶ score_io.exportMidi(score)               ──▶ MIDI bytes
```

### Undo/Redo フロー

```
CommandEngine
  undoStack: [record_N, ..., record_1]   ← apply() で push
  redoStack: [record_A, record_B, ...]   ← undo() で push、apply() でクリア

undo() → undoStack.pop() → return record.scoreBefore
redo() → redoStack.pop() → return record.scoreAfter
```

Undo 戦略: **完全スナップショット方式**（MVP）。Score は immutable なので前後の参照を保持するだけでよい。

---

## 5. score_core 設計

### 5.1 データモデル階層

```
Score
  └── IList<Part>
        └── IList<Staff>
              └── IMap<measureNumber, Measure>
                    └── IMap<VoiceId, Voice>
                          └── IList<MusicEvent>
                                ├── NoteEvent
                                ├── RestEvent
                                └── ChordEvent
                                      └── IList<NoteEvent>

Score
  └── IList<MeasureHeader>     ← 全 Part 共通の小節メタ情報
        └── TimeSignature / KeySignature / Tempo / Barline

Score
  └── IList<BeamGroup>         ← edge 要素（ID 参照）
  └── IList<Slur>
  └── IList<Tie>
```

**全エンティティは `final class`（immutable value object）**。変更は `copyWith` パターンで新インスタンスを生成する。

### 5.2 ID 設計

```dart
extension type ScoreId(String value) {}
extension type PartId(String value) {}
extension type StaffId(String value) {}
// ... 同様に全エンティティ
```

型安全な ID ラッパー。値は UUID v4 文字列。  
異なるエンティティの ID を誤って代入するとコンパイルエラーになる。

### 5.3 Fraction

時間軸（音価・オフセット）は浮動小数点を使わず `Fraction(numerator, denominator)` で表現する。  
JSON 表現は `"3/4"` の文字列形式。

### 5.4 Command Engine

```dart
sealed class Command { ... }         // 全コマンドの基底
final class AddNoteCommand ...
final class BatchCommand ...         // 複数コマンドを atomic に適用

sealed class CommandResult { ... }
final class CommandSuccess { Score newScore; ... }
final class CommandFailure { Score originalScore; ... }   // 例外 throw しない

final class CommandEngine {
  CommandResult apply(Command, Score);
  CommandResult dryRun(Command, Score);  // 副作用なし
  CommandResult undo(Score);
  CommandResult redo(Score);
  CommandResult applyBatch(IList<Command>, Score);
}
```

- `apply()` はアトミック保証: 成功か元の Score を返すかのどちらか
- `BatchCommand` は all-or-nothing: 途中失敗で全ロールバック
- 内部エラー（バグ）は `ScoreException` を throw（checked exception 相当）

### 5.5 Validation

```dart
final class Validator {
  ValidationResult validate(Score score);
  ValidationResult validateCommand(Command command, Score score);
}
```

severity: `error`（Command をブロック）/ `warning`（通過させるが警告）/ `info`

### 5.6 内部ディレクトリ構成

```
score_core/lib/src/
  model/
    score.dart  part.dart  staff.dart  measure.dart  voice.dart
    note.dart  rest.dart  chord.dart  pitch.dart  duration.dart
    beam_group.dart  tuplet.dart  slur.dart  tie.dart
    dynamic.dart  lyric.dart  articulation.dart  ornament.dart
    clef.dart  key_signature.dart  time_signature.dart
    barline.dart  tempo.dart  rehearsal_mark.dart
    tab/          (TabConfig, TabFret, GuitarTechnique, Tuning)
    percussion/   (DrumMapping, DrumInstrument, PercussionConfig)
    cross_staff/  (CrossStaffRef, CrossStaffBeamGroup)
    voice_model/  (VoiceConfig, VoicePriority)
  command/
    command.dart  command_result.dart  command_engine.dart
    command_history.dart  audit_log.dart
    add_note_command.dart  remove_note_command.dart  ...
  validation/
    validator.dart  validation_result.dart  validation_rule.dart  ...
  query/
    score_query.dart  note_query.dart  measure_query.dart
  selection/
    selection.dart  selection_range.dart
```

---

## 6. score_layout 設計

### 6.1 内部座標系

- 単位: **Staff Space（sp）**。1sp = staff line の間隔
- 5 線譜の staff 高さ = 4sp
- X 軸: 時間軸（左→右）、Y 軸: 音高軸（下→上、上方向が正）
- 原点: 各 staff 左端・下線

### 6.2 LayoutTree

```
LayoutTree
  └── IList<SystemLayout>
        └── IList<StaffLayout>
        └── IList<MeasureLayout>
              └── IList<VoiceLayout>
                    └── NoteLayout / RestLayout / BeamLayout / StemLayout
                          └── BoundingBox (left/top/right/bottom in sp)
                          └── smuflGlyphName (string ID)
```

LayoutTree 全体は JSON serializable。golden test のベースとして使用する。

### 6.3 Measure Spacing アルゴリズム

**Spring モデル（Gourlay 変形）**:

1. 各 event の natural width（音価に比例）を計算
2. 最短 duration 音符に `min_width` を割り当て
3. 各小節の `contentWidth` を算出
4. システム幅に合わせて justify（均等伸長）

MVP はシングルシステム（段組なし）として計算。

### 6.4 Voice Layout

- Stem 方向は `VoiceConfig.stemDirectionPolicy`（up/down/auto）に従う
- 同時刻 Note 間の X offset を計算（notehead collision 回避）
- Rest positioning は voice 数・stem 方向から自動決定

### 6.5 Collision Detection / Resolution

**検出:** BoundingBox intersection（notehead / accidental / articulation 等）  
**stemとbeam:** line segment intersection  
**slur/tie:** bezier curve の bbox 近似

**解決優先度モデル（数値が小さいほど不動）:**

| 優先度 | 要素 | 移動制約 |
|--------|------|----------|
| 1（不動）| staff line / barline / notehead | 移動不可 |
| 2 | stem / beam | Y 方向のみ伸長 |
| 3 | accidental | X 方向のみ |
| 4 | articulation | Y 方向 |
| 5 | dynamic / tempo text | Y 方向 |
| 6 | lyric | Y 方向（下） |
| 7 | fingering / chord symbol | X/Y 両方向 |
| 8（最低）| rehearsal mark | Y 方向 |

解決は最大 10 回反復。解消しない場合は warning として残す。  
`isManualOverride: true` の要素は自動解決でスキップする。

### 6.6 Incremental Layout

- `LayoutCache` に MeasureLayout をキャッシュ
- Command apply 後に `changedMeasureSet` を算出
- 変更小節とその隣接小節のみ再計算

---

## 7. score_io 設計

### 7.1 対応フォーマット（MVP）

| 形式 | 方向 | 実装 |
|------|------|------|
| `.score.json`（native） | read/write | `json_serializable` |
| MusicXML 3.1 | import/export | `xml` パッケージ |
| MIDI SMF Type 1 | export | 独自 binary encoder |
| MIDI events JSON dump | 読み取り専用 | MIDI binary → JSON |

### 7.2 native format（`.score.json`）

- UTF-8 JSON テキスト（バイナリ禁止、テキストエディタで直接編集可能）
- `$schema_version` フィールドでマイグレーション管理
- Fraction 値は `"3/4"` 文字列表現
- 2 スペースインデント
- ID は UUID v4 文字列
- タイムスタンプ等の非決定的な値はデフォルト off（Reproducible Export 保証）

### 7.3 MusicXML Import 方針

- partwise MusicXML を DOM parse → Score model に変換
- 非対応要素は `ValidationWarning` を出して skip（例外 throw しない）
- import → validate → export → import の roundtrip で lossless（対応要素のみ）

### 7.4 MIDI Export 方針

- SMF Type 1（マルチトラック）を標準出力
- `--type 0` オプションで Type 0 も選択可能（v1）
- テンポ・拍子は Meta event として出力
- 同一 Score から常に同一バイナリを生成（Reproducible Export）

---

## 8. score_cli 設計

### 8.1 コマンド一覧

```
score new          # .score.json 新規作成
score validate     # バリデーション
score import       # MusicXML import
score export       # MusicXML / MIDI export
score layout       # LayoutTree JSON 出力
score collisions   # CollisionReport JSON 出力
score fix-collisions  # 衝突自動解決
score inspect      # スコア検査 / MIDI JSON dump
score diff         # 2 スコア差分
score tui          # TUI 起動
score mcp serve    # MCP Server 起動
```

### 8.2 出力設計

- デフォルト出力: **JSON**（CI・コーディングエージェント向け）
- `--format pretty`: 人間可読形式
- エラーは常に `stderr` に JSON 形式で出力

### 8.3 終了コード

| コード | 意味 |
|--------|------|
| 0 | 成功 |
| 1 | エラー（ファイル未発見・parse 失敗等） |
| 2 | Validation failure |
| 3 | Layout collision 未解決 |

---

## 9. score_tui 設計

### 9.1 レンダリング基盤

- `dart_console` でキー入力・カーソル制御・カラー出力
- カスタム ANSI エスケープレイヤーで Unicode ブロック文字による楽譜近似表示
- 完全なグラフィクスは将来の Flutter renderer 担当

### 9.2 Modal Editing

**Vim 準拠の 5 モード:**

| モード | 説明 | 入口 |
|--------|------|------|
| NORMAL | カーソル移動・コマンド入力 | `Esc` |
| INSERT | 音符入力（`a-g`, `#`, `&`, `r`） | `i` |
| VISUAL | 範囲選択 | `v` |
| COMMAND | コマンドパレット（ファジー補完） | `:` |
| SEARCH | 検索 | `/` |

### 9.3 パネル構成

```
┌──────────────┬──────────────────────────────────────┐
│  Score Tree  │                                      │
│  (<leader>t) │     Measure Grid / Event List        │
│              │     Voice Lane / TAB Editor          │
│              │     Percussion Grid                  │
├──────────────┴──────────────────────────────────────┤
│       Collision Report / Validation Panel           │
├─────────────────────────────────────────────────────┤
│  : command palette                                  │
└─────────────────────────────────────────────────────┘
```

各パネルは独立したコンポーネントとして実装し、`<leader>x` キーで切り替える。

### 9.4 状態管理

TUI の状態（現在モード・カーソル位置・選択範囲・アクティブパネル）は `TuiState` として管理する。  
スコアの変更は CommandEngine 経由のみ。TUI 独自のミューテーションは行わない。

---

## 10. score_mcp 設計

> MCP Server は補助機能。CLI・TUI の実装が優先される。

### 10.1 プロトコル仕様

- **MCP Specification 2024-11-05**（JSON-RPC 2.0、stdio transport）
- HTTP SSE は v2 で検討

### 10.2 Resource URI スキーム

```
score://current                       # スコア全体
score://parts                         # パート一覧
score://parts/{partId}
score://parts/{partId}/staves/{staffId}
score://measures/{measureNumber}
score://voices/{voiceId}
score://layout                        # 最新 LayoutTree
score://collisions                    # 最新 CollisionReport
score://validation                    # 最新 ValidationResult
score://history                       # AuditLog
```

### 10.3 権限モデルと Confirmation Handshake

| 操作 | 権限 | Confirmation |
|------|------|-------------|
| 読み取り（query） | 常に許可 | 不要 |
| 音符追加・編集 | sandbox 内 | 不要 |
| パート/小節 追加・削除 | sandbox 内 | **必要** |
| ファイル上書き保存 | sandbox 内 | **必要** |
| sandbox 外ファイルアクセス | 禁止 | 不可 |

### 10.4 Sandbox Policy

`--sandbox <dir>` で指定したディレクトリ配下のみアクセス許可。  
パストラバーサル（`../` 等）はリクエスト受信時に検証して拒否する。

### 10.5 Audit Log

全 tool call を JSONL 形式でファイルに記録する:

```json
{"timestamp": "...", "tool": "add_note", "source": "mcp", "success": true}
```

---

## 11. 横断関心事

### 11.1 テスト戦略

| テスト種別 | 場所 | 実行タイミング |
|------------|------|--------------|
| Unit test | 全パッケージ | PR / push |
| Command Engine test | score_core | PR / push |
| Layout golden test | score_layout/test/golden/ | PR / push |
| MusicXML roundtrip test | score_io/test/fixtures/ | PR / push |
| TUI snapshot test | score_tui/test/snapshots/ | PR / push |
| MCP tool test | score_mcp | PR / push |
| Dependency boundary test | tools/dep_checker.dart | PR / push |
| Performance benchmark | score_layout/benchmark/ | 週次 |
| Fuzz test | score_core / score_io | 夜間 |

**Layout golden test:** LayoutTree を JSON serialize してファイルと比較（画像不要）。  
**TUI snapshot test:** ANSI エスケープを除去したプレーンテキストで比較。  
カバレッジ目標: **80%以上**（score_core + score_layout は 85% 以上）。

### 11.2 CI（GitHub Actions）

3 ジョブマトリクス: `ubuntu-latest` / `macos-latest` / `windows-latest`

```
analyze   → melos run analyze  (warning 0 / error 0 必須)
test      → melos run test     (全 OS)
golden    → melos run test_layout_golden
deps_check→ melos run deps_check
build_cli → dart compile exe bin/score.dart -o build/score
```

### 11.3 エラーハンドリング方針

- `CommandEngine` はすべてのエラーを `CommandFailure` として返す（例外 throw しない）
- 内部バグは `ScoreException` を throw（呼び出し元で catch して `CommandFailure` に変換）
- CLI はエラーを `stderr` に JSON で出力し、適切な exit code で終了する
- MusicXML の非対応要素は `ValidationWarning` に記録して処理を継続する

### 11.4 パフォーマンス目標

| 操作 | 目標値 |
|------|--------|
| layout 計算（10 小節・4 声・1 パート） | ≤ 30ms |
| layout 計算（50 小節・4 声・2 パート） | ≤ 300ms |
| MusicXML import（200 小節） | ≤ 1000ms |
| MIDI export（200 小節） | ≤ 300ms |
| Collision detection（200 要素） | ≤ 100ms |
| Command apply（single） | ≤ 20ms |

---

## 12. 設計上の決定（ADR）

### ADR-01: Immutable Data Model + Command Engine

**決定:** Score とその全子要素を immutable value object として実装し、状態変更は `CommandEngine.apply()` のみを通じて行う。

**理由:** Undo/Redo を完全スナップショット方式で実装できる。Score の前後状態を参照として保持するだけで実現でき、diff 計算が不要。テストで任意の状態を容易に構築できる。

**トレードオフ:** 大規模スコアでのコピーコスト。`fast_immutable_collections` の structural sharing で緩和する。将来必要になれば diff 方式に移行可能な設計にしておく。

### ADR-02: Staff Space（sp）を内部座標単位とする

**決定:** レイアウト計算の内部座標単位を Staff Space（1sp = staff line 間隔）とする。

**理由:** SMuFL の標準単位と一致するためグリフ寸法をそのまま使用できる。画面解像度・フォントサイズと独立しており、Flutter / TUI / CLI のいずれでも同じ計算結果を使い回せる。

### ADR-03: Fraction による時間表現（浮動小数点回避）

**決定:** 音価・タイミングをすべて `Fraction(int numerator, int denominator)` で表現する。

**理由:** 複雑な連符（例: 5 連符中の付点音符）を浮動小数点で表現すると誤差が累積し、拍子整合性の検証が困難になる。integer exact arithmetic で処理することで roundtrip での精度劣化を防ぐ。

### ADR-04: Undo/Redo は完全スナップショット方式（MVP）

**決定:** `CommandRecord` に `scoreBefore` と `scoreAfter` の両 Score を保持する。

**理由:** データモデルが immutable であるため、参照を保持するコストは低い。最大 1000 ステップでメモリ上限を設定する。将来大規模スコアで問題が生じた場合は structural diff 方式に移行する。

### ADR-05: MCP Server は補助機能として後回し

**決定:** CLI / TUI の実装が完了してから MCP Server を実装する。

**理由:** MCP Server の tool は CLI コマンドのラッパーとして実装できるため、CLI が完成していれば MCP の実装コストは低い。MVP の完了定義（MusicXML roundtrip + headless layout + CLI 全コマンド）に MCP は含まれない。

### ADR-06: TUI は dart_console + カスタム ANSI レンダリング

**決定:** キー入力・カーソル制御に `dart_console` を使い、楽譜プレビューは独自 Unicode ブロック文字レンダリングで実装する。

**理由:** Dart エコシステムで TUI ライブラリの選択肢が限られる中、`dart_console` が最も安定している。完全な楽譜グラフィクスは Flutter renderer で行う方針のため、TUI は「テキストで読める近似表示」に割り切る。

### ADR-07: score_core は pure Dart（dart:ffi 禁止）

**決定:** `score_core` と `score_layout` で `dart:ffi` を使用しない。

**理由:** Flutter なしでの単体テスト可能性を保証するため。SMuFL フォントのグリフ寸法参照は `smuflGlyphName` 文字列 ID で抽象化し、実際のフォントレンダリングは Flutter レイヤーに委ねる。

---

*詳細な機能要件・受け入れ条件・タスク分解は [REQUIREMENTS.md](./REQUIREMENTS.md) を参照。*
