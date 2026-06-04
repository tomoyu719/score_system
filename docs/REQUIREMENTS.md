# フル機能楽譜編集システム 要件定義書

バージョン: 1.0.0  
作成日: 2026-06-01  
更新日: 2026-06-01  
ステータス: **確定**（全質問への回答反映済み・仮定ゼロ）

---

## 目次

1. [確認質問](#1-確認質問)
2. [仮定](#2-仮定)
3. [プロダクト概要](#3-プロダクト概要)
4. [MVP方針](#4-mvp方針)
5. [スコープ](#5-スコープ)
6. [機能要件](#6-機能要件)
7. [非機能要件](#7-非機能要件)
8. [技術アーキテクチャ](#8-技術アーキテクチャ)
9. [Monorepo / Melos設計](#9-monorepo--melos設計)
10. [データモデル](#10-データモデル)
11. [Command Engine仕様](#11-command-engine仕様)
12. [レイアウト・衝突回避仕様](#12-レイアウト衝突回避仕様)
13. [TUI仕様](#13-tui仕様)
14. [CLI / Headless仕様](#14-cli--headless仕様)
15. [MCP Server仕様](#15-mcp-server仕様)
16. [TAB / Percussion仕様](#16-tab--percussion仕様)
17. [Cross-staff / N Voice仕様](#17-cross-staff--n-voice仕様)
18. [ファイル形式・入出力](#18-ファイル形式入出力)
19. [配布方針](#19-配布方針)
20. [リスクと技術課題](#20-リスクと技術課題)
21. [受け入れ条件](#21-受け入れ条件)
22. [テスト戦略](#22-テスト戦略)
23. [開発タスク分解](#23-開発タスク分解)
24. [次に決めるべきこと](#24-次に決めるべきこと)

---

## 1. 確認質問

優先度順。未回答の場合は [仮定](#2-仮定) を適用する。

### プロダクト目的

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-01 | このシステムの最終的な位置づけは何か | 商用製品 / OSS公開 / 個人ツール / ライブラリ提供 | ライセンス・API設計・配布方針全般 |
| Q-02 | 主な収益・成功指標（KPI）は何か | DAU / エクスポート数 / GitHub star / 商用ライセンス販売 | ロードマップ優先度 |
| Q-03 | 競合ポジショニングはどこか | MuseScore / Sibelius / Finale / LilyPond / VexFlow | 機能優先度・差別化ポイント |

### 対象ユーザー

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-04 | 主要ユーザー層は誰か | 作曲家・編曲家 / DTMユーザー / ゲーム開発者 / 音楽教育者 / 開発者 | UX・CLI設計・MCP利用シナリオ |
| Q-05 | AIエージェントによる楽譜編集をメインユースケースとするか | Yes（MCP first） / No（人間first） | MCP Server設計の複雑度 |
| Q-06 | 楽譜の規模感（最大小節数・パート数）を想定しているか | 4〜8小節のスニペット / 交響曲規模（100パート・1000小節超） | パフォーマンス目標・レイアウトエンジン設計 |

### MVP範囲

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-07 | MVPのリリース目標時期はあるか | 3ヶ月 / 6ヶ月 / 1年 / 未定 | タスク分解・優先順位 |
| Q-08 | MVPで最低限「動く」ことを確認したい機能は何か | MusicXML roundtrip / TUI編集 / MCP tool call / 衝突回避 | sprint計画 |
| Q-09 | headless engine単体での動作確認（CI上でのテスト通過）をMVP完了条件とするか | Yes / No | 受け入れ条件 |

### Dart-only制約

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-10 | Dartの外部pure Dartパッケージ利用は自由か | 自由 / 最小限 / 禁止 | MusicXML parser・MIDIライブラリの選択 |
| Q-11 | dart:ffi は完全禁止か（SMuFLフォントアクセス等で必要になる場合）| 完全禁止 / 限定的OK | フォント・グリフ設計 |
| Q-12 | Web（dart2js / Wasm）でのlayout計算をMVP範囲内とするか | Yes / No | isolate設計・chunked processing |

### TUI

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-13 | TUIのターミナル制御ライブラリとして既存Dartパッケージを使うか、独自実装するか | `dart_console` 等を使用 / 独自ANSIエスケープ実装 | 実装工数・依存関係 |
| Q-14 | TUIのASCII楽譜プレビューはどの程度の精度を目指すか | 音符名テキスト一覧 / ASCII線譜 / Unicodeブロック記号による近似 | TUI実装難易度 |
| Q-15 | modal editingのモデルはVim準拠か独自か | Vim準拠（Normal/Insert/Visual/Command） / 独自 | キーバインド設計 |

### MCP Server

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-16 | 対象MCPプロトコルバージョンは何か | MCP 1.0 / 最新draft | tool定義スキーマ |
| Q-17 | MCP経由の破壊的操作（削除・上書き）に対してconfirmation handshakeを設けるか | Yes（必須） / No（呼び出し元責任） | MCP Server設計・audit log |
| Q-18 | MCP Serverのサンドボックスポリシー（ファイルシステムアクセス制限等）の範囲は | 読み取り専用モード / 指定ディレクトリのみ / 無制限 | セキュリティ設計 |

### 楽譜編集機能

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-19 | 対応するSMuFLバージョンは何か。またグリフIDをcoreモデルに持つか | SMuFL 1.4 / LayoutのみSMuFL参照 | データモデル設計 |
| Q-20 | 移調機能（transposing instrument対応）はMVP必須か | Yes / No（v1） | score_coreの設計範囲 |
| Q-21 | 拍子変更・調号変更・移調はコマンドとして実装するか（undoable） | Yes（必須） | Command Engine設計 |

### TAB

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-22 | ギターTABの最大弦数は何弦か | 6弦固定 / 4〜12弦可変 | TABモデル設計 |
| Q-23 | チューニングの定義方法は | プリセット（Standard/Drop-D等） / 完全カスタム | Tuningモデル |
| Q-24 | TABと五線譜の音高同期はリアルタイム（編集時即時）か、明示的な同期操作か | リアルタイム / 手動同期 | Command Engine設計 |

### Percussion

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-25 | 対応するドラムキットマッピング規格は | General MIDI / カスタムマッピングのみ / 両方 | Percussion model設計 |
| Q-26 | percussion TABのライン数は固定か可変か | 固定（例: 5ライン） / 可変（instrument数に応じる） | レイアウト設計 |

### レイアウト

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-27 | レイアウト単位（内部座標系）は何を使うか | Staff Space（sp）/ Point / 独自単位 | layout engine全体設計 |
| Q-28 | 段組（system break）の計算はMVP範囲内か | Yes / No（将来） | layout engine実装範囲 |
| Q-29 | 楽譜スペーシングアルゴリズムの参考にする標準は | Gourlay / Optimal / 独自 | layout難易度 |

### MusicXML / MIDI

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-30 | 対象MusicXMLバージョンは | 3.1 / 4.0 / 両方 | score_io実装範囲 |
| Q-31 | MIDIはSMF Type 0 / Type 1 どちらを出力するか | Type 0のみ / Type 1のみ / 両方 | MIDI export設計 |
| Q-32 | MIDIインポートはMVP対象か | Yes / No（exportのみ） | score_io範囲 |

### Native Format

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-33 | `.score.json` のスキーマバージョニング戦略は | semver field + migration script / 後方互換のみ | native format設計 |
| Q-34 | native formatをコーディングエージェントが直接編集することを想定するか | Yes（読み書き可能JSON設計） / No | フォーマット設計優先度 |

### テスト

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-35 | コードカバレッジの目標値はあるか | 80% / 90% / 目標なし | CI設定 |
| Q-36 | layout golden testのgoldenデータ管理はGit管理か | Yes（JSON diff） / No | test infrastructure |
| Q-37 | パフォーマンスベンチマークの合格基準は | 100小節・4声で < 100ms layout / 未定 | 非機能要件の具体化 |

### 開発体制

| # | 質問 | 選択肢例 | 影響 |
|---|------|----------|------|
| Q-38 | ソロ開発かチーム開発か | ソロ / 2〜5人チーム | タスク分解・並行作業計画 |
| Q-39 | CIプラットフォームは何を使うか | GitHub Actions / GitLab CI / CircleCI | CI設定ファイル設計 |
| Q-40 | ライセンスはOSSか商用か | MIT / Apache-2.0 / Proprietary | 依存パッケージのライセンス制約 |

---

## 2. 決定事項一覧

全項目確定済み。仮定ゼロ。

| ID | 内容 | 根拠・理由 |
|----|------|-----------|
| D-01 | 個人ツールとして開発する。pub.dev公開不要。API設計より機能重視。ライセンスはMIT | Q-01 回答 |
| D-02 | 主要ユーザーは開発者自身。AIエージェントによるMCP利用は補助機能 | Q-04, Q-05 回答 |
| D-03 | MVPに期限なし。優先度・興味でタスクを進める | Q-07 回答 |
| D-04 | MVP完了条件: MusicXML roundtrip + headless layout計算 + CLI全コマンド通過 + テストスイート全green | recommended |
| D-05 | 外部pure Dartパッケージ使用可。dart:ffiは禁止。推奨パッケージは下記参照 | Q-10, Q-11 回答 |
| D-06 | TUIは **`dart_console` ＋ カスタムANSIレンダリング**。Dartエコシステムで最も現実的な構成 | Q-13 recommended |
| D-07 | TUI楽譜プレビューは **Unicodeブロック文字による近似表示**（`─` / `●` / `○` 等）。完全グラフィクスはFlutter担当 | Q-14 recommended |
| D-08 | modal editingは **Vim準拠**（Normal / Insert / Visual / Command-line mode）。学習コスト低・操作効率高 | Q-15 recommended |
| D-09 | MCP仕様: **MCP Specification 2024-11-05**（最新安定版）、Stdio transport、JSON-RPC 2.0 | Q-16 recommended |
| D-10 | MCP経由の破壊的操作に **confirmation handshakeを設ける**。誤操作防止 | Q-17 recommended |
| D-11 | layout内部座標単位: **Staff Space（sp）**。1sp = staff lineの間隔（5線譜height = 4sp）。SMuFLの標準単位と一致 | Q-27 recommended |
| D-12 | MusicXML **3.1を主対象**。4.0はv1で随時対応 | Q-30 recommended |
| D-13 | MIDI出力: **SMF Type 1（マルチトラック）**を標準。Type 0も `--type 0` オプションで選択可能 | Q-31 recommended |
| D-14 | MIDIインポートはMVP対象外。v1で対応 | Q-32 recommended |
| D-15 | `.score.json` に `"$schema_version"` フィールドを持ち、マイグレーションスクリプトを提供 | Q-33 recommended |
| D-16 | ギターTABは **4〜12弦の可変弦数**に対応。6弦固定では将来の拡張性がなくなる | Q-22 recommended |
| D-17 | ソロ開発。タスクは直列進行前提で分解する | Q-38 回答 |
| D-18 | CIは **GitHub Actions** を使用 | Q-39 recommended |
| D-19 | コードカバレッジ目標: **80%以上**（個人ツールとして現実的。厳格な追跡より実装速度優先） | Q-35 recommended |
| D-20 | パフォーマンス目標: 個人ツール基準。50小節・4声・2パートで layout ≤ 300ms。詳細はNFR-01参照 | Q-37 recommended |
| D-21 | 段組（system break）計算はMVP対象外。レイアウトはシングルシステム（改行なし）として計算 | Q-28 recommended |
| D-22 | グリフはSMuFLのglyph nameを文字列IDとして参照。フォントレンダリングはlayout engine対象外 | Q-19 recommended |
| D-23 | 移調機能（transposing instrument）はMVP対象外。v1で対応 | Q-20 recommended |
| D-24 | **General MIDIドラムマッピングをデフォルト**とし、カスタムマッピングもサポート | Q-25 recommended |
| D-25 | Web対応はMVP対象外。v2で検討 | Q-12 recommended |
| D-26 | **GitHubリポジトリはprivate**で開始。後で公開するかは任意 | Q-01補足 recommended |
| D-27 | カスタムドラムマッピングをサポートする。GMプリセット ＋ ユーザー定義マッピングの2層構造 | Q-25 recommended |
| D-28 | Springモデル（Gourlay変形）でmeasure spacing計算。実装実績があり、Dartのみで実現可能 | Q-29 recommended |
| D-29 | レイアウトアルゴリズム参考実装: LilyPondのspacing理論（Optimal均等間隔）をベースにシンプル化 | Q-29 recommended |

### 推奨外部パッケージ一覧（A-05 補足）

| 用途 | パッケージ | 理由 |
|------|-----------|------|
| XML parse / build | `xml` (pub.dev) | Dart公式推奨。MusicXML処理に使用 |
| Terminal 制御 | `dart_console` | キー入力・ANSI色・カーソル制御 |
| UUID生成 | `uuid` | エンティティID生成 |
| Immutable collections | `fast_immutable_collections` | IList / IMap / ISet |
| JSON serialize | `json_annotation` + `json_serializable` | ボイラープレート削減 |
| CLI args | `args` | score_cli引数パース |
| テスト | `test` + `test_coverage` | 標準 |
| Property-based test | `glados` | Fuzz / property-based test |
| MCP SDK | `mcp_dart`（存在すれば）/ 独自実装 | MCP protocol実装 |

---

## 3. プロダクト概要

### 目的

「score_system」は、Dart言語のみで実装する**個人用フル機能楽譜編集システム**である。

開発者自身が実用的に使える楽譜ツールを、headless engineを中心に構築する。ターミナルからキーボードだけで楽譜を作成・編集・エクスポートし、MusicXML・MIDIで他ツールと連携できることを主目的とする。MCP Serverとして動作する機能も持つが、それは補助機能である。

### 提供価値

| ユーザー | 提供価値 |
|----------|----------|
| **開発者自身（主）** | ターミナルから楽譜を作成・編集・検証・エクスポートできる。キーボードfirst。guitar TABとstandard notationを同時に編集できる |
| Flutter開発者（将来の自分） | 将来、score_flutter packageを通じてGUI楽譜エディタを構築できる設計になっている |
| AIエージェント（補助） | MCP Server経由でtool callして楽譜を操作できる。全CLI出力がJSON |

### 対象ユーザー（ペルソナ）

**P1（主）: 開発者自身**
- ターミナル・Vim系操作に慣れている
- guitar TABとstandard notationを同時に編集したい
- MusicXMLで他ソフト（MuseScore等）と連携したい
- undo/redoが使えるキーボードdriven editorが欲しい
- ドラム譜も扱いたい

**P2（補助）: Claude等のAIエージェント**
- MCP Serverとしてscoreを操作・検証するパイプラインに組み込む
- JSON出力で楽譜状態をパース・確認できる

### 主要ユースケース

| ID | ユースケース | 優先度 |
|----|-------------|--------|
| UC-01 | CLIでMusicXMLをインポートし、バリデーションを通してMIDIにエクスポートする | P0 |
| UC-02 | TUIで楽譜を開き、音符を追加・削除・移動し、MusicXMLで保存する | P0 |
| UC-03 | guitar TABをTUI TAB editorで入力し、standard notationと同期確認する | P1 |
| UC-04 | ドラム譜をpercussion gridで編集しMIDIにエクスポートして再生確認する | P1 |
| UC-05 | cross-staff beamingを含むピアノ譜を編集し衝突を自動解決する | P1 |
| UC-06 | N voiceの楽譜をMusicXMLからインポートし各voiceを独立に編集する | P1 |
| UC-07 | AIエージェントがMCP tool callで楽譜を生成し衝突レポートを確認する | P2 |
| UC-08 | CI上でMusicXML roundtripテストとlayout golden testを実行する | P2 |

---

## 4. MVP方針

### 基本方針

**headless engine first** — GUIアプリではなく、コアロジックとCLI/TUI/MCP Serverを先に作る。

MVPの完了条件：
1. `score new` → `score import musicxml` → `score validate` → `score export midi` がCLIで動作する
2. TUIで楽譜を開き、音符を追加・削除・保存できる
3. MCP Server経由でscore queryおよびbasic edit tool callが動作する
4. headless layoutが計算でき、CollisionReportをJSON出力できる
5. 全パッケージのテストスイートがCIで通過する（warning 0 / error 0）

### MVPで必須とする機能（優先順位付き）

| 優先度 | 機能 |
|--------|------|
| P0 | 楽譜内部データモデル（Score / Part / Staff / Measure / Voice / Note / Rest / Chord） |
| P0 | Command Engine + Undo/Redo |
| P0 | Validation |
| P0 | Native project format（`.score.json`）serialize/deserialize |
| P0 | MusicXML 3.1 import/export |
| P0 | MIDI SMF export（Type 1） |
| P0 | score_cli 全コマンド（基本動作） |
| P1 | headless layout計算（measure spacing, voice layout） |
| P1 | Collision detection（基本衝突検出） |
| P1 | Collision resolution（基本自動解決） |
| P1 | Terminal TUI（modal editing, measure grid, event list） |
| P1 | MCP Server（resource/tool 基本セット） |
| P1 | N voice対応（任意数voice） |
| P1 | TAB基盤（guitar/bass TAB model） |
| P1 | percussion notation基盤 |
| P2 | percussion TAB基盤 |
| P2 | cross-staff model（内部モデルのみ、layout計算は部分対応） |
| P2 | TAB editor TUI |
| P2 | percussion grid TUI |

### MVPで初期対象外

- 完全なFlutter GUIエディタ
- PDF / SVG / PNG export
- 高度な印刷組版・段組計算
- リアルタイム共同編集（CRDT / OT）
- MIDIインポート
- MEI import/export
- 移調機能
- Web対応（Wasm / dart2js最適化）

---

## 5. スコープ

### In Scope（MVP）

- score_core: 楽譜データモデル・Command Engine・Validation・N voice・TAB model・percussion model・cross-staff model
- score_layout: measure/staff spacing・voice layout・TAB layout・percussion layout・collision detection・collision resolution・LayoutTree出力
- score_io: `.score.json`・MusicXML 3.1 import/export・MIDI SMF Type 1 export・MIDI JSON dump
- score_cli: 全CLIコマンド（`score new` / `validate` / `import` / `export` / `layout` / `collisions` / `fix-collisions` / `inspect` / `tui` / `mcp serve`）
- score_tui: modal editing / measure grid / event list / voice lane / TAB editor / percussion grid / collision report panel / validation panel / command palette
- score_mcp: score resource / part/staff/measure/voice resource / layout resource / collision report resource / validation resource / score query tools / score edit tools / layout tools / collision analysis tools / MusicXML tools / MIDI tools

### Out of Scope（現在）

- Flutter GUIエディタ（score_flutter package の骨格のみ作成）
- PDF / SVG / PNG export
- 印刷組版・page layout・system break計算
- リアルタイム共同編集・CRDT・OT
- MIDIインポート
- MEI import/export
- Guitar Pro import/export
- LilyPond export
- 移調機能
- Web最適化（Wasm / chunked processing）
- クラウド同期
- アクセシビリティ（スクリーンリーダー対応）

### Future Scope

- Flutter GUIエディタ（zoom/pan/gesture/touch/stylus）
- PDF / SVG / PNG export
- 段組・page layout
- リアルタイム共同編集
- MEI / LilyPond / Guitar Pro
- 移調機能
- Web / PWA対応
- MIDI import
- クラウド同期
- アクセシビリティ層
- pub.dev公開

---

## 6. 機能要件

### 6.1 楽譜データモデル

**FR-001**

- 概要: Score / Part / Staff / Measure / Voice / Note / Rest / Chord の階層モデル
- 詳細:
  - Score は 1 以上の Part を持つ
  - Part は 1 以上の Staff を持つ（grand staff対応）
  - Staff は Measure の配列を持つ
  - Measure は N個の Voice を持つ
  - Voice は Event（Note / Rest / Chord）の配列を持つ
  - Note は音高・音価・臨時記号・アーティキュレーション・スラー/タイ・装飾音を持つ
  - Chord は複数のNoteを同時刻に持つ
  - BeamGroup・Tuplet・Slur・Tie・Dynamic・Lyricはedge/annotation要素として管理する
- 優先度: P0
- 受け入れ条件:
  - 全エンティティがimmutable値オブジェクトとして実装されている
  - Score.fromJson / Score.toJson でserialize/deserializeできる
  - 各エンティティに一意のIDがある
- 技術課題: immutableモデルとefficient copy-on-writeの両立

**FR-002**

- 概要: Beam / Stem / Tuplet / Slur / Tie の関係モデル
- 詳細:
  - BeamGroup: voice内の連続するNote/Chordのgroupを参照
  - Tuplet: N個のeventをM拍として扱うbracket
  - Slur/Tie: 開始NoteIDと終了NoteIDのペア（cross-measure対応）
  - Stem: 各Note/Chordが持つstem方向・長さへの参照
- 優先度: P0
- 受け入れ条件:
  - BeamGroupが正しく構築・解体できる（add/remove note）
  - Cross-measure slur/tieがserializeできる
- 技術課題: Tuplet内Tuplet（nested tuplet）の表現

**FR-003**

- 概要: Articulation / Dynamic / Lyric / Fingering / Chord Symbol / Ornament
- 詳細:
  - Articulation: staccato / tenuto / accent / marcato / fermata 等
  - Dynamic: p / mp / mf / f / ff / cresc / dim 等
  - Lyric: verse番号・syllable・elision対応
  - Fingering: 指番号（0〜5）・弦番号
  - Chord Symbol: root / quality / bass / extensions
  - Ornament: trill / turn / mordent / tremolo
- 優先度: P1
- 受け入れ条件: 各annotationがNoteに付与・取得できる

### 6.2 Command Engine

**FR-010**

- 概要: Command / CommandResult / CommandEngine の実装
- 詳細: [11. Command Engine仕様](#11-command-engine仕様) 参照
- 優先度: P0
- 受け入れ条件:
  - apply / undo / redo がatomicに動作する
  - dry run modeで副作用なく検証できる
  - batch commandが一括apply/undoできる

**FR-011**

- 概要: Undo / Redo
- 詳細:
  - 無制限undo/redo（メモリ上限で上限設定可能）
  - undo stack / redo stackをCommandHistoryとして管理
  - 新コマンドapply時にredo stackをクリア
- 優先度: P0
- 受け入れ条件:
  - 100ステップのundo/redoが正確に動作する
  - undo後のstateがapply前と完全一致する

**FR-012**

- 概要: Validation
- 詳細:
  - command apply前後にvalidationを実行
  - ValidationResultはseverity（error / warning / info）付き
  - 検証項目: 拍子整合性 / 声部整合性 / 音域 / MusicXML制約 / TAB制約
- 優先度: P0
- 受け入れ条件:
  - ValidationResultがJSON serializable
  - ErrorはCommandの適用をブロックできる（strict mode）

### 6.3 MusicXML Import / Export

**FR-020**

- 概要: MusicXML 3.1 import
- 詳細:
  - partwise MusicXML をparseしてScore modelに変換
  - 対応要素: note / rest / chord / measure / part / clef / key / time / beam / tuplet / slur / tie / dynamic / lyric / articulation / ornament / direction / barline / repeat
  - 非対応要素はwarningを出してskip
- 優先度: P0
- 受け入れ条件:
  - MakeMusic公式テストスイートの主要ファイルをimportできる
  - import後にvalidationが通る
  - import → export → importでlosslessなroundtrip（対応要素のみ）

**FR-021**

- 概要: MusicXML 3.1 export
- 詳細:
  - Score modelからpartwise MusicXMLを生成
  - 出力はUTF-8 XMLテキスト
  - XMLはindent整形済み（人間可読）
- 優先度: P0
- 受け入れ条件:
  - 出力XMLがMusicXML 3.1 XSDでvalidationを通る
  - MuseScore / Finale / Sibeliusで開ける（主要ソフト3つで確認）

### 6.4 MIDI Export

**FR-030**

- 概要: MIDI SMF Type 1 export
- 詳細:
  - トラック: 1トラック/Part（またはVoice別）
  - テンポ・拍子をMeta eventとして出力
  - ノートオンオフ・velocity・program change
  - MIDI JSON dump（`score inspect --midi`）で検証可能
- 優先度: P0
- 受け入れ条件:
  - 出力MIDIファイルがDAW（GarageBand等）で開ける
  - MIDI JSON dumpが正確なevent timingを持つ

### 6.5 headless Layout

**FR-040**

- 概要: measure spacing計算
- 詳細: [12. レイアウト・衝突回避仕様](#12-レイアウト衝突回避仕様) 参照
- 優先度: P1
- 受け入れ条件: LayoutTreeがJSON serializable / deterministic（同入力→同出力）

**FR-041**

- 概要: Collision detection
- 優先度: P1
- 受け入れ条件: CollisionReportがJSON serializable / 全衝突対象を検出できる

**FR-042**

- 概要: Collision resolution
- 優先度: P1
- 受け入れ条件: 自動解決後にCollisionReportの衝突数が0になる（解決可能なケース）

### 6.6 Terminal TUI

**FR-050** 〜 **FR-065**: [13. TUI仕様](#13-tui仕様) 参照

### 6.7 CLI

**FR-070** 〜 **FR-082**: [14. CLI / Headless仕様](#14-cli--headless仕様) 参照

### 6.8 MCP Server

**FR-090** 〜 **FR-110**: [15. MCP Server仕様](#15-mcp-server仕様) 参照

### 6.9 TAB対応

**FR-120** 〜 **FR-135**: [16. TAB / Percussion仕様](#16-tab--percussion仕様) 参照

### 6.10 Percussion対応

**FR-140** 〜 **FR-155**: [16. TAB / Percussion仕様](#16-tab--percussion仕様) 参照

### 6.11 Cross-staff / N Voice

**FR-160** 〜 **FR-175**: [17. Cross-staff / N Voice仕様](#17-cross-staff--n-voice仕様) 参照

---

## 7. 非機能要件

### NFR-01: パフォーマンス

個人ツールとして「使っていてストレスを感じない」ことを基準とする。交響曲規模の最適化より、通常の楽曲（4〜8パート、100小節前後）での快適さを優先する。

| 指標 | 目標値 | 根拠 |
|------|--------|------|
| layout計算（50小節・4声・2パート） | ≤ 300ms | TUI操作の体感遅延なし |
| layout計算（10小節・4声・1パート） | ≤ 30ms | キー入力後の即時フィードバック |
| MusicXML import（200小節） | ≤ 1000ms | CLIでファイルを開く際の待機時間 |
| MIDI export（200小節） | ≤ 300ms | エクスポート操作の待機時間 |
| Collision detection（200要素） | ≤ 100ms | 衝突確認のレスポンス |
| command apply（single command） | ≤ 20ms | TUI操作時のUndo/Redo応答 |

大規模スコア最適化（交響曲規模）はv2で検討。MVPではシンプルな実装を優先する。

### NFR-02: Deterministic Layout

- 同一入力（Score model）に対して常に同一のLayoutTreeを出力する
- フォント依存・プラットフォーム依存の値を含めない
- layout golden testで回帰を自動検出する

### NFR-03: Reproducible Export

- 同一Score modelから同一MusicXML / MIDIバイナリを生成する
- タイムスタンプ等の非決定的な値をファイルに含めない（オプションとして生成日時フィールドを追加可能だが、デフォルトはoff）

### NFR-04: Reliability

- ValidationはすべてのCommandに対して必ず実行される
- Commandが失敗した場合にScoreは元の状態に戻る（atomicity保証）
- native project formatは常にバリデーションを通るデータのみを保存する

### NFR-05: Offline Support

- ネットワーク接続なしで全機能が動作する（MCP Server自体はlocalで動作）
- 外部API依存なし

### NFR-06: Testability

- すべてのpublic APIにユニットテストを書く（TDD: Red → Green → Refactor）
- コードカバレッジ目標: **80%以上**（個人ツールとして現実的な値。厳格なカバレッジ追跡より実装速度を優先）
- score_coreはpure Dartであるため、Flutterなしでテスト可能
- layout golden testはLayoutTree JSONとして比較（画像不要）
- TUI testはANSIエスケープ除去済みテキストスナップショット

### NFR-07: Maintainability

- 1ファイル1public class
- if nestは1段まで（早期リターン必須）
- strict linter（warning 0 / error 0）をCIで強制
- すべてのpublic APIにドキュメントコメント（/// 形式）
- package境界をCI上で自動チェック

### NFR-08: Security（MCP Server）

- MCP経由の破壊的操作にはconfirmation handshakeを設ける
- ファイルアクセスは指定ディレクトリ内に制限するsandbox policyを設ける
- コマンドインジェクション・パストラバーサルを防ぐ
- audit logを記録する（操作・タイムスタンプ・結果）

### NFR-09: Portability

- macOS / Windows / Linux でコードを変更せずに動作する
- platform固有のAPIはplatform abstraction layerで隔離する
- `dart:io` の直接使用はscore_cli / score_tui / score_mcpに限定する

### NFR-10: Extensibility

- 新しいファイル形式のimporter/exporterをscore_ioに追加できる
- 新しいTUIパネルをscore_tuiに追加できる
- 新しいMCP toolをscore_mcpに追加できる
- Flutter GUIを将来score_flutterとして追加できる（score_core / score_layoutはFlutter非依存）

### NFR-11: 個人ツールとしてのシンプルさ優先

- API設計の汎用性より、自分が使いやすいUXを優先する
- 過度な抽象化・汎用化は避ける（YAGNI原則）
- pub.dev公開を考慮したAPI安定性は不要
- ドキュメント整備より実装を優先してよい（ただしコードは読みやすく）

### NFR-11: Memory Usage

- 1000小節・4声の楽譜で常駐メモリ ≤ 500MB（目標）
- layout cacheを実装し、変更のない部分を再計算しない

### NFR-12: Package Boundary Enforcement

- `score_core` が Flutter / dart:ui / terminal / MCP / CLI に依存しないことをCIで検証する
- `score_layout` が Flutter に依存しないことをCIで検証する
- 依存方向の逆流をCIでエラーとする

---

## 8. 技術アーキテクチャ

### 8.1 Package構成

```
score_system/                    # workspace root
  pubspec.yaml                   # workspace定義
  analysis_options.yaml          # 共有linter設定
  melos.yaml                     # Melos設定
  packages/
    score_core/                  # 楽譜意味構造・編集操作（pure Dart）
    score_layout/                # レイアウト計算・衝突回避
    score_io/                    # ファイル形式変換
    score_cli/                   # CLI entry point
    score_tui/                   # Terminal UI
    score_mcp/                   # MCP Server
    score_flutter/               # Flutter UI（骨格のみ、将来）
  apps/
    score_flutter_app/           # Flutter アプリ（将来）
  tools/                         # 開発ツール・script
  bin/
    score.dart                   # CLI entry point
```

### 8.2 依存関係

```
score_core
  └── external pure Dart packages のみ

score_layout
  └── score_core

score_io
  └── score_core

score_cli
  ├── score_core
  ├── score_layout
  └── score_io

score_tui
  ├── score_core
  ├── score_layout
  └── score_io

score_mcp
  ├── score_core
  ├── score_layout
  └── score_io

score_flutter（将来）
  ├── score_core
  └── score_layout

apps/score_flutter_app（将来）
  ├── score_flutter
  ├── score_core
  ├── score_layout
  └── score_io
```

### 8.3 score_core 内部構造

```
score_core/lib/
  src/
    model/
      score.dart
      part.dart
      staff.dart
      measure.dart
      voice.dart
      note.dart
      rest.dart
      chord.dart
      pitch.dart
      duration.dart
      beam_group.dart
      tuplet.dart
      slur.dart
      tie.dart
      dynamic.dart
      lyric.dart
      articulation.dart
      ornament.dart
      fingering.dart
      chord_symbol.dart
      clef.dart
      key_signature.dart
      time_signature.dart
      barline.dart
      rehearsal_mark.dart
      tempo.dart
      tab/
        tab_note.dart
        tab_staff.dart
        tuning.dart
        guitar_technique.dart
      percussion/
        percussion_note.dart
        percussion_staff.dart
        drum_mapping.dart
      cross_staff/
        cross_staff_beam.dart
        cross_staff_stem.dart
      voice_model/
        voice_config.dart
        voice_priority.dart
    command/
      command.dart
      command_result.dart
      command_engine.dart
      command_history.dart
      add_note_command.dart
      remove_note_command.dart
      move_note_command.dart
      add_measure_command.dart
      remove_measure_command.dart
      add_part_command.dart
      batch_command.dart
      # ... 他コマンド
    validation/
      validator.dart
      validation_result.dart
      validation_rule.dart
      # ... ルール実装
    query/
      score_query.dart
      note_query.dart
      measure_query.dart
    selection/
      selection.dart
      selection_range.dart
```

### 8.4 データフロー

```
[Input: TUI / CLI / MCP / Flutter]
         |
         v
    Command (immutable)
         |
         v
    CommandEngine.apply(command, score)
         |
         +-- Validation.validate(newScore)
         |        |
         |        +-- ValidationResult.error → reject, return original score
         |        |
         |        +-- ValidationResult.ok → proceed
         |
         v
    Updated Score (immutable)
         |
         +---> score_layout.calculateIncremental(score)
         |           |
         |           v
         |       LayoutTree / CollisionReport
         |
         +---> score_io.exportMusicXml(score)
         |           |
         |           v
         |       MusicXML string
         |
         +---> score_io.exportMidi(score)
                     |
                     v
                 MIDI bytes
```

---

## 9. Monorepo / Melos設計

### 9.1 pubspec.yaml（workspace root）

```yaml
name: score_system
publish_to: none

environment:
  sdk: ">=3.5.0 <4.0.0"

workspace:
  - packages/score_core
  - packages/score_layout
  - packages/score_io
  - packages/score_cli
  - packages/score_tui
  - packages/score_mcp
  - packages/score_flutter
  - apps/score_flutter_app
```

### 9.2 melos.yaml

```yaml
name: score_system

packages:
  - packages/**
  - apps/**

command:
  version:
    workspaceChangelog: true

scripts:
  analyze:
    run: dart analyze --fatal-infos --fatal-warnings
    exec:
      concurrency: 4
    description: "Analyze all packages (strict mode, 0 warnings)"

  test:
    run: dart test
    exec:
      concurrency: 2
    description: "Run all tests"

  test_core:
    run: dart test
    packageFilters:
      scope: score_core

  test_layout:
    run: dart test
    packageFilters:
      scope: score_layout

  test_io:
    run: dart test
    packageFilters:
      scope: score_io

  test_cli:
    run: dart test
    packageFilters:
      scope: score_cli

  test_tui:
    run: dart test
    packageFilters:
      scope: score_tui

  test_mcp:
    run: dart test
    packageFilters:
      scope: score_mcp

  test_layout_golden:
    run: dart test --name "golden"
    packageFilters:
      scope: score_layout

  format:
    run: dart format --set-exit-if-changed .
    exec:
      concurrency: 4

  check:
    run: melos run format && melos run analyze && melos run test

  build_cli:
    run: dart compile exe bin/score.dart -o build/score
    description: "Compile CLI to native executable"

  deps_check:
    run: dart run tools/dep_checker.dart
    description: "Check package dependency boundaries"

  benchmark:
    run: dart run benchmark/layout_benchmark.dart
    packageFilters:
      scope: score_layout
```

### 9.3 analysis_options.yaml（workspace root / 各packageが include する）

```yaml
include: package:lints/recommended.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
    implicit_dynamic_type: error

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
    - always_use_package_imports
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_final_locals
```

### 9.4 CI設計（GitHub Actions）

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: dart-lang/setup-dart@v1
      - run: dart pub get
      - run: melos run analyze

  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: dart-lang/setup-dart@v1
      - run: dart pub get
      - run: melos run test

  golden:
    runs-on: ubuntu-latest
    steps:
      - uses: dart-lang/setup-dart@v1
      - run: melos run test_layout_golden

  deps_check:
    runs-on: ubuntu-latest
    steps:
      - run: melos run deps_check

  build_cli:
    runs-on: ubuntu-latest
    steps:
      - run: melos run build_cli
```

### 9.5 Package Dependency Boundary Check

`tools/dep_checker.dart` を実装し、以下を自動チェックする：

- `score_core` の pubspec.yaml の dependencies に `flutter` / `score_layout` / `score_io` / `score_cli` / `score_tui` / `score_mcp` が含まれないこと
- `score_layout` の dependencies に `flutter` が含まれないこと
- 依存の逆流がないこと（DAG検証）

---

## 10. データモデル

### 10.1 主要エンティティ（Dart風擬似コード）

```dart
// --- Immutable value objects ---

final class Score {
  final ScoreId id;
  final ScoreMetadata metadata;
  final IList<Part> parts;
  final IList<MeasureHeader> measureHeaders; // 全パート共通の小節情報
}

final class ScoreMetadata {
  final String title;
  final String composer;
  final String? lyricist;
  final String? copyright;
  final int schemaVersion; // native format migration用
}

final class MeasureHeader {
  final int measureNumber;          // 1-indexed
  final TimeSignature timeSignature;
  final KeySignature keySignature;
  final Tempo? tempo;
  final RehearsalMark? rehearsalMark;
  final BarlineType startBarline;
  final BarlineType endBarline;
}

final class Part {
  final PartId id;
  final String name;
  final String abbreviation;
  final IList<Staff> staves;
  final MidiInstrument midiInstrument;
  final PartType partType; // standard | tab | percussion | percussionTab
}

final class Staff {
  final StaffId id;
  final Clef clef;
  final StaffType staffType; // standard | tab | percussion | percussionTab
  final int lineCount;      // 通常5、TABは弦数
  final TabConfig? tabConfig;
  final PercussionConfig? percussionConfig;
  final IMap<int, Measure> measures; // key: measureNumber
}

final class Measure {
  final MeasureId id;
  final int measureNumber;
  final IMap<VoiceId, Voice> voices;
}

final class Voice {
  final VoiceId id;
  final int voiceNumber;
  final StemDirection stemDirectionPolicy;
  final bool isHidden;
  final IList<MusicEvent> events;
}

sealed class MusicEvent {
  final EventId id;
  final Fraction offset;   // 小節内オフセット（拍）
  final Fraction duration; // 音価
}

final class NoteEvent extends MusicEvent {
  final Pitch pitch;
  final Accidental? accidental;
  final NoteHead noteHead;
  final IList<Articulation> articulations;
  final IList<Lyric> lyrics;
  final Fingering? fingering;
  final TieId? tieStart;
  final TieId? tieEnd;
  final SlurId? slurStart;
  final SlurId? slurEnd;
  final bool isGrace;
  final TabFret? tabFret; // TABの場合
}

final class RestEvent extends MusicEvent {
  final bool isFullMeasureRest;
  final int? displayPosition; // staff line上の表示位置
}

final class ChordEvent extends MusicEvent {
  final IList<NoteEvent> notes;
  final ChordSymbol? chordSymbol;
}

final class Pitch {
  final NoteName step;    // C D E F G A B
  final int octave;       // 0-9
  final int alter;        // -2 -1 0 1 2（半音単位）
}

final class Duration {
  final NoteType type;    // whole | half | quarter | eighth | ...
  final int dots;
  final Fraction? tupletFactor;
}

final class Fraction {
  final int numerator;
  final int denominator;
}

// --- TAB ---

final class TabConfig {
  final int stringCount;
  final IList<Pitch> tuning; // 低弦から高弦
  final int capo;
}

final class TabFret {
  final int stringNumber; // 1-indexed、1=最低弦
  final int fretNumber;   // 0=開放弦
  final IList<GuitarTechnique> techniques;
}

enum GuitarTechnique {
  hammerOn, pullOff, slide, bend, release,
  vibrato, palmMute, harmonic, tapping,
  deadNote, ghostNote,
}

// --- Percussion ---

final class PercussionConfig {
  final DrumMapping drumMapping;
}

final class DrumMapping {
  final IMap<int, DrumInstrument> midiNoteToInstrument;
}

final class DrumInstrument {
  final String name;
  final int staffLine;
  final NoteHeadType noteHeadType;
  final int midiNote;
}

// --- Cross-staff ---

final class CrossStaffRef {
  final NoteId noteId;
  final StaffId displayStaff; // 表示上のstaff（論理voiceとは異なる）
  final StaffId logicalStaff; // 音高の帰属先staff
}

// --- Beam / Slur / Tie ---

final class BeamGroup {
  final BeamGroupId id;
  final IList<EventId> eventIds;
  final IList<CrossStaffRef> crossStaffRefs;
}

final class Slur {
  final SlurId id;
  final NoteId startNote;
  final NoteId endNote;
  final SlurPlacement placement;
}

final class Tie {
  final TieId id;
  final NoteId startNote;
  final NoteId endNote;
}

// --- N Voice ---

final class VoiceConfig {
  final VoiceId id;
  final int priority;             // 数値が小さいほど優先
  final StemDirection stemPolicy;
  final RestPositioningPolicy restPolicy;
  final bool isPlayback;
  final bool isLayout;
  final bool isEditing;
}
```

### 10.2 ID設計

すべてのエンティティIDはラッパークラスとする：

```dart
extension type ScoreId(String value) {}
extension type PartId(String value) {}
extension type StaffId(String value) {}
extension type MeasureId(String value) {}
extension type VoiceId(String value) {}
extension type EventId(String value) {}
extension type NoteId(String value) {}
extension type BeamGroupId(String value) {}
extension type SlurId(String value) {}
extension type TieId(String value) {}
```

IDはUUID v4を使用する。

### 10.3 Native Format（`.score.json`）

```json
{
  "$schema_version": 1,
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "metadata": {
    "title": "Example Score",
    "composer": "J.S. Bach",
    "lyricist": null,
    "copyright": null
  },
  "measureHeaders": [
    {
      "measureNumber": 1,
      "timeSignature": { "beats": 4, "beatType": 4 },
      "keySignature": { "fifths": 0, "mode": "major" },
      "tempo": { "bpm": 120, "beatUnit": 4 },
      "startBarline": "regular",
      "endBarline": "regular"
    }
  ],
  "parts": [
    {
      "id": "part-1",
      "name": "Violin",
      "abbreviation": "Vln.",
      "partType": "standard",
      "midiInstrument": { "program": 40, "channel": 1 },
      "staves": [
        {
          "id": "staff-1",
          "clef": { "sign": "G", "line": 2 },
          "staffType": "standard",
          "lineCount": 5,
          "measures": {
            "1": {
              "id": "measure-1-staff-1",
              "measureNumber": 1,
              "voices": {
                "voice-1": {
                  "id": "voice-1",
                  "voiceNumber": 1,
                  "stemDirectionPolicy": "auto",
                  "isHidden": false,
                  "events": [
                    {
                      "type": "note",
                      "id": "note-001",
                      "offset": "0/1",
                      "duration": "1/4",
                      "pitch": { "step": "C", "octave": 4, "alter": 0 },
                      "noteHead": "normal",
                      "articulations": [],
                      "lyrics": []
                    }
                  ]
                }
              }
            }
          }
        }
      ]
    }
  ],
  "beamGroups": [],
  "slurs": [],
  "ties": []
}
```

---

## 11. Command Engine仕様

### 11.1 Command定義

```dart
sealed class Command {
  const Command();
}

// 基本コマンド例
final class AddNoteCommand extends Command {
  final StaffId staffId;
  final int measureNumber;
  final VoiceId voiceId;
  final Fraction offset;
  final Pitch pitch;
  final Duration duration;
  const AddNoteCommand({...});
}

final class RemoveNoteCommand extends Command {
  final NoteId noteId;
  const RemoveNoteCommand({required this.noteId});
}

final class MoveNoteCommand extends Command {
  final NoteId noteId;
  final Pitch? newPitch;
  final Fraction? newOffset;
  final VoiceId? newVoice;
}

final class BatchCommand extends Command {
  final IList<Command> commands;
  final String description;
}

final class SetTimeSignatureCommand extends Command {
  final int measureNumber;
  final TimeSignature timeSignature;
}

final class SetTempoCommand extends Command {
  final int measureNumber;
  final Tempo tempo;
}
```

### 11.2 CommandResult

```dart
sealed class CommandResult {}

final class CommandSuccess extends CommandResult {
  final Score newScore;
  final IList<ValidationWarning> warnings;
  final CommandId commandId;
}

final class CommandFailure extends CommandResult {
  final String message;
  final IList<ValidationError> errors;
  final Score originalScore; // 変更なし
}
```

### 11.3 CommandEngine

```dart
final class CommandEngine {
  CommandResult apply(Command command, Score score);
  CommandResult undo(Score score);
  CommandResult redo(Score score);

  // Dry run: 副作用なしに検証のみ
  CommandResult dryRun(Command command, Score score);

  // Batch: 複数コマンドをatomicに適用
  CommandResult applyBatch(IList<Command> commands, Score score);

  CommandHistory get history;
}
```

### 11.4 Undo / Redo

```dart
final class CommandHistory {
  final IList<CommandRecord> undoStack;
  final IList<CommandRecord> redoStack;
  final int maxDepth; // デフォルト: 1000

  bool get canUndo;
  bool get canRedo;
}

final class CommandRecord {
  final CommandId id;
  final Command command;
  final Score scoreBefore;
  final Score scoreAfter;
  final DateTime appliedAt;
}
```

Undo戦略: **完全スナップショット方式**（MVPとして実装シンプル化。将来必要に応じてdiff方式に移行）

### 11.5 Validation

```dart
final class Validator {
  ValidationResult validate(Score score);
  ValidationResult validateCommand(Command command, Score score);
}

final class ValidationResult {
  final IList<ValidationError> errors;
  final IList<ValidationWarning> warnings;
  final IList<ValidationInfo> infos;

  bool get isValid => errors.isEmpty;

  Map<String, Object?> toJson();
}
```

### 11.6 Error Handling

- Commandが失敗した場合はCommandFailureを返す（例外throwしない）
- 内部エラー（バグ）はScoreException（checked exception相当）
- ValidationErrorはCommandをblockする
- ValidationWarningはCommandを通過させるが警告を返す

### 11.7 Atomic Operation保証

- CommandEngine.apply()はatomic: 成功またはoriginal scoreを返す
- 部分適用状態（中途半端なScore）は外部に漏れない
- BatchCommandはall-or-nothing: いずれかのcommandが失敗した場合すべてを巻き戻す

### 11.8 Dry Run

```dart
// dry run: score を変更せず、ValidationResultとprospective newScoreを返す
final result = engine.dryRun(addNoteCommand, currentScore);
if (result is CommandSuccess) {
  // ユーザーに事前確認させる
}
```

### 11.9 Audit Log

```dart
final class AuditLog {
  final IList<AuditEntry> entries;

  void record(Command command, CommandResult result, String? source);
  Map<String, Object?> toJson();
}

final class AuditEntry {
  final String commandType;
  final String? source;       // "cli" | "tui" | "mcp" | "flutter"
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;
}
```

---

## 12. レイアウト・衝突回避仕様

### 12.1 内部座標系

- 単位: **Staff Space（sp）**。1sp = staff lineの間隔（5線譜の場合、staff height = 4sp）
- X軸: 時間軸（左→右）
- Y軸: 音高軸（下→上、正値=上方向）
- 原点: 各staff左端・下線

### 12.2 LayoutTree

```dart
final class LayoutTree {
  final IList<SystemLayout> systems;

  Map<String, Object?> toJson();
}

final class SystemLayout {
  final double x;
  final double y;
  final double width;
  final IList<StaffLayout> staves;
  final IList<MeasureLayout> measures;
}

final class MeasureLayout {
  final int measureNumber;
  final double x;
  final double width;
  final IList<VoiceLayout> voices;
}

final class VoiceLayout {
  final VoiceId voiceId;
  final IList<NoteLayout> notes;
  final IList<RestLayout> rests;
  final IList<BeamLayout> beams;
  final IList<StemLayout> stems;
}

final class NoteLayout {
  final NoteId noteId;
  final double x;
  final double y;
  final BoundingBox boundingBox;
  final String smuflGlyphName;
  final IList<AccidentalLayout> accidentals;
  final IList<ArticulationLayout> articulations;
}
```

### 12.3 BoundingBox

```dart
final class BoundingBox {
  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;

  bool intersects(BoundingBox other);
  BoundingBox inflate(double margin);
}
```

### 12.4 Measure Spacing

アルゴリズム: **Springモデル（Gourlay変形）**

1. 各eventのnatural width（音価に比例）を計算
2. 最短duration音符にmin_widthを割り当て
3. 各小節のcontentWidthを計算
4. システム幅に合わせてjustify（均等伸長）
5. page非依存のシングルシステムとして計算（MVP）

### 12.5 Voice Layout

- Stem directionはvoicePolicyに基づく（上声部=up / 下声部=down / auto）
- 同時刻のNote間のX offsetを計算（notehead collision回避）
- Rest positioningはvoice数・stem directionから自動決定

### 12.6 Collision Detection

検出対象と検出方法:

| 要素 | 検出方法 |
|------|----------|
| notehead | BoundingBox intersection |
| stem | line segment intersection |
| beam | line segment intersection |
| accidental | BoundingBox intersection |
| articulation | BoundingBox intersection |
| dynamic | BoundingBox intersection |
| lyric | BoundingBox intersection（text幅考慮） |
| chord symbol | BoundingBox intersection |
| slur / tie | bezier curve approximation（BBox） |
| fingering | BoundingBox intersection |
| TAB fret number | BoundingBox intersection |
| percussion glyph | BoundingBox intersection |
| cross-staff beam | multi-staff BoundingBox |

```dart
final class CollisionReport {
  final IList<Collision> collisions;
  final int totalCount;

  Map<String, Object?> toJson();
}

final class Collision {
  final CollisionId id;
  final CollisionSeverity severity; // error | warning | info
  final LayoutElementRef elementA;
  final LayoutElementRef elementB;
  final BoundingBox intersection;
  final String description;
  final IList<CollisionFix> suggestedFixes;
}

enum CollisionSeverity { error, warning, info }
```

### 12.7 Collision Resolution

優先度モデル:

| 優先度 | 要素 | 移動制約 |
|--------|------|----------|
| 1（最高・不動）| staff line / barline / notehead（音高固定） | 移動不可 |
| 2 | stem / beam | Y方向のみ伸長可 |
| 3 | accidental | X方向のみ移動 |
| 4 | articulation | Y方向移動（上下） |
| 5 | dynamic / tempo text | Y方向移動 |
| 6 | lyric | Y方向移動（下方向） |
| 7 | fingering / chord symbol | Y/X両方向移動 |
| 8（最低）| rehearsal mark | Y方向移動 |

解決アルゴリズム:

1. 衝突リストを severity 降順でソート
2. 高優先度要素を固定、低優先度要素を移動対象とする
3. 移動方向を制約に従って決定
4. 最小移動量で衝突が解消するまでiterateする（最大10回）
5. 10回で解消しない場合はwarningとして残す

```dart
final class CollisionResolver {
  // 自動解決を試みてnewLayoutTreeを返す
  ResolvedLayout resolve(LayoutTree tree, CollisionReport report);
}

final class ResolvedLayout {
  final LayoutTree layoutTree;
  final CollisionReport remainingCollisions; // 解決できなかった衝突
  final IList<AppliedFix> appliedFixes;
}
```

### 12.8 User Override

- ユーザーが手動で要素位置を調整した場合、その要素に `isManualOverride: true` フラグを立てる
- 自動解決は `isManualOverride: true` の要素を移動しない
- `score fix-collisions --reset-overrides` でoverrideをクリアできる

### 12.9 Incremental Layout

- 変更されたMeasureとその隣接Measureのみ再計算する
- LayoutCacheにMeasureLayoutをキャッシュする
- CommandApply後にchangedMeasureSetを計算して差分更新する

### 12.10 Layout Regression Test

- LayoutTree全体をJSON serializeしてgoldenファイルと比較
- `test/golden/layout/` にgolden JSON を配置
- `melos run test_layout_golden` で比較実行
- goldenが変更された場合は `--update-goldens` フラグで更新

---

## 13. TUI仕様

### 13.1 画面構成

```
┌─────────────────────────────────────────────────────────┐
│ [score_system] example.score.json  [NORMAL]  m:4 v:2    │ ← Status bar
├──────────┬──────────────────────────────────────────────┤
│ Score    │                                              │
│ Tree     │         Measure Grid / Event List            │
│ Panel    │         (メインパネル、切り替え可)            │
│          │                                              │
│ Part 1   │ M1       M2       M3       M4                │
│  Staff 1 │ [C4 E4] [G4    ] [A4 G4] [F4    ]           │
│  Staff 2 │ [C3    ] [G3   ] [E3    ] [C3    ]          │
│          │                                              │
├──────────┴──────────────────────────────────────────────┤
│ Collision Report / Validation Panel（下部パネル）        │
├─────────────────────────────────────────────────────────┤
│ : (command palette)                                     │ ← Command line
└─────────────────────────────────────────────────────────┘
```

### 13.2 パネル構成

| パネル | キー | 説明 |
|--------|------|------|
| Score Tree | `<leader>t` | パート・スタッフ・ボイスのツリー |
| Measure Grid | `<leader>m` | 小節グリッド（デフォルト） |
| Event List | `<leader>e` | 時系列イベントリスト |
| Voice Lane | `<leader>l` | 声部レーン表示 |
| TAB Editor | `<leader>b` | TAB編集ビュー |
| Percussion Grid | `<leader>p` | パーカッショングリッド |
| Collision Report | `<leader>c` | 衝突レポート |
| Validation | `<leader>v` | バリデーション結果 |

### 13.3 Editing Mode

| モード | 説明 | 入口 |
|--------|------|------|
| NORMAL | カーソル移動・コマンド入力 | `Esc` |
| INSERT | 音符入力モード | `i` |
| VISUAL | 範囲選択 | `v` |
| COMMAND | コマンドパレット | `:` |
| SEARCH | 検索 | `/` |

### 13.4 主要キーバインド（NORMAL mode）

| キー | 動作 |
|------|------|
| `h / j / k / l` | 左/下/上/右移動 |
| `w / b` | 次/前の音符へ |
| `gg / G` | 最初/最後の小節へ |
| `:[n]` | 小節nへジャンプ |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `dd` | 選択要素を削除 |
| `yy / p` | コピー/ペースト |
| `?` | ヘルプ |
| `q` | 終了（確認あり） |

### 13.5 INSERT mode（音符入力）

| キー | 動作 |
|------|------|
| `a-g` | 音名入力（C=c, D=d, ... B=b） |
| `0-9` | オクターブ指定 |
| `1-7` | 音価（1=全音符, 2=2分, 4=4分...） |
| `.` | 付点 |
| `#` | シャープ |
| `&` | フラット |
| `r` | 休符挿入 |
| `Esc` | NORMAL modeへ |

### 13.6 ASCII / Unicode Preview

- TUI楽譜プレビュー: Unicodeブロック文字で近似
- 五線: `─` (U+2500)
- 音符ヘッド: `♩` / `●` / `○`
- 音部記号: テキスト（`G:`, `F:`）
- 実用的な精度を優先し、完全な楽譜グラフィクスは Flutter renderer担当

### 13.7 Command Palette

`:` 押下でコマンドパレット起動。ファジー検索で補完。

```
: add part violin
: export musicxml output.xml
: fix collisions
: jump 42         (小節42へ)
: set tempo 132
: filter voice 1
```

---

## 14. CLI / Headless仕様

### 14.1 CLIコマンド一覧

```bash
# 新規プロジェクト作成
score new [--title "Title"] [--composer "Name"] [--output file.score.json]

# バリデーション
score validate <file.score.json> [--format json|pretty]

# MusicXML import
score import musicxml <input.xml> -o <output.score.json>

# MusicXML export
score export musicxml <input.score.json> -o <output.xml>

# MIDI export
score export midi <input.score.json> -o <output.mid> [--type 0|1]

# レイアウト計算
score layout <input.score.json> [--format json|pretty]

# 衝突レポート
score collisions <input.score.json> [--format json|pretty]

# 衝突自動解決
score fix-collisions <input.score.json> -o <output.score.json> [--reset-overrides]

# スコア検査
score inspect <input.score.json> [--format json|pretty]
score inspect --midi <input.mid>         # MIDIイベントJSONダンプ

# diff
score diff <before.score.json> <after.score.json> [--format json|pretty]

# TUI起動
score tui [<file.score.json>]

# MCP Server起動
score mcp serve [--port 8080] [--sandbox <dir>]
```

### 14.2 出力形式

```bash
# デフォルト: JSON（CI・コーディングエージェント向け）
score validate example.score.json
# → {"valid": true, "errors": [], "warnings": []}

# --format pretty: ヒューマンリーダブル
score validate example.score.json --format pretty
# → ✓ Valid (0 errors, 2 warnings)
#   ⚠ Measure 3: quarter note exceeds time signature

# エラー出力は常にstdherrにJSON形式
# → {"error": "File not found: example.score.json"}
```

### 14.3 終了コード

| コード | 意味 |
|--------|------|
| 0 | 成功 |
| 1 | エラー（ファイル未発見・parse失敗等） |
| 2 | Validation failure |
| 3 | Layout collision未解決 |

### 14.4 headless CI利用例

```bash
# MusicXML roundtripテスト
score import musicxml input.xml -o roundtrip.score.json
score export musicxml roundtrip.score.json -o roundtrip.xml
diff <(xmllint --c14n input.xml) <(xmllint --c14n roundtrip.xml)

# layoutとcollisionレポートをJSONとして保存
score layout score.score.json > layout.json
score collisions score.score.json > collisions.json

# バリデーション結果をCIで確認
RESULT=$(score validate score.score.json)
if echo "$RESULT" | jq -e '.valid == false' > /dev/null; then
  echo "Validation failed"
  exit 2
fi
```

---

## 15. MCP Server仕様

> **位置づけ**: MCP Serverは補助機能。AIエージェントとの連携を試したいときに使う。CLI・TUIが主な操作インターフェースであり、MCP Server実装の完成度はCLI・TUIより後回しにしてよい。

### 15.1 起動

```bash
score mcp serve [--sandbox <directory>] [--log audit.log]
```

MCP Serverはstdio transportを使用（MCP Specification 2024-11-05準拠、JSON-RPC 2.0）。HTTP SSEモードはv2で検討。

### 15.2 Resources

| Resource URI | 説明 |
|-------------|------|
| `score://current` | 現在開いているスコア全体 |
| `score://parts` | パート一覧 |
| `score://parts/{partId}` | 特定パート |
| `score://parts/{partId}/staves/{staffId}` | 特定スタッフ |
| `score://measures/{measureNumber}` | 特定小節（全パート） |
| `score://voices/{voiceId}` | 特定ボイス |
| `score://layout` | 最新LayoutTree |
| `score://collisions` | 最新CollisionReport |
| `score://validation` | 最新ValidationResult |
| `score://history` | CommandHistory（AuditLog） |

### 15.3 Tools

#### Score Query Tools

```typescript
// スコア情報取得
get_score_info() → ScoreMetadata
list_parts() → Part[]
list_measures(partId?: string, from?: number, to?: number) → MeasureHeader[]
get_measure(measureNumber: number, partId?: string) → Measure
list_notes(filter: NoteFilter) → NoteEvent[]
```

#### Score Edit Tools

```typescript
// 音符操作（確認不要）
add_note(params: AddNoteParams) → CommandResult
remove_note(noteId: string) → CommandResult
move_note(noteId: string, params: MoveParams) → CommandResult
add_rest(params: AddRestParams) → CommandResult

// 構造操作（確認あり）
add_measure(params: AddMeasureParams) → CommandResult  // confirmation required
remove_measure(measureNumber: number) → CommandResult  // confirmation required
add_part(params: AddPartParams) → CommandResult        // confirmation required
remove_part(partId: string) → CommandResult            // confirmation required

// Undo / Redo
undo() → CommandResult
redo() → CommandResult

// Batch
apply_batch(commands: Command[]) → CommandResult
```

#### Layout & Collision Tools

```typescript
calculate_layout() → LayoutTree
get_collisions() → CollisionReport
fix_collisions(strategy?: 'auto' | 'manual') → ResolvedLayout
get_collision_fixes(collisionId: string) → CollisionFix[]
```

#### Import / Export Tools

```typescript
import_musicxml(xml: string) → CommandResult
export_musicxml() → string
export_midi() → string  // base64 encoded binary
save_project(path?: string) → void
```

### 15.4 Prompts

```typescript
// AI楽譜編集支援
suggest_harmony(measureRange: MeasureRange) → HarmonySuggestion[]
suggest_voicing(chord: ChordSymbol) → VoicingOption[]
analyze_score() → ScoreAnalysis
```

### 15.5 権限モデル

| 操作分類 | 権限 | Confirmation |
|----------|------|--------------|
| 読み取り（query） | 常に許可 | 不要 |
| 音符追加・編集 | 許可（sandbox内） | 不要 |
| パート追加・削除 | 許可（sandbox内） | 必要 |
| 小節追加・削除 | 許可（sandbox内） | 必要 |
| ファイル上書き保存 | 許可（sandbox内） | 必要 |
| ファイルシステムアクセス（sandbox外） | 禁止 | 不可 |

### 15.6 Audit Log

MCP Server起動時から全tool callをaudit logに記録する：

```json
{"timestamp": "2026-06-01T10:00:00Z", "tool": "add_note", "source": "mcp", "success": true}
{"timestamp": "2026-06-01T10:00:01Z", "tool": "remove_part", "source": "mcp", "success": false, "reason": "confirmation_required"}
```

---

## 16. TAB / Percussion仕様

### 16.1 Guitar / Bass TAB

#### TABモデル

```dart
final class TabConfig {
  final int stringCount;        // 4〜12
  final IList<Pitch> tuning;   // stringCount分、低弦から
  final int capo;               // 0 = capoなし
}

// プリセットチューニング
const standardGuitar = TabConfig(
  stringCount: 6,
  tuning: [E2, A2, D3, G3, B3, E4],
  capo: 0,
);

const standardBass = TabConfig(
  stringCount: 4,
  tuning: [E1, A1, D2, G2],
  capo: 0,
);
```

#### TABと五線譜の同期

- TABのfret入力 → Pitchを自動計算 → NoteEventに反映
- 五線譜のPitch入力 → デフォルト弦・fretを計算（最も低弦・最も低fretを優先）
- 手動でfret/string overrideした場合はTabFretに `isManualOverride: true` フラグ
- 同期はCommandEngine経由でatomic

#### ギターテクニック

| テクニック | 記号（TUI ASCII） | MusicXML要素 |
|------------|-------------------|--------------|
| Hammer-on | `h` | `hammer-on` |
| Pull-off | `p` | `pull-off` |
| Slide up | `/` | `slide` |
| Slide down | `\` | `slide` |
| Bend | `b` | `bend` |
| Release | `r` after bend | `bend/release` |
| Vibrato | `~` | `wavyLine` |
| Palm mute | `PM` | `technical/other-technical` |
| Harmonic | `<>` | `harmonic` |
| Tapping | `t` | `tap` |
| Dead note | `x` | `muted` |
| Ghost note | `()` | `ghost-note` |

#### TAB Editor TUI

- 1行 = 1弦（最上行が最高弦）
- カーソルが弦・fret位置を示す
- `0-9` でfret番号入力（2桁は `12` 等連続入力）
- テクニックはテクニックキーで追加（Insert mode内でのサブモード）

### 16.2 Percussion Notation

#### Drum Mapping

```dart
final class DrumInstrument {
  final String name;       // "Snare", "Kick", "Hi-Hat Closed" ...
  final int staffLine;     // -4 〜 4（0=中線）
  final NoteHeadType noteHeadType;
  final int midiNote;
  final int gmProgram;     // General MIDI drum note number（35〜81）
}

// GMデフォルトマッピング
const generalMidiDrumMap = DrumMapping({
  35: DrumInstrument("Bass Drum 2", staffLine: -4, noteHeadType: normal, midiNote: 35),
  36: DrumInstrument("Bass Drum 1", staffLine: -4, noteHeadType: normal, midiNote: 36),
  38: DrumInstrument("Snare", staffLine: 0, noteHeadType: normal, midiNote: 38),
  42: DrumInstrument("Hi-Hat Closed", staffLine: 4, noteHeadType: cross, midiNote: 42),
  44: DrumInstrument("Hi-Hat Pedal", staffLine: -5, noteHeadType: cross, midiNote: 44),
  46: DrumInstrument("Hi-Hat Open", staffLine: 4, noteHeadType: openCross, midiNote: 46),
  49: DrumInstrument("Crash 1", staffLine: 5, noteHeadType: cross, midiNote: 49),
  51: DrumInstrument("Ride", staffLine: 5, noteHeadType: cross, midiNote: 51),
  // ...
});
```

#### Percussion Notation対応要素

- notehead type: normal / cross / diamond / slash / triangle / x / backslash
- staff line mapping: 各instrumentを固定staff lineに配置
- percussion clef: `%` clef記号
- voice separation: kick=voice1 / snare+hi-hat=voice2 / cymbals=voice3（デフォルト）
- sticking: `R` / `L` テキストアノテーション
- rudiments: roll（`//` トレモロ記号）/ flam / drag / ruff

### 16.3 Percussion TAB

#### Percussion TABモデル

```dart
final class PercussionTabConfig {
  final IList<PercussionTabLine> lines;
}

final class PercussionTabLine {
  final String label;          // "BD", "SN", "HH", "RD", ...
  final int midiNote;
  final String defaultSymbol;  // "X", "O", "x" ...
}
```

#### Percussion TABレイアウト

```
BD |--X-|----|----|--X-|
SN |----|--X-|----|--X-|
HH |X-X-|X-X-|X-X-|X-X-|
RD |----|----|----|X---|
   |  1 |  2 |  3 |  4 |
```

- 縦軸: instrument（行）
- 横軸: 時間（拍・16分音符等のgrid）
- grid解像度: 4分 / 8分 / 16分 / 32分 選択可

#### Standard Notationとの変換

- Percussion TAB → Standard: TABのシンボル位置からdrum instrumentを決定し、staff line・noteheadに変換
- Standard → Percussion TAB: drum mappingからTABシンボルを逆引き

---

## 17. Cross-staff / N Voice仕様

### 17.1 Cross-staff Beaming

```dart
// ノートが論理上は上声部（Staff 1, Voice 1）に属するが、
// 表示上は下のStaff 2に配置するケース
final class CrossStaffBeamGroup extends BeamGroup {
  final IList<CrossStaffRef> crossStaffRefs;
}

final class CrossStaffRef {
  final NoteId noteId;
  final StaffId displayStaff;  // 表示先staff
  final StaffId logicalStaff;  // 音高・声部の帰属先staff
}
```

LayoutEngineは：
1. logicalStaffでvoice/pitch決定
2. displayStaffでY座標を決定
3. BeamをcrossStaffRefを考慮して複数staff間に描画

### 17.2 Cross-staff Stemming

- stemの長さは通常（3.5sp）を基準に、cross-staffの場合はstaff間距離まで延長
- stem方向はcross先staffの方向に統一

### 17.3 N Voice対応

```dart
// 任意数voice
final class VoiceConfig {
  final VoiceId id;
  final int voiceNumber;       // 表示番号（1-indexed）
  final int priority;          // 数値が小さいほど優先
  final StemDirection stemDirectionPolicy;
  final RestPositioningPolicy restPolicy;
  final bool isHidden;
  final bool isPlayback;
  final bool isEditing;
}

enum StemDirection { up, down, auto }
enum RestPositioningPolicy { auto, center, byVoice }
```

#### Voice間衝突解決優先度

- voice priority 小 = 衝突解決で固定（動かさない）
- voice priority 大 = 衝突解決で移動対象

#### Shared Notehead

- 同一pitch・同一オフセットで複数voiceが音符を持つ場合、1つのnoteheadを共有
- stem方向で区別（上声部=stem up / 下声部=stem down）
- accidentalは共有、articulation/dynamicはvoice別

#### Overlapping Duration

- voice間でdurationが重なる場合（polyrhythm）は両voiceを独立に表示
- collision detectionで重なりを検出し、X offsetで解決

#### MusicXML Voice Mapping

MusicXMLは1パートあたり最大4声（voice 1〜4）を想定するが、score_systemはN声対応。
- export時に5声以上はwarningを出してvoice 1〜4にマッピング（または複数part化）
- import時はMusicXMLのvoice番号をそのままVoiceIdとして使用

---

## 18. ファイル形式・入出力

### 18.1 優先度別対応

| 形式 | 優先度 | 方向 | ステータス |
|------|--------|------|----------|
| `.score.json`（native） | P0 | read/write | MVP必須 |
| MusicXML 3.1 | P0 | import/export | MVP必須 |
| MIDI SMF Type 1 | P0 | export | MVP必須 |
| MIDI events JSON dump | P0 | 読み取り専用（検査） | MVP必須 |
| MIDI SMF Type 0 | P1 | export | v1 |
| MusicXML 4.0 | P2 | import/export | v1 |
| MEI | P3 | import/export | Future |
| LilyPond | P3 | export | Future |
| Guitar Pro | P3 | import | Future |
| MuseScore | P3 | import | Future |
| PDF | - | export | 対象外 |
| SVG | - | export | 対象外 |
| PNG | - | export | 対象外 |

### 18.2 Native Format設計方針

- UTF-8 JSON テキスト（バイナリ禁止）
- テキストエディタ・コーディングエージェントが直接読み書き可能
- `$schema_version` フィールドでマイグレーション管理
- 人間可読なindent整形（2スペース）
- Fraction値は `"3/4"` 等の文字列表現
- IDはUUID v4文字列

### 18.3 MusicXML Import範囲

**対応（MVP）**

- partwise MusicXML（timewise は変換して対応）
- note / rest / chord / pitch / duration
- measure / barline / repeat / ending
- clef / key / time / beat-type
- beam / stem / tuplet
- slur / tie
- dynamic / wedge
- lyric / syllabic / text
- articulation（staccato / accent / tenuto / fermata 等）
- ornament（trill / turn / mordent）
- TAB記法（frame / fret / string）
- percussion記法（unpitched-pitch / notehead）

**非対応（警告でskip）**

- figured-bass
- frame（guitar chord diagram グラフィクス）
- harp-pedals
- accordion-registration
- sound（playback hint）
- 一部のdirectionサブ要素

---

## 19. 配布方針

### 19.1 Dart Package

個人ツールのため pub.dev 公開は不要。Gitリポジトリ（GitHub等）で管理する。

| Package | 管理方法 |
|---------|---------|
| score_core〜score_mcp | モノレポ内で管理。必要に応じてGit dependencyとして参照可 |
| score_flutter | 骨格のみ作成。将来の自分が使うために設計だけ確保 |

### 19.2 Native Executable（個人環境への導入）

```bash
# ビルドと個人環境への配置
dart compile exe bin/score.dart -o build/score
cp build/score /usr/local/bin/score   # macOS / Linux

# または PATH に bin/ を追加して dart run bin/score.dart で使う（開発中はこちらで十分）
```

MVP段階では `dart run` で実行でよい。ネイティブバイナリ化はv1で行う。

対象: macOS arm64（開発環境）を優先。Windows / Linux は後回し。

### 19.3 MCP Server（補助）

```bash
score mcp serve
```

Claude Desktop 設定例：

```json
{
  "mcpServers": {
    "score_system": {
      "command": "dart",
      "args": ["run", "/path/to/score_system/bin/score.dart", "mcp", "serve",
               "--sandbox", "/Users/me/scores"]
    }
  }
}
```

### 19.4 Flutter App

将来の自分向けのGUIエディタ。設計だけ確保しておき、実装は後回し。AppStore公開等は考えない。

---

## 20. リスクと技術課題

| リスク | 深刻度 | 対策 |
|--------|--------|------|
| **Dart-onlyでのレイアウトエンジン性能** | 高 | incremental layout・layout cache・isolate分離を設計段階から考慮。benchmarkをCIに組み込む |
| **大規模スコア処理（1000小節超）** | 高 | チャンク処理・lazy evaluation・immutableモデルのshared memory活用（const）|
| **衝突回避アルゴリズムの収束** | 高 | 最大iteration制限・priority modelの明確化・解決不能時のwarning返却 |
| **MusicXML互換性** | 中 | 公式テストスイートとの定期的な回帰テスト。非対応要素は必ずwarning記録 |
| **N voice設計の複雑度** | 中 | voice間の依存を最小化。各voiceを独立なEventリストとして管理 |
| **cross-staff表現の実装難度** | 中 | cross-staff referenceをfirst classモデルとして設計。MVPでは内部モデルのみ・layout計算は部分対応 |
| **TAB ↔ 五線譜同期の整合性** | 中 | sync commandをatomicに設計。manual overrideフラグで意図的な不一致を許容 |
| **TUI terminal互換性** | 中 | ANSI基本エスケープコードに限定。Windows Terminal / iTerm2 / tmuxで動作確認 |
| **MCP Serverのセキュリティ** | 中 | sandbox policy・confirmation handshake・audit logを設計段階から組み込む |
| **MusicXML Fraction精度** | 低 | Fractionクラスをexact integer arithmeticで実装（浮動小数点回避） |
| **Melos運用の複雑化** | 低 | package数が多いため、CI時間増大に注意。concurrency設定で並列化 |
| **Flutter GUI移行の摩擦** | 低 | score_core / score_layoutをFlutter非依存に保てば移行は容易。骨格packageを早期に作成 |

---

## 21. 受け入れ条件

### ユーザー視点

| ID | 条件 |
|----|------|
| AC-U-01 | `score import musicxml sample.xml -o sample.score.json && score export musicxml sample.score.json -o roundtrip.xml` が成功する |
| AC-U-02 | `score tui sample.score.json` で楽譜が開き、音符を追加・削除・undo/redoできる |
| AC-U-03 | `score mcp serve` でMCP Serverが起動し、Claude Desktopからtool callできる |
| AC-U-04 | `score collisions sample.score.json` が衝突レポートをJSON出力する |
| AC-U-05 | `score fix-collisions sample.score.json -o fixed.score.json` で衝突が自動解決される |
| AC-U-06 | guitar TABをTUI TAB editorで入力でき、五線譜と同期される |
| AC-U-07 | percussion gridでドラムパターンを入力しMIDIとしてエクスポートできる |

### 開発者視点

| ID | 条件 |
|----|------|
| AC-D-01 | `melos run analyze` が全packageでwarning 0 / error 0で通過する |
| AC-D-02 | `melos run test` が全packageで通過する |
| AC-D-03 | `melos run deps_check` でpackage境界違反が検出されない |
| AC-D-04 | `score_core` をFlutterなしでimportしてテストできる |
| AC-D-05 | layout golden testがdeterministicに通過する（CI 3回連続で同じ結果） |
| AC-D-06 | `dart compile exe bin/score.dart -o build/score` が成功する |
| AC-D-07 | MusicXML roundtripで主要testスイートのXMLが losslessにroundtripする |

### QA視点

| ID | 条件 |
|----|------|
| AC-Q-01 | code coverage ≥ 85%（score_core + score_layout） |
| AC-Q-02 | 100小節・4声・4パートのlayout計算が ≤ 200ms（シングルスレッド） |
| AC-Q-03 | macOS / Linux / WindowsのCIマトリクスがすべて通過する |
| AC-Q-04 | CollisionReport / LayoutTree / ValidationResultがすべてJSON serializableである |
| AC-Q-05 | CLIの全コマンドがexit code 0で正常終了する（正常入力） |
| AC-Q-06 | 不正入力に対してCLIがexit code 1とJSON errorメッセージを返す |

---

## 22. テスト戦略

### 23.1 テスト分類と配置

| テスト種別 | パッケージ | ツール | 実行タイミング |
|------------|-----------|--------|--------------|
| Unit test | 全package | `dart test` | PR・push毎 |
| Command engine test | score_core | `dart test` | PR・push毎 |
| Validation test | score_core | `dart test` | PR・push毎 |
| Layout golden test | score_layout | `dart test --name golden` | PR・push毎 |
| Layout regression test | score_layout | `dart test` | PR・push毎 |
| Collision detection test | score_layout | `dart test` | PR・push毎 |
| Collision resolution test | score_layout | `dart test` | PR・push毎 |
| MusicXML import test | score_io | `dart test` | PR・push毎 |
| MusicXML export test | score_io | `dart test` | PR・push毎 |
| MusicXML roundtrip test | score_io | `dart test` | PR・push毎 |
| MIDI export test | score_io | `dart test` | PR・push毎 |
| Native format roundtrip | score_io | `dart test` | PR・push毎 |
| CLI test | score_cli | `dart test` + Process test | PR毎 |
| TUI snapshot test | score_tui | `dart test` + golden | PR毎 |
| MCP tool test | score_mcp | `dart test` | PR毎 |
| Dependency boundary test | tools | `dart run` | PR毎 |
| Performance benchmark | score_layout | `dart run benchmark/` | weekly |
| Fuzz test | score_core / score_io | `package:fuzz` | 夜間 |
| Property-based test | score_core | `package:test` + `Arbitrary` | PR毎 |
| Cross-platform test | 全package | GitHub Actions matrix | PR毎 |

### 23.2 Layout Golden Test方針

```
test/golden/layout/
  simple_quarter_notes.golden.json       # 4分音符4つ
  chord_with_accidentals.golden.json     # 和音+臨時記号
  n_voice_collision.golden.json          # N声衝突解決後
  cross_staff_beam.golden.json           # cross-staff連桁
  guitar_tab.golden.json                 # guitar TAB
  percussion_grid.golden.json            # パーカッション
```

- LayoutTree全体をJSON serializeして比較（画像不要）
- `--update-goldens` フラグでgolden更新
- CIではupdate-goldensを禁止（変更はPR内でのみ）

### 23.3 TUI Snapshot Test方針

```
test/snapshots/tui/
  normal_mode.snapshot.txt
  insert_mode.snapshot.txt
  collision_panel.snapshot.txt
  tab_editor.snapshot.txt
```

- ANSIエスケープコードを除去したプレーンテキスト
- `String` 比較でOK（画像不要）
- コーディングエージェントが読める形式

### 23.4 MusicXML Roundtrip Test

```
test/fixtures/musicxml/
  bach_bwv846.xml       # バッハ平均律
  simple_chord.xml      # 和音テスト
  cross_staff.xml       # cross-staff
  n_voice.xml           # N voice（4声以上）
  guitar_tab.xml        # TAB notation
  percussion.xml        # percussion notation
```

テスト手順:
1. import → `Score` model
2. validate → errors 0
3. export → `MusicXML`
4. import再度 → `Score` model 2
5. Score 1 == Score 2（対応要素のみ比較）

### 23.5 Fuzz Test

```dart
// MusicXMLパーサーのfuzz test
void main() {
  test('musicxml parser does not throw on arbitrary bytes', () {
    final fuzzer = Fuzzer();
    for (final bytes in fuzzer.generate(1000)) {
      expect(() => MusicXmlImporter().import(String.fromCharCodes(bytes)), returnsNormally);
    }
  });
}
```

---

## 23. 開発タスク分解

### Epic 1: 基盤整備

| Story | Task |
|-------|------|
| E1-S1: monorepo構成 | T1: pubspec.yaml workspace設定 |
| | T2: melos.yaml設定 |
| | T3: analysis_options.yaml共有設定 |
| | T4: 各packageの骨格作成 |
| | T5: GitHub Actions CI設定 |
| E1-S2: dep_checker | T6: dep_checker.dart実装 |
| | T7: CIにdep_checkスクリプト追加 |

### Epic 2: score_core

| Story | Task |
|-------|------|
| E2-S1: 基本モデル | T8: Pitch / Duration / Fraction |
| | T9: Score / Part / Staff |
| | T10: Measure / Voice / MusicEvent |
| | T11: NoteEvent / RestEvent / ChordEvent |
| | T12: Clef / KeySignature / TimeSignature |
| | T13: Barline / MeasureHeader |
| E2-S2: Edge要素 | T14: BeamGroup / Tuplet |
| | T15: Slur / Tie |
| | T16: Articulation / Dynamic / Lyric |
| E2-S3: Command Engine | T17: Command sealed class |
| | T18: AddNoteCommand / RemoveNoteCommand |
| | T19: CommandEngine.apply / dryRun |
| | T20: CommandHistory（Undo/Redo） |
| | T21: BatchCommand |
| | T22: AuditLog |
| E2-S4: Validation | T23: Validator基盤 |
| | T24: 拍子整合性ルール |
| | T25: 音域バリデーション |
| | T26: ValidationResult JSON serialize |
| E2-S5: TAB model | T27: TabConfig / TabFret |
| | T28: GuitarTechnique |
| E2-S6: Percussion model | T29: DrumMapping / DrumInstrument |
| | T30: PercussionNote |
| E2-S7: Cross-staff model | T31: CrossStaffRef |
| | T32: CrossStaffBeamGroup |
| E2-S8: N Voice | T33: VoiceConfig |
| | T34: VoicePriority policy |

### Epic 3: score_io

| Story | Task |
|-------|------|
| E3-S1: native format | T35: Score.toJson / Score.fromJson |
| | T36: Fraction ↔ String変換 |
| | T37: schema migration基盤 |
| E3-S2: MusicXML | T38: MusicXML DOMパーサー |
| | T39: note / rest / chord import |
| | T40: beam / tuplet / slur / tie import |
| | T41: dynamic / lyric / articulation import |
| | T42: MusicXML export generator |
| | T43: Roundtripテスト |
| E3-S3: MIDI | T44: MIDI SMF Type 1 encoder |
| | T45: MIDI JSON dump |

### Epic 4: score_layout

| Story | Task |
|-------|------|
| E4-S1: 基盤 | T46: BoundingBox |
| | T47: LayoutElement sealed class |
| | T48: LayoutTree |
| E4-S2: spacing | T49: NoteLayout（X/Y計算） |
| | T50: MeasureSpacingEngine |
| | T51: StaffSpacingEngine |
| E4-S3: voice layout | T52: StemDirection決定 |
| | T53: RestPositioning |
| | T54: SharedNotehead検出 |
| E4-S4: collision | T55: CollisionDetector |
| | T56: CollisionReport |
| | T57: CollisionResolver |
| | T58: ManualOverride対応 |
| E4-S5: golden test | T59: golden test基盤 |
| | T60: 主要golden JSON作成 |
| | T61: incremental layout基盤 |

### Epic 5: score_cli

| Story | Task |
|-------|------|
| E5-S1: コマンド | T62: score new |
| | T63: score validate |
| | T64: score import/export musicxml |
| | T65: score export midi |
| | T66: score layout / collisions / fix-collisions |
| | T67: score inspect / inspect --midi |
| | T68: score diff |
| | T69: score tui / mcp serve |

### Epic 6: score_tui

| Story | Task |
|-------|------|
| E6-S1: 基盤 | T70: ANSI terminal renderer |
| | T71: Mode管理（NORMAL/INSERT/COMMAND） |
| | T72: キーバインド管理 |
| E6-S2: パネル | T73: Score Tree パネル |
| | T74: Measure Grid パネル |
| | T75: Event List パネル |
| | T76: Collision Report パネル |
| | T77: Validation パネル |
| | T78: Command Palette |
| E6-S3: editor | T79: 音符入力（INSERT mode） |
| | T80: TAB Editor |
| | T81: Percussion Grid |
| E6-S4: test | T82: TUI snapshot test基盤 |
| | T83: 主要snapshot作成 |

### Epic 7: score_mcp

| Story | Task |
|-------|------|
| E7-S1: Server基盤 | T84: MCP stdio transport |
| | T85: Resource handler基盤 |
| | T86: Tool handler基盤 |
| E7-S2: Resources | T87: score/parts/measures resource |
| | T88: layout/collision/validation resource |
| E7-S3: Tools | T89: query tools |
| | T90: edit tools |
| | T91: layout/collision tools |
| | T92: import/export tools |
| E7-S4: 安全性 | T93: Confirmation Handshake |
| | T94: Sandbox policy |
| | T95: Audit log |

---

## 24. 次に決めるべきこと

**全項目確定済み。未決事項ゼロ。**

実装を開始できる状態。[20. ロードマップ](#20-mvp--v1--v2-ロードマップ) の Phase 0 から着手する。

### 最初にやること（Phase 0）

1. GitHubにprivateリポジトリを作成
2. monorepo構成（Pub Workspaces + Melos）を構築
3. 全package骨格（`dart create`）を作成
4. `analysis_options.yaml` 共有設定を配置
5. GitHub Actions CI（analyze + test）を設定
6. `tools/dep_checker.dart` を実装
7. 全package `melos run analyze` が warning 0 / error 0 で通過することを確認

---

*この要件定義書はドラフトです。[確認質問](#1-確認質問) への回答をいただき次第、仮定を実際の決定事項に更新します。*
