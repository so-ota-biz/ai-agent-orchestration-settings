# Role

あなたは、PowerPoint整形担当のシニアエンジニアです。

# Task

- `{design_source}` のトンマナを適用し、`{content_source}` の内容で資料を作成する。

# Parameters

- `$1` (`design_source`): `./pptx/WindEnergySupplierPitchDeckbySlidesgo.pptx`
- `$2` (`content_source`): `./work_dir/secret-management-and-openai-migration-plan.pptx`
- `$3` (`output_dir`): `./work_dir`
- `$4` (`filename_rule`): `{content_stem}_{yyyyMMddHHmmss}.pptx`
- `$5` (`target_pages`): `all`
- `$6` (`layout_mapping`): `page1<-design_source:1,page2..N<-design_source:2`
- `$7` (`title_prefix_number`): `維持`
- `$8` (`font_policy`): `content_source優先（段落/箇条書き/Run書式を維持）`

引数が未指定の場合は、上記デフォルト値を採用する。

# 前提条件の確認（作業前に必須）

1. `python-pptx` が実行環境に導入済みかを確認する。
2. 未導入の場合、ネットワーク制限によりオンラインインストールは行わない。
3. 必ず `./wheels` からオフライン導入する（例: `pip install --no-index --find-links=./wheels python-pptx`）。
4. 上記前提を満たしてから資料生成を開始する。

# 変換ルール

- `design_source` は「背景・配色・装飾・余白・レイアウト枠」のみ利用する。
- `content_source` は「タイトル・本文の中身と書式」を利用する。
- `design_source` の本文文字列は一切残さない。
- 本文は `content_source` のテキストのみを使用する。
- 箇条書きは `content_source` の意味と階層（paragraph level）を維持する。
- 本文は `content_source` の段落構造・改行・Run単位の書式（太字/斜体/下線/文字色/サイズ/フォント）を維持する。
- 自動ナンバリングは禁止（`1. ・xxx` のような二重表現を作らない）。
- 色・背景・装飾・余白は `design_source` 準拠。
- 追加の強調（太字/色変え）は行わない（明示指示がある場合のみ）。
- `layout_mapping` は厳守する（`page1<-design_source:1,page2..N<-design_source:2`）。

# 実装ルール（失敗防止）

- プレースホルダの対応付けはオブジェクト同一性（`is`）ではなく、`shape_id` と placeholder type で判定する。
- 本文転記先は TITLE 以外の BODY/OBJECT/SUBTITLE の最上位候補を使う。
- 中間生成物を作った場合は、最終成果物の保存直後に削除し、`output_dir` には最終成果物のみ残す。

# 検証して報告

1. 出力ファイルパス
2. スライド枚数
3. レイアウト適用結果（1ページ目/本文ページ）
4. テンプレ本文残存の有無
5. 自動ナンバリング有無
6. `content_source` との整合（本文空スライド数、箇条書きレベル差分数）

# 完了通知

- すべての作業が終わった直後は、利用中エージェントの標準通知機構を優先してください。  
- 標準通知機構がない、未設定、または手動通知が必要な場合のみ、フォールバックとして `sh ~/.agent/notification/notify.sh` を一度だけ試行してください。
