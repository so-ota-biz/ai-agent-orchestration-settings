---
name: drawio_diagram
description: Draw.ioを使用してAWS・GCPなどのクラウド構成図や汎用アーキテクチャ図を設計・生成するスキル。「構成図を描いて」「draw.ioで図を作って」「AWSアーキテクチャを図示して」「GCP構成図」などの依頼で使用する。
---

# Skill: Draw.io Architecture Diagram Generator

Version: 1.1
LastUpdated: 2026-03-07
Scope: Draw.io（diagrams.net）でクラウド構成図・アーキテクチャ図を生成・編集する

---

## 0. このSkillの目的

- **主成果物**: draw.io で開いて編集できる図（XML / MCP経由の直接操作）
- AWS・GCP の公式アイコンを使った構成図を綺麗に描く
- 読み手が図だけで構成を把握できる品質を担保する

---

## 1. MCP ツールの優先順位

以下のMCPツールが利用可能な場合、直接XMLファイルを生成するより優先する。

| ツール | 用途 |
|---|---|
| `mcp__drawio__open_drawio_xml` | mxGraph XMLを直接draw.ioで開く（最優先） |
| `mcp__drawio__open_drawio_mermaid` | Mermaid記法で図を開く（シンプルなフロー向け） |
| `mcp__drawio__open_drawio_csv` | CSVから図を生成する |

**原則**: まず `open_drawio_xml` でXMLを生成・表示する。ユーザーが「Mermaidで」と明示した場合のみ `open_drawio_mermaid` を使う。

---

## 2. 実行プロセス

### Step 1: 要件整理
ユーザーの依頼から以下を確認する（不明な場合は最善解を選んで進め、最後に確認する）。

- **クラウドプロバイダー**: AWS / GCP / Azure / マルチクラウド / 汎用
- **図の種類**: 構成図 / ネットワーク図 / データフロー図 / シーケンス図
- **主要リソース**: 含めるべきサービス・コンポーネント
- **接続フロー**: データの流れ・通信の方向

### Step 2: 構造設計
コードを書く前に、以下の階層構造を頭の中で設計する。

```
[クラウド境界]
  └── [VPC/VNet/VPC Network]
        ├── [可用性ゾーン/リージョン]
        │     ├── [パブリックサブネット]
        │     │     └── リソース群
        │     └── [プライベートサブネット]
        │           └── リソース群
        └── [マネージドサービス群]
```

### Step 3: XML生成
後述のテンプレートとルールに従いXMLを生成する。

### Step 4: MCP経由で表示
`mcp__drawio__open_drawio_xml` を呼び出して図を表示する。

### Step 5: Quality Gates チェック
後述のチェックリストを通過してから完了報告する。

---

## 3. レイアウトルール（必須）

### 3.1 サイズ基準

| 要素 | サイズ |
|---|---|
| リソースアイコン | 60×60px（標準）|
| グループコンテナの内部パディング | 40px 以上 |
| アイコン間の水平間隔 | 120px |
| アイコン間の垂直間隔 | 80px |
| ラベルとアイコンの距離 | アイコン下部から 5px |

### 3.2 配置方針

- **左→右** を基本フロー方向とする（入口が左、出口が右）
- **上→下** はサブネット階層（パブリック上、プライベート下）
- 矢印は交差しないよう座標を調整する
- **矢印ラベルは矢印から最低 20px 以上離す**（テキスト被り防止）

### 3.3 フォント設定

- `mxGraphModel` の `defaultFontFamily` だけでは反映されない
- **各 `mxCell` の `style` 属性に `fontFamily=Helvetica;` を明示する**
- 日本語ラベル: 1文字あたり約 30〜40px を確保（英語より横幅が必要）

### 3.4 XML 要素の順序

矢印（Edge）をXMLの先頭に、ノード（Vertex）をその後に記述すると、矢印が他要素の背後に描画される（視認性向上）。

```xml
<root>
  <mxCell id="0" />
  <mxCell id="1" parent="0" />
  <!-- 1. 先に矢印（Edge）を定義 -->
  <mxCell id="edge_01" ... edge="1" ... />
  <!-- 2. 後にノード（Vertex）を定義 -->
  <mxCell id="node_01" ... vertex="1" ... />
</root>
```

---

## 4. AWS 構成図ルール

### 4.1 階層構造

```
AWS Cloud (Region)
  └── VPC
        ├── Public Subnet (AZ-a)
        │     └── ALB, NAT Gateway, Bastion
        ├── Private Subnet (AZ-a)
        │     └── EC2, ECS, Lambda
        ├── Private Subnet (AZ-b)
        │     └── EC2, ECS, Lambda
        └── DB Subnet
              └── RDS, ElastiCache
```

### 4.2 AWS アイコンスタイル（draw.io 標準）

draw.io の AWS4 シェイプライブラリを使用する。`shape=mxgraph.aws4.<service>` の形式。

| サービス | style |
|---|---|
| EC2 | `shape=mxgraph.aws4.ec2;fillColor=#F58534;strokeColor=none;` |
| RDS | `shape=mxgraph.aws4.rds;fillColor=#2E73B8;strokeColor=none;` |
| S3 | `shape=mxgraph.aws4.s3;fillColor=#3F8624;strokeColor=none;` |
| ALB | `shape=mxgraph.aws4.application_load_balancer;fillColor=#F58534;strokeColor=none;` |
| Lambda | `shape=mxgraph.aws4.lambda;fillColor=#F58534;strokeColor=none;` |
| CloudFront | `shape=mxgraph.aws4.cloudfront;fillColor=#8C4FFF;strokeColor=none;` |
| API Gateway | `shape=mxgraph.aws4.api_gateway;fillColor=#F58534;strokeColor=none;` |
| ECS | `shape=mxgraph.aws4.ecs;fillColor=#F58534;strokeColor=none;` |
| SQS | `shape=mxgraph.aws4.sqs;fillColor=#F58534;strokeColor=none;` |
| SNS | `shape=mxgraph.aws4.sns;fillColor=#F58534;strokeColor=none;` |
| ElastiCache | `shape=mxgraph.aws4.elasticache;fillColor=#2E73B8;strokeColor=none;` |
| VPC | `shape=mxgraph.aws4.group_vpc;fillColor=none;strokeColor=#8C4FFF;` |
| Internet Gateway | `shape=mxgraph.aws4.internet_gateway;fillColor=#8C4FFF;strokeColor=none;` |
| Route 53 | `shape=mxgraph.aws4.route_53;fillColor=#8C4FFF;strokeColor=none;` |

全アイコンに共通で付与するスタイル属性:
```
outlineConnect=0;fontColor=#232F3E;gradientColor=none;dashed=0;
verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;
fontSize=12;fontStyle=0;aspect=fixed;fontFamily=Helvetica;
```

### 4.3 コンテナスタイル（AWS）

```xml
<!-- AWS Cloud / Region -->
<mxCell style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_aws_cloud_alt;strokeColor=#232F3E;fillColor=#FFFFFF;verticalAlign=top;align=center;spacingTop=25;dashed=0;fontFamily=Helvetica;" />

<!-- VPC -->
<mxCell style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_vpc;strokeColor=#8C4FFF;fillColor=#F4F0FF;verticalAlign=top;align=center;spacingTop=25;dashed=0;fontFamily=Helvetica;" />

<!-- Public Subnet -->
<mxCell style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_public_subnet;strokeColor=#3F8624;fillColor=#F0FFF0;verticalAlign=top;align=center;spacingTop=25;dashed=0;fontFamily=Helvetica;" />

<!-- Private Subnet -->
<mxCell style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_private_subnet;strokeColor=#147EBA;fillColor=#E6F2F8;verticalAlign=top;align=center;spacingTop=25;dashed=0;fontFamily=Helvetica;" />
```

### 4.4 接続線（AWS）

| フロータイプ | スタイル |
|---|---|
| 通常のリクエスト（同期） | `endArrow=block;endFill=1;strokeColor=#232F3E;` |
| 非同期メッセージ | `endArrow=block;endFill=1;strokeColor=#232F3E;dashed=1;` |
| データフロー | `endArrow=open;endFill=0;strokeColor=#3F8624;strokeWidth=2;` |

---

## 5. GCP 構成図ルール

### 5.1 階層構造

```
GCP Project
  └── VPC Network
        ├── Region
        │     ├── Subnet (us-central1)
        │     │     └── Compute Engine, GKE Node
        │     └── Subnet (us-east1)
        └── Global Resources
              └── Cloud Load Balancing, Cloud CDN
```

### 5.2 GCP アイコンスタイル（draw.io 標準）

`shape=mxgraph.gcp2.<service>` の形式を使用する。

| サービス | style |
|---|---|
| Compute Engine | `shape=mxgraph.gcp2.compute_engine;fillColor=#4285F4;strokeColor=none;` |
| Cloud Storage | `shape=mxgraph.gcp2.cloud_storage;fillColor=#4285F4;strokeColor=none;` |
| Cloud SQL | `shape=mxgraph.gcp2.cloud_sql;fillColor=#4285F4;strokeColor=none;` |
| GKE | `shape=mxgraph.gcp2.container_engine;fillColor=#4285F4;strokeColor=none;` |
| Cloud Functions | `shape=mxgraph.gcp2.cloud_functions;fillColor=#4285F4;strokeColor=none;` |
| Pub/Sub | `shape=mxgraph.gcp2.cloud_pubsub;fillColor=#4285F4;strokeColor=none;` |
| BigQuery | `shape=mxgraph.gcp2.bigquery;fillColor=#4285F4;strokeColor=none;` |
| Cloud Run | `shape=mxgraph.gcp2.cloud_run;fillColor=#4285F4;strokeColor=none;` |
| Load Balancing | `shape=mxgraph.gcp2.cloud_load_balancing;fillColor=#4285F4;strokeColor=none;` |
| Cloud CDN | `shape=mxgraph.gcp2.cloud_cdn;fillColor=#4285F4;strokeColor=none;` |

全アイコンに共通で付与するスタイル属性:
```
outlineConnect=0;fontColor=#000000;gradientColor=none;dashed=0;
verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;
fontSize=12;fontStyle=0;aspect=fixed;fontFamily=Helvetica;
```

### 5.3 コンテナスタイル（GCP）

```xml
<!-- GCP Project -->
<mxCell style="strokeColor=#4285F4;fillColor=#E8F0FE;verticalAlign=top;align=left;spacingLeft=30;dashed=0;rounded=1;arcSize=2;fontFamily=Helvetica;fontStyle=1;fontSize=13;" />

<!-- VPC Network -->
<mxCell style="strokeColor=#34A853;fillColor=#E6F4EA;verticalAlign=top;align=left;spacingLeft=30;dashed=1;rounded=1;arcSize=2;fontFamily=Helvetica;" />

<!-- Subnet -->
<mxCell style="strokeColor=#FBBC04;fillColor=#FEF9E7;verticalAlign=top;align=left;spacingLeft=30;dashed=0;rounded=1;arcSize=5;fontFamily=Helvetica;" />
```

---

## 6. XML テンプレート

### 6.1 基本構造

```xml
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
  tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1"
  pageWidth="1169" pageHeight="827" math="0" shadow="0"
  defaultFontFamily="Helvetica">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />

    <!-- ここに図の要素を記述 -->

  </root>
</mxGraphModel>
```

### 6.2 AWS 3層構成（ALB → ECS → RDS）の最小テンプレート

```xml
<mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
  tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1"
  pageWidth="1169" pageHeight="827" math="0" shadow="0"
  defaultFontFamily="Helvetica">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />

    <!-- 矢印を先に定義 -->
    <mxCell id="edge_alb_ecs" value="" style="endArrow=block;endFill=1;strokeColor=#232F3E;fontFamily=Helvetica;" edge="1" source="alb" target="ecs" parent="vpc">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="edge_ecs_rds" value="" style="endArrow=block;endFill=1;strokeColor=#232F3E;fontFamily=Helvetica;" edge="1" source="ecs" target="rds" parent="vpc">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>

    <!-- AWS Cloud -->
    <mxCell id="aws_cloud" value="AWS Cloud" style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_aws_cloud_alt;strokeColor=#232F3E;fillColor=#FFFFFF;verticalAlign=top;align=center;spacingTop=25;dashed=0;fontFamily=Helvetica;fontStyle=1;fontSize=13;" vertex="1" parent="1">
      <mxGeometry x="40" y="40" width="900" height="600" as="geometry" />
    </mxCell>

    <!-- VPC -->
    <mxCell id="vpc" value="VPC (10.0.0.0/16)" style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_vpc;strokeColor=#8C4FFF;fillColor=#F4F0FF;verticalAlign=top;align=center;spacingTop=25;dashed=0;fontFamily=Helvetica;" vertex="1" parent="aws_cloud">
      <mxGeometry x="50" y="80" width="800" height="470" as="geometry" />
    </mxCell>

    <!-- Public Subnet -->
    <mxCell id="pub_subnet" value="Public Subnet" style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_public_subnet;strokeColor=#3F8624;fillColor=#F0FFF0;verticalAlign=top;align=center;spacingTop=25;dashed=0;fontFamily=Helvetica;" vertex="1" parent="vpc">
      <mxGeometry x="40" y="60" width="220" height="180" as="geometry" />
    </mxCell>

    <!-- ALB -->
    <mxCell id="alb" value="ALB" style="outlineConnect=0;fontColor=#232F3E;gradientColor=none;fillColor=#F58534;strokeColor=none;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.application_load_balancer;fontFamily=Helvetica;" vertex="1" parent="pub_subnet">
      <mxGeometry x="80" y="60" width="60" height="60" as="geometry" />
    </mxCell>

    <!-- Private Subnet -->
    <mxCell id="priv_subnet" value="Private Subnet" style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_private_subnet;strokeColor=#147EBA;fillColor=#E6F2F8;verticalAlign=top;align=center;spacingTop=25;dashed=0;fontFamily=Helvetica;" vertex="1" parent="vpc">
      <mxGeometry x="300" y="60" width="220" height="180" as="geometry" />
    </mxCell>

    <!-- ECS -->
    <mxCell id="ecs" value="ECS Service" style="outlineConnect=0;fontColor=#232F3E;gradientColor=none;fillColor=#F58534;strokeColor=none;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.ecs;fontFamily=Helvetica;" vertex="1" parent="priv_subnet">
      <mxGeometry x="80" y="60" width="60" height="60" as="geometry" />
    </mxCell>

    <!-- DB Subnet -->
    <mxCell id="db_subnet" value="DB Subnet" style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_private_subnet;strokeColor=#DD344C;fillColor=#FFF0F0;verticalAlign=top;align=center;spacingTop=25;dashed=0;fontFamily=Helvetica;" vertex="1" parent="vpc">
      <mxGeometry x="560" y="60" width="220" height="180" as="geometry" />
    </mxCell>

    <!-- RDS -->
    <mxCell id="rds" value="RDS (MySQL)" style="outlineConnect=0;fontColor=#232F3E;gradientColor=none;fillColor=#2E73B8;strokeColor=none;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.rds;fontFamily=Helvetica;" vertex="1" parent="db_subnet">
      <mxGeometry x="80" y="60" width="60" height="60" as="geometry" />
    </mxCell>

  </root>
</mxGraphModel>
```

---

## 7. 凡例（Legend）の追加

接続線の種類が複数ある場合、図の右下に凡例を追加する。

```xml
<!-- 凡例コンテナ -->
<mxCell id="legend" value="Legend" style="text;html=1;strokeColor=#666666;fillColor=#F5F5F5;align=left;verticalAlign=middle;spacingLeft=10;rounded=1;fontSize=13;fontStyle=1;fontFamily=Helvetica;fontColor=#333333;" vertex="1" parent="1">
  <mxGeometry x="980" y="40" width="160" height="120" as="geometry" />
</mxCell>
<!-- 凡例: 同期通信 -->
<mxCell id="legend_sync" value="同期通信" style="endArrow=block;endFill=1;strokeColor=#232F3E;fontFamily=Helvetica;" edge="1" parent="1">
  <mxGeometry x="990" y="70" width="80" height="20" as="geometry">
    <Array as="points" />
  </mxGeometry>
</mxCell>
<!-- 凡例: 非同期通信 -->
<mxCell id="legend_async" value="非同期通信" style="endArrow=block;endFill=1;strokeColor=#232F3E;dashed=1;fontFamily=Helvetica;" edge="1" parent="1">
  <mxGeometry x="990" y="110" width="80" height="20" as="geometry">
    <Array as="points" />
  </mxGeometry>
</mxCell>
```

---

## 8. PNG エクスポート（オプション）

draw.io CLI がインストールされている場合、以下のコマンドで高解像度PNGを生成できる。

```bash
# 高解像度・透明背景でPNG変換
drawio -x -f png -s 2 -t output.drawio
```

---

## 9. Quality Gates（完了前チェック）

以下を全て満たしてから完了報告する。

**必須:**
- [ ] 全アイコンに `fontFamily=Helvetica;` が含まれている
- [ ] 矢印がXML内でノードより前に定義されている
- [ ] 矢印ラベルがある場合、アイコン/ノードと重なっていない
- [ ] コンテナ（VPC/Subnet等）の `parent` 属性が正しく入れ子になっている
- [ ] 日本語ラベルを使う場合、ラベル幅が文字数×30px 以上確保されている
- [ ] `mcp__drawio__open_drawio_xml` でエラーなく表示できた（MCP利用時）

**推奨:**
- [ ] 接続線の種類が2つ以上ある場合、凡例（Legend）を追加している
- [ ] 図のタイトル・作成日などのメタデータが含まれている
- [ ] 全コンテナに `value`（ラベル）が設定されている

---

## 10. よくある失敗パターンと対策

| 失敗 | 原因 | 対策 |
|---|---|---|
| フォントが反映されない | `mxGraphModel` 属性のみ設定 | 各 `mxCell` の `style` に `fontFamily=Helvetica;` を追加 |
| 矢印がアイコンの上に重なる | EdgeがVertexの後に定義 | EdgeをXML先頭に移動 |
| テキストが改行される | ラベル幅が不足 | `width` を拡張 or `noLabel=0;overflow=visible;` を追加 |
| 壊れたアイコンが表示される | 存在しない `shape` 名 | draw.io 標準ライブラリのスタイルを使用 |
| parent の指定ミス | 入れ子が崩れる | 必ず親コンテナの `id` を `parent` に指定 |
| 矢印が親コンテナ外に出る | `parent` を誤った要素に設定 | Edgeの `parent` は共通祖先のコンテナ（通常 `"1"`）に設定 |
