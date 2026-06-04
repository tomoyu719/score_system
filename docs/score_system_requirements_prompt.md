# フル機能の楽譜編集システム 要件定義プロンプト

あなたは、楽譜編集システム、音楽記譜ソフト、DAW連携、Dart、Flutter、CLI/TUI、MCP Server、MusicXML、MIDI、楽譜レイアウトエンジン、衝突回避アルゴリズムに精通したシニアプロダクトマネージャー兼ソフトウェアアーキテクトです。

これから「フル機能の楽譜編集システム」の要件定義を行ってください。

# 前提

開発対象は、Dartのみで実装するフル機能の楽譜編集システムです。

## 技術方針

- Rustは使用しない
- C++は使用しない
- Native extension / FFI は使用しない
- 実装言語はDartのみ
- Flutter UI、headless engine、CLI、TUI、MCP Server、MusicXML/MIDI処理、レイアウトエンジン、衝突回避エンジンはすべてDartで実装する
- Flutterは将来的なGUI frontendとして使う
- MVPはFlutter GUIではなく、headless engine中心で作る
- monorepo管理には Pub Workspaces + Melos を使用する
- core engineはFlutter非依存のpure Dart packageとして設計する
- strictなlinterを全packageに適用する（`package:lints` + Dart analyzer strict modeを使用）
- analyzer strict modeとして以下をすべてのpackageの `analysis_options.yaml` に適用する
  - `implicit-casts: false`
  - `implicit-dynamic: false`
  - `strict-casts: true`
  - `strict-inference: true`
  - `strict-raw-types: true`

## コーディング規約

以下の規約をプロジェクト全体で遵守する。

### テスト駆動開発（TDD）

- 実装前にテストを書く（Red → Green → Refactor）
- 新機能・バグ修正はすべてテストから始める
- テストなしのコードをmainブランチにマージしない
- unit test・golden test・integration testをすべてCIで必須とする

### ネストif禁止（二重if禁止）

- if文のネストは1段まで。二重以上のif nestは禁止する
- ネストが深くなる場合は早期リターン・ガード節・メソッド分割で解決する

```dart
// NG
if (a) {
  if (b) {
    doSomething();
  }
}

// OK（早期リターンで解決）
if (!a) return;
if (!b) return;
doSomething();
```

### 1ファイル1クラス

- 1つの `.dart` ファイルには1つのpublic classのみ定義する
- ファイル名はクラス名のsnake_caseとする（例: `add_note_command.dart`）
- privateなヘルパークラスは同ファイル内に定義してもよいが、最小限に留める

### 早期リターンの積極的な使用

- ガード節を先頭に集め、正常系のロジックをネストなしで記述する
- nullチェック・バリデーションは関数の先頭で処理して即リターンする

```dart
// NG
String process(String? input) {
  if (input != null) {
    if (input.isNotEmpty) {
      return input.trim();
    }
  }
  return '';
}

// OK
String process(String? input) {
  if (input == null) return '';
  if (input.isEmpty) return '';
  return input.trim();
}
```

## 対象プラットフォーム

将来的に以下すべてを対象にする。

- macOS
- Windows
- Linux
- iOS
- Android
- Web
- terminal

ただし、MVPでは以下を優先する。

- headless engine
- CLI
- TUI
- MCP Server
- MusicXML import/export
- MIDI export
- レイアウト計算
- 衝突検出・衝突解決

## MVP方針

MVPではGUIアプリではなく、headless engineを中心に構築する。

MVPで必須とするもの：

- 楽譜内部データモデル
- command engine
- undo / redo
- validation
- MusicXML import/export
- MIDI export
- native project format
- レイアウト計算
- 衝突検出
- 衝突解決
- terminal TUI
- CLI
- MCP Server
- N voice対応
- TAB基盤
- percussion notation基盤
- percussion TAB基盤
- cross-staff表現の内部モデル

MVPで初期対象外とするもの：

- 完全なFlutter GUIエディタ
- PDF export
- SVG export
- PNG export
- 高度な印刷組版
- リアルタイム共同編集
- クラウド同期
- CRDT
- OT
- 複数ユーザー編集競合解決

ただし、将来的にFlutter GUI、印刷、画像/PDF出力、共同編集を追加できる設計にする。

# 主要要件

このシステムは以下に対応する。

## 1. Terminal TUI

terminalで動作するTUIを持つ。

TUIでは以下を扱えること。

- keyboard-first workflow
- modal editing
- score tree
- measure grid
- event list
- voice lane
- TAB editor
- percussion grid
- collision report panel
- command palette
- validation panel
- ASCII / Unicode preview
- search
- jump to measure
- undo / redo
- filter by part / staff / voice
- headless layout result inspection

## 2. MCP Server

このシステム自体がMCP Serverとして動作する。

MCP Serverは以下を提供する。

- score resource
- part resource
- staff resource
- measure resource
- voice resource
- layout resource
- collision report resource
- validation resource
- score query tools
- score edit tools
- layout calculation tools
- collision analysis tools
- collision fix proposal tools
- MusicXML import/export tools
- MIDI export tools
- AI assistantによる楽譜編集支援API

MCP Serverは、TUI/CLI/Flutterと同じcommand engineを使用する。

## 3. 衝突回避

衝突回避は、楽譜レイアウト上の図形衝突のみを対象とする。

対象とする衝突：

- notehead
- stem
- beam
- accidental
- articulation
- slur
- tie
- dynamic
- lyric
- chord symbol
- fingering
- fret number
- string number
- percussion glyph
- staff
- barline
- tuplet bracket
- rehearsal mark
- tempo text
- system text
- cross-staff beam
- cross-staff stem
- N voice間の衝突

対象外：

- 複数ユーザー編集競合
- CRDT
- OT
- real-time collaboration conflict
- MCP経由の同時編集競合

ただし、将来的な拡張余地は残す。

## 4. TAB対応

以下のTABに対応する。

- guitar TAB
- bass TAB
- percussion TAB

guitar / bass TABでは以下を扱う。

- tuning
- string count
- fret number
- string number
- hammer-on
- pull-off
- slide
- bend
- release
- vibrato
- palm mute
- harmonics
- tapping
- dead note
- ghost note
- standard notationとの同期
- TABのみ編集
- 五線譜とTABの同時編集

## 5. percussion対応

percussionについては以下の両方を対象とする。

1. ドラム譜・打楽器譜としてのpercussion notation
2. TAB的な入力・表示方式を打楽器にも拡張するpercussion TAB

percussion notationでは以下を扱う。

- drum kit mapping
- unpitched instrument mapping
- notehead type
- staff line mapping
- percussion clef
- voice separation
- stem direction
- articulations
- sticking
- rudiments
- playback mapping

percussion TABでは以下を扱う。

- lineごとのinstrument mapping
- pad / grid representation
- stroke symbols
- ghost notes
- accents
- flams
- rolls
- open / closed hi-hat
- cymbal choke
- MIDI note mapping
- standard percussion notationとの変換

## 6. cross-staff beaming / stemming

以下に対応する。

- cross-staff beaming
- cross-staff stemming
- cross-staff notes
- logical voiceとvisual staffの分離
- beamが複数staffにまたがる表現
- stemが複数staffにまたがる表現
- stem direction
- beam slope
- staff間スペーシング
- collision avoidance
- playbackとの整合性
- MusicXML / MEI export時の表現

## 7. N voice対応

4声に限定せず、任意数のvoiceを扱う。

以下を考慮する。

- voice ID
- voice layer
- voice priority
- stem direction policy
- beam grouping
- rest positioning
- shared notehead
- overlapping duration
- cross-staff voice
- hidden voice
- playback voice
- layout voice
- editing voice
- export時のvoice mapping
- MusicXMLのvoice制約との対応

# Dart-only Architecture

以下のDart package分割を前提にする。

```text
score_system/
  pubspec.yaml
  analysis_options.yaml
  packages/
    score_core/
    score_layout/
    score_io/
    score_cli/
    score_tui/
    score_mcp/
    score_flutter/
  apps/
    score_flutter_app/
  tools/
```

## packageの役割

### score_core

楽譜の意味構造と編集操作の中心。

担当：

- Score / Part / Staff / Measure / Voice / Note / Rest
- Chord
- Beam
- Stem
- Tie
- Slur
- Tuplet
- Articulation
- Ornament
- Dynamic
- Lyric
- Fingering
- TAB model
- Percussion model
- Cross-staff model
- N voice model
- Command engine
- Undo / Redo
- Validation
- Selection model
- Score query API
- 変更履歴

制約：

- Flutterに依存しない
- dart:uiに依存しない
- terminalに依存しない
- MCPに依存しない
- CLIに依存しない
- pure Dart packageとして実装する

### score_layout

score_coreの楽譜モデルを受け取り、表示用の配置情報を作る。

担当：

- measure spacing
- staff spacing
- voice layout
- TAB layout
- percussion layout
- cross-staff beaming layout
- cross-staff stemming layout
- collision detection
- collision resolution
- layout tree
- render primitives
- bounding box
- glyph placement

制約：

- 描画はしない
- Flutterに依存しない
- terminal描画に依存しない
- score_coreにのみ依存する

出力：

- LayoutTree
- RenderPrimitive[]
- BoundingBox[]
- CollisionReport

### score_io

ファイル形式との変換を担当する。

担当：

- native project format（`.score.json`、UTF-8 JSONテキスト形式）
- MusicXML import/export
- MIDI export
- MIDI events text dump（`score inspect --midi` 用のJSON出力）
- optional MEI import/export
- serialization
- deserialization

制約：

- score_coreに依存する
- score_layoutには原則依存しない
- dart:io依存はplatform abstractionで隔離する
- Web対応を考慮する
- native project formatはバイナリ不可。テキストエディタ・コーディングエージェントが直接読めるJSONとする

### score_cli

CLI入口。

担当：

- score new
- score validate
- score import musicxml
- score export musicxml
- score export midi
- score layout
- score collisions
- score fix-collisions
- score inspect
- score tui
- score mcp serve

制約：

- ロジックを持たない
- 引数を解析してscore_core / score_layout / score_ioを呼び出すadapterに徹する

### score_tui

terminal上の編集UI。

担当：

- modal editing
- keyboard-first editing
- score tree view
- measure grid view
- event list view
- voice lane view
- TAB editor view
- percussion grid view
- collision report panel
- validation panel
- command palette
- terminal preview

制約：

- 編集ロジックを持たない
- key inputをscore_coreのCommandに変換する
- 表示はscore_layoutのLayoutTreeをもとに行う

### score_mcp

MCP Server。

担当：

- MCP resources
- MCP tools
- MCP prompts
- score query
- score edit
- validation
- layout calculation
- collision analysis
- collision fix proposal
- MusicXML import/export
- MIDI export
- audit log
- destructive operation confirmation
- sandbox policy

制約：

- ロジックを持たない
- MCP tool callをscore_coreのCommandに変換する
- TUI/CLI/Flutterと同じcommand engineを使用する

### score_flutter

将来のFlutter UI用frontend package。

担当：

- CustomPainter rendering
- gestures
- selection UI
- notation viewport
- zoom / pan
- keyboard shortcuts
- touch / stylus input
- platform UI
- accessibility layer

制約：

- core logicを持たない
- score_coreとscore_layoutを呼び出すfrontendに徹する
- score_core / score_layoutをFlutter依存にしてはならない

# アーキテクチャ関係

以下の依存関係を守る。

```text
score_core
  -> external pure Dart packages only

score_layout
  -> score_core

score_io
  -> score_core

score_cli
  -> score_core
  -> score_layout
  -> score_io

score_tui
  -> score_core
  -> score_layout
  -> score_io

score_mcp
  -> score_core
  -> score_layout
  -> score_io

score_flutter
  -> score_core
  -> score_layout

apps/score_flutter_app
  -> score_flutter
  -> score_core
  -> score_layout
  -> score_io
```

全体像：

```text
                          apps/score_flutter_app
                                   |
                                   v
                            score_flutter
                                   |
                                   v
+-------------+     +--------- score_core ---------+     +-------------+
| score_cli   | --> | command / model / validation | <-- | score_mcp   |
+-------------+     +-------------+----------------+     +-------------+
                                  ^
+-------------+                   |
| score_tui   | ------------------+
+-------------+                   |
                          +-------+-------+
                          v               v
                    score_layout      score_io
```

より正確な役割：

```text
score_core:
  楽譜の真実、意味構造、編集操作

score_layout:
  見た目の位置、衝突検出、衝突解決

score_io:
  外部形式との変換

score_cli:
  command-line adapter

score_tui:
  terminal UI adapter

score_mcp:
  MCP Server adapter

score_flutter:
  Flutter UI adapter
```

# データの流れ

## 編集操作

```text
Input
  TUI / CLI / MCP / Flutter
      |
      v
Command
      |
      v
score_core
      |
      v
Updated Score
      |
      +----> score_layout ----> LayoutTree / CollisionReport
      |
      +----> score_io --------> MusicXML / MIDI / Native format
```

## TUIで音符を追加する例

```text
key input
  -> AddNoteCommand
  -> score_core.commandEngine.apply()
  -> score_core.validate()
  -> score_layout.calculateIncremental()
  -> score_tui.render()
```

## MCP経由で音符を追加する例

```text
MCP tool call
  -> AddNoteCommand
  -> score_core.commandEngine.apply()
  -> score_core.validate()
  -> score_layout.calculate()
  -> MCP response
```

## MusicXML import/export

```text
MusicXML
  -> score_io.importMusicXml()
  -> score_core.Score
  -> score_core.validate()
  -> score_io.exportMusicXml()
```

# Melos / Pub Workspaces方針

このプロジェクトはDart-only monorepoとして構成する。

monorepo管理には Pub Workspaces と Melos を使用する。

## 目的

- 複数Dart packageを単一repositoryで管理する
- core / layout / io / cli / tui / mcp / flutter を明確に分離する
- package境界を守る
- 一括 analyze / test / format / build を可能にする
- CI/CDを簡素化する
- 将来的なpub.dev公開とrelease automationに備える

## Linter / Analyzer方針

全packageに以下のlinter設定を適用する。

```yaml
# analysis_options.yaml（各packageに配置）
include: package:lints/recommended.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    - always_declare_return_types
    - avoid_dynamic_calls
    - avoid_type_to_string
    - cancel_subscriptions
    - close_sinks
    - comment_references
    - discarded_futures
    - literal_only_boolean_expressions
    - no_adjacent_strings_in_list
    - prefer_relative_imports
    - throw_in_finally
    - unawaited_futures
    - unnecessary_statements
```

- workspace root の `analysis_options.yaml` を共有ベースとし、各packageで必要に応じてoverrideする
- `melos run analyze` はすべてのpackageに対してwarning 0、error 0を要求する
- CI上でanalyzeが失敗した場合はビルドを中断する

## Melosに求める機能

- workspace packageの管理
- 一括analyze（strict mode、warning 0・error 0を必須とする）
- 一括test
- 一括format
- CLI executable build
- layout golden test
- MCP test
- package dependency boundary check
- release / publish support, future

## Melos script候補

```text
melos run analyze
melos run test
melos run format
melos run check
melos run test_core
melos run test_layout
melos run test_io
melos run test_cli
melos run test_tui
melos run test_mcp
melos run test_layout_golden
melos run build_cli
melos run deps_check
```

# CLI / Headless仕様

CLIでは以下のようなコマンドを想定する。

```text
score new
score validate <file>
score import musicxml <input> -o <output>
score export musicxml <input> -o <output>
score export midi <input> -o <output>
score layout <input> [--format json|pretty]
score collisions <input> [--format json|pretty]
score fix-collisions <input> -o <output>
score inspect <input> [--format json|pretty]
score inspect --midi <midi-file>
score diff <before> <after> [--format json|pretty]
score tui <file>
score mcp serve
```

CLIの出力形式方針：

- デフォルトはJSON（コーディングエージェント・CI向け）
- `--format pretty` を指定するとヒューマンリーダブルなテキスト出力
- `score inspect --midi <file>` はMIDIバイナリをJSON形式のイベントリストとして出力する
- すべてのエラーはstderrにJSON `{"error": "..."}` 形式で出力する
- 終了コードはUNIX標準（0=成功、1=エラー、2=validation failure）

MVPでは単一コマンド `score` として配布する。

# 配布方針

## Dart packages

core package群はpub.devまたはGit dependencyで配布可能にする。

候補：

- score_core
- score_layout
- score_io
- score_cli
- score_tui
- score_mcp
- score_flutter

MVP初期はprivate Git dependencyでよい。

## CLI / TUI / MCP

MVPでは単一コマンド `score` として配布する。

```text
score tui
score mcp serve
```

## Native executable

Dart SDKなしで使えるように、`dart compile exe` によるネイティブ実行ファイル配布を検討する。

対象：

- macOS arm64
- macOS x64
- Windows x64
- Linux x64
- Linux arm64

## Flutter app

将来的なFlutterアプリは、Dart core packageを直接依存として組み込む。

FFIは使わない。

## Web

Flutter WebではDart coreをそのまま使用する。

重い処理については以下を検討する。

- isolate
- chunked processing
- incremental layout
- Web Worker相当の設計
- layout cache

# レイアウトエンジン要件

以下を定義する。

- 音符配置
- 休符配置
- 臨時記号配置
- 連桁配置
- 符尾配置
- 符鉤配置
- スラー配置
- タイ配置
- 強弱記号配置
- 歌詞配置
- chord symbol配置
- fingering配置
- TAB配置
- percussion配置
- cross-staff配置
- N voice配置
- 小節内スペーシング
- 譜表間スペーシング
- system layout
- page非依存の論理レイアウト
- 将来のpage layout対応
- incremental layout
- deterministic layout
- layout cache
- collision detection
- collision resolution
- user overrideと自動配置の共存

# 衝突回避仕様

以下を詳細に定義する。

- 衝突対象
- bounding box model
- priority model
- constraint model
- minimum distance
- avoidance direction
- retry strategy
- conflict severity
- automatic resolution
- manual override
- collision report
- deterministic result
- layout regression test
- N voice間衝突
- cross-staff衝突
- TAB/percussion固有衝突

# ファイル形式

初期対象：

- native project format（`.score.json`、UTF-8 JSON、テキストエディタ・コーディングエージェントが直接読める形式）
- MusicXML import/export
- MIDI export（バイナリ）+ MIDI events JSON dump（テキスト検証用）

任意・将来対象：

- MEI import/export
- LilyPond export
- Guitar Pro import/export
- MuseScore互換形式の扱い

初期対象外：

- PDF export
- SVG export
- PNG export

ただし、将来的なrenderer追加に備え、layout resultは中立的なLayoutTreeとして設計する。

# 非機能要件

以下を定義する。

- performance
- deterministic layout
- reproducible export
- reliability
- offline support
- accessibility
- security
- portability
- testability
- maintainability
- extensibility
- memory usage
- large score handling
- isolate対応
- Web対応
- CI/CD対応
- package boundary enforcement

# テスト戦略

以下を含める。

- unit test
- command engine test
- validation test
- layout golden test
- layout regression test
- collision detection test
- collision resolution test
- MusicXML import/export test
- MIDI export test
- native format roundtrip test
- CLI test
- TUI test
- MCP tool test
- cross-platform test
- performance benchmark
- fuzz test
- property-based test
- dependency boundary test

layout golden testでは、画像ではなくLayoutTree JSONをgoldenとして比較する。

TUI testでは、ANSIエスケープコードを除去したプレーンテキストスナップショットをgoldenとして比較する。

コーディングエージェント互換性方針：

- すべてのCLI出力はデフォルトJSON（コーディングエージェントがパース・検証可能）
- native project formatはUTF-8 JSON（コーディングエージェントが直接読み書き可能）
- MIDIバイナリはJSONイベントリストとして検査可能（`score inspect --midi`）
- TUIスナップショットはANSI除去済みテキスト（コーディングエージェントが文字列比較可能）
- CollisionReport・LayoutTree・ValidationResultはすべてJSON serializable

# 出力してほしい内容

以下の構成で要件定義書を作成してください。

## 1. 確認質問

要件定義に必要な質問を、優先度順に並べてください。

分類：

- プロダクト目的
- 対象ユーザー
- MVP範囲
- Dart-only制約
- TUI
- MCP Server
- 楽譜編集機能
- TAB
- percussion
- cross-staff
- N voice
- MusicXML
- MIDI
- native format
- レイアウト
- 衝突回避
- Melos / monorepo
- 配布
- テスト
- 開発体制

## 2. 仮定

回答がない場合の前提・仮定を明示してください。

## 3. プロダクト概要

目的、価値、対象ユーザー、主要ユースケースを定義してください。

## 4. MVP方針

headless-firstで何を作るかを明確にしてください。

## 5. スコープ

以下に分けてください。

- In Scope
- Out of Scope
- Future Scope

## 6. 機能要件

ID付きで定義してください。

各要件には以下を含めてください。

- 概要
- 詳細
- 優先度
- 受け入れ条件
- 関連する技術課題

## 7. 非機能要件

performance、deterministic layout、reproducible export、security、testability、maintainabilityなどを含めてください。

## 8. 技術アーキテクチャ

Dart-only architectureとして、package構成、依存関係、データフローを定義してください。

## 9. Monorepo / Melos設計

Pub Workspaces + Melosを前提に、workspace構成、script、CI、dependency boundaryを定義してください。

## 10. データモデル

主要エンティティと関係を定義してください。

必要であればDart風の擬似コードで表現してください。

## 11. Command Engine仕様

TUI/CLI/MCP/Flutterが共通で使うcommand engineを定義してください。

以下を含めてください。

- Command
- CommandResult
- Undo / Redo
- Validation
- Error handling
- Atomic operation
- Batch command
- Dry run
- Audit log

## 12. レイアウト・衝突回避仕様

楽譜レイアウトの自動配置、制約、衝突検出、衝突解決、手動調整の仕様を詳しく書いてください。

## 13. TUI仕様

画面構成、操作体系、キー操作、編集モード、プレビュー方式を定義してください。

## 14. CLI/headless仕様

CLIコマンド例、headless処理例、CI/CD利用例を含めてください。

## 15. MCP Server仕様

MCP resource/tool/promptの候補、API例、権限モデル、安全性を定義してください。

## 16. TAB / percussion仕様

guitar、bass、percussion TAB、percussion notationの仕様を定義してください。

## 17. cross-staff / N voice仕様

cross-staff beaming、cross-staff stemming、N voiceの仕様を定義してください。

## 18. ファイル形式・入出力

対応すべき形式を優先度付きで定義してください。

## 19. 配布方針

Dart package、CLI executable、MCP Server、Flutter app、Webの配布方法を定義してください。

## 20. MVP / v1 / v2ロードマップ

実装順序を現実的に分解してください。

## 21. リスクと技術課題

特に以下を評価してください。

- Dart-onlyでの性能限界
- 大規模スコア処理
- レイアウトエンジンの難易度
- 衝突回避アルゴリズム
- TUI preview
- MCP Server安全性
- MusicXML互換性
- MIDI export
- N voice設計
- cross-staff表現
- TAB/percussion表現
- Flutter GUIへの将来拡張
- Web対応
- Melos運用
- package分割の複雑さ

## 22. 受け入れ条件

ユーザー視点・開発者視点・QA視点で定義してください。

## 23. テスト戦略

unit test、golden layout test、MusicXML roundtrip test、CLI/TUI/MCP test、benchmark、fuzz testを含めてください。

## 24. 開発タスク分解

epic、story、task単位に分解してください。

## 25. 次に決めるべきこと

優先度順に意思決定項目を整理してください。

# 注意

- 不明点は必ず質問してください
- ただし質問だけで終わらず、仮定を置いた暫定要件も作成してください
- MVPはheadless-firstです
- TUIは必須です
- MCPはこのシステム自体がServerとして動作します
- 衝突回避は楽譜レイアウト上の衝突のみを対象とします
- percussionはドラム譜・打楽器譜とpercussion TABの両方を対象とします
- PDF / SVG / PNG exportは初期対象外です
- Rust / C++ / FFI は使用しません
- 実装はDartのみです
- Flutter UIは将来追加可能なfrontendとして設計してください
- core engineはFlutter非依存にしてください
- TUI/CLI/MCP/Flutterが同じcommand engineを使う設計にしてください
- Melos + Pub Workspacesを前提にしてください
- 楽譜編集ソフトとして実用に耐えるレベルで深く定義してください
