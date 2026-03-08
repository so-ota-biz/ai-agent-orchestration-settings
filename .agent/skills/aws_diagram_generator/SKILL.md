---
name: aws-diagram-generator
description: 【非推奨】このスキルは drawio_diagram に統合されました。新規のAWS構成図作成には drawio_diagram を使用してください。このスキルは使用しないでください。
---

# Skill: Draw.io AWS Architecture Generator（非推奨）

> **このスキルは非推奨です。**
> AWS・GCP・汎用アーキテクチャ図の作成には、代わりに **`drawio_diagram`** スキルを使用してください。
> `drawio_diagram` はこのスキルのすべての機能を包含し、さらに改善されています。

---

## 1. Overview（旧）

このスキルは、ユーザーの要求に応じてAWSのベストプラクティスに基づいたインフラ構成図を設計し、Draw.io（diagrams.net）で編集可能な形式で生成・操作するためのものです。

## 2. Capability & Context

- **専門知識:** AWSアーキテクチャ（Well-Architected Framework）に基づいたコンポーネント配置。
- **出力形式:** mxGraph形式のXML、またはMCPツールを介した直接的な図形操作。
- **デザイン:** AWS公式アイコンセット（最新版）のスタイルと階層構造（Region > VPC > AZ > Subnet）の遵守。

## 3. Tool Definitions (Assumed MCP Functions)

このスキルは、以下の関数がMCPサーバー側で定義されていることを前提とします。

- `create_new_diagram(title)`: 新しい描画キャンバスを作成する。
- `add_aws_resource(type, name, parent_id, x, y)`: EC2, RDS, S3などのアイコンを配置する。
- `add_container(type, label, x, y, w, h)`: VPCやSubnetなどの枠線を作成する。
- `draw_connection(source_id, target_id, label)`: リソース間に矢印線を引く。

## 4. Design Guidelines & Rules

### 0. デフォルト生成モード（必須）

- AWS構成図は、まずローカルアセット `~/aws-assets` を優先して使用する。
- ローカルアセット利用時は **SVGのみ使用可** とし、`png/jpg/jpeg` は使用禁止とする。
- 対象リソースに対応するSVGが複数ある場合は、最も標準的なサービス/リソースアイコン（例: `Application-Load-Balancer`, `EC2_Instance`）を優先する。
- SVG配置は、draw.io上で壊れ画像（破損アイコン）が出ない方式を必須とする。壊れ画像を招く埋め込み方式（不適切なdata URI等）は使用しない。
- `~/aws-assets` が存在しない場合、または対象リソースに対応する適切なSVGが見つからない場合のみ、**draw.io の AWS 図形ライブラリ（AWS shape）**へフォールバックする。
- **Mermaidによる汎用ノード作図はデフォルトで使用しない**。
- Mermaidを使ってよいのは、ユーザーが明示的に「Mermaidで」と指定した場合のみ。
- 既定の実行方針は「AWS公式アセットの可読性・標準性を優先し、不足時はAWS shapeで補完する」とする。
- 作図完了前に、AWSアイコンが正常表示されていること（壊れ画像でないこと）を確認する。
- 完了報告時に、使用したSVGの絶対パスを列挙する。

### A. 階層構造の定義

構成図を作成する際は、以下の入れ子構造を維持してください。

1. **Cloud/Region**: 最外周の境界。
2. **VPC**: ネットワークの境界。
3. **Availability Zones (AZ)**: 物理的な分離を示す境界（通常2つ以上）。
4. **Subnets**: Public/Privateの論理分離。
5. **Resources**: 各サブネット内にアイコンを配置。

### B. レイアウト基準

- **アイコンサイズ**: 標準 60x60px。
- **パディング**: コンテナ（VPC等）の境界線と内部リソースの間隔は 40px 以上。
- **間隔**: アイコン間の水平距離は 120px、垂直距離は 80px を推奨。

### C. XML (mxGraph) 構造テンプレート

直接XMLを生成する場合は、以下の構造に従ってください。

```xml
<mxGraphModel>
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    <mxCell id="vpc_01" value="VPC (10.0.0.0/16)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=none;strokeColor=#232F3E;dashed=1;verticalAlign=top;" vertex="1" parent="1">
      <mxGeometry x="50" y="50" width="600" height="400" as="geometry" />
    </mxCell>
    <mxCell id="ec2_01" value="Web Server" style="outlineConnect=0;fontColor=#232F3E;gradientColor=none;fillColor=#F58534;strokeColor=none;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.ec2;" vertex="1" parent="vpc_01">
      <mxGeometry x="100" y="100" width="60" height="60" as="geometry" />
    </mxCell>
  </root>
</mxGraphModel>
```
