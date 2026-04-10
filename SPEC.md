# FidgetKey 仕様

**概要**
テンキーパッドのキー押下中、対応位置に図形表示。離したら消える。

**入力**
- 対象：Keychron K0 Max 拡張キーパッド全キー
- `keyDown` → 表示
- `keyUp` → 消去
- 同時押し対応

**表示**
- 図形：数字キーは `fillEllipse`、それ以外は `fillRect`（角丸）
- 色：キーごとに固定色
- アニメーションなし
- 背景：`NSColor.windowBackgroundColor`

**レイアウト（4列×6行）**

```
[Home] [End ] [PgUp] [PgDn]   // 行0
[NmLk] [ / ] [ * ]  [ - ]     // 行1
[ 7 ]  [ 8 ] [ 9 ]            // 行2
[ 4 ]  [ 5 ] [ 6 ]  [  +  ]  // 行3（+は行3-4結合）
[ 1 ]  [ 2 ] [ 3 ]            // 行4
[   0   ]    [ . ] [Enter]    // 行5（0は列0-1結合、Enterは行4-5結合）
```

**配色**

| キー | 色 |
|------|----|
| Home / End / PgUp / PgDn | systemBlue |
| NmLk | systemPurple |
| / · * · - | systemOrange |
| + | systemRed |
| 0–9 | systemGreen |
| Enter | systemYellow |
| . | systemTeal |

**環境**
- macOS 14.0+
- AppKit（`NSView` + `drawRect`）
- Xcode 16+
