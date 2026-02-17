import SwiftUI

/// プリセット壁紙の定義（コード生成のみ、画像ファイル不要）
enum PresetWallpaper: String, CaseIterable, Identifiable, Codable {

    // グラデーション系
    case midnightBlue
    case sunset
    case aurora
    case lavender
    case rosegold

    // テクスチャ系
    case darkWood
    case marble
    case carbon

    // パターン系
    case circlePattern
    case diagonalStripes
    case dotGrid
    case meshGradient

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .midnightBlue:    return "ミッドナイト"
        case .sunset:          return "サンセット"
        case .aurora:          return "オーロラ"
        case .lavender:        return "ラベンダー"
        case .rosegold:        return "ローズゴールド"
        case .darkWood:        return "ダークウッド"
        case .marble:          return "マーブル"
        case .carbon:          return "カーボン"
        case .circlePattern:   return "サークル"
        case .diagonalStripes: return "ストライプ"
        case .dotGrid:         return "ドットグリッド"
        case .meshGradient:    return "メッシュ"
        }
    }
}

// MARK: - View Generation

extension PresetWallpaper {

    /// プリセットに応じた背景ビューを返す
    @ViewBuilder
    func makeView() -> some View {
        switch self {
        // ── Gradients ──────────────────────────────
        case .midnightBlue:
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.05, blue: 0.20),
                    Color(red: 0.05, green: 0.12, blue: 0.35),
                    Color(red: 0.08, green: 0.08, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .sunset:
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.55, blue: 0.20),
                    Color(red: 0.90, green: 0.30, blue: 0.35),
                    Color(red: 0.55, green: 0.15, blue: 0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

        case .aurora:
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.10, blue: 0.15),
                    Color(red: 0.10, green: 0.55, blue: 0.45),
                    Color(red: 0.15, green: 0.35, blue: 0.65),
                    Color(red: 0.05, green: 0.10, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .lavender:
            LinearGradient(
                colors: [
                    Color(red: 0.80, green: 0.72, blue: 0.90),
                    Color(red: 0.65, green: 0.55, blue: 0.82),
                    Color(red: 0.50, green: 0.40, blue: 0.70)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

        case .rosegold:
            LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.78, blue: 0.72),
                    Color(red: 0.85, green: 0.62, blue: 0.58),
                    Color(red: 0.72, green: 0.48, blue: 0.50)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        // ── Textures ──────────────────────────────
        case .darkWood:
            DarkWoodPattern()

        case .marble:
            MarblePattern()

        case .carbon:
            CarbonPattern()

        // ── Patterns ──────────────────────────────
        case .circlePattern:
            CirclePatternView()

        case .diagonalStripes:
            DiagonalStripesPattern()

        case .dotGrid:
            DotGridPattern()

        case .meshGradient:
            MeshGradientPattern()
        }
    }
}

// MARK: - Texture Views

/// ダークウッド風テクスチャ（水平グレイン）
private struct DarkWoodPattern: View {
    var body: some View {
        Canvas { context, size in
            // ベース
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(red: 0.18, green: 0.12, blue: 0.08))
            )
            // 木目のグレインライン
            let lineCount = Int(size.height / 3)
            for i in 0..<lineCount {
                let y = CGFloat(i) * 3.0
                let wobble = sin(Double(i) * 0.3) * 2.0
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y + wobble))
                for x in stride(from: 0, to: size.width, by: 4) {
                    let yOffset = y + sin(Double(x) * 0.02 + Double(i) * 0.5) * 1.5 + wobble
                    path.addLine(to: CGPoint(x: x, y: yOffset))
                }
                let alpha = 0.08 + sin(Double(i) * 0.15) * 0.05
                context.stroke(
                    path,
                    with: .color(Color(red: 0.30, green: 0.20, blue: 0.12, opacity: alpha)),
                    lineWidth: 1.0
                )
            }
        }
    }
}

/// 大理石風テクスチャ（白系）
private struct MarblePattern: View {
    var body: some View {
        Canvas { context, size in
            // 白ベース
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(red: 0.94, green: 0.93, blue: 0.91))
            )
            // 大理石の筋模様
            let veins = 8
            for v in 0..<veins {
                var path = Path()
                let startY = size.height * CGFloat(v) / CGFloat(veins)
                    + size.height * 0.05 * sin(Double(v) * 1.2)
                path.move(to: CGPoint(x: 0, y: startY))
                for x in stride(from: 0, to: size.width, by: 2) {
                    let y = startY
                        + sin(Double(x) * 0.015 + Double(v) * 0.8) * size.height * 0.08
                        + cos(Double(x) * 0.008 + Double(v)) * size.height * 0.04
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                context.stroke(
                    path,
                    with: .color(Color(red: 0.72, green: 0.70, blue: 0.68, opacity: 0.25)),
                    lineWidth: CGFloat(1.5 + sin(Double(v)) * 0.8)
                )
            }
        }
    }
}

/// カーボンファイバー風テクスチャ
private struct CarbonPattern: View {
    var body: some View {
        Canvas { context, size in
            // 黒ベース
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(red: 0.10, green: 0.10, blue: 0.12))
            )
            // 格子パターン
            let cellSize: CGFloat = 6
            let cols = Int(size.width / cellSize) + 1
            let rows = Int(size.height / cellSize) + 1
            for row in 0..<rows {
                for col in 0..<cols {
                    let x = CGFloat(col) * cellSize
                    let y = CGFloat(row) * cellSize
                    let isOdd = (row + col) % 2 == 0
                    let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                    context.fill(
                        Path(rect),
                        with: .color(Color(
                            red: isOdd ? 0.14 : 0.10,
                            green: isOdd ? 0.14 : 0.10,
                            blue: isOdd ? 0.16 : 0.12
                        ))
                    )
                }
            }
        }
    }
}

// MARK: - Pattern Views

/// 同心円パターン
private struct CirclePatternView: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let maxRadius = max(size.width, size.height) * 0.8

            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(red: 0.08, green: 0.10, blue: 0.18))
            )

            let ringCount = 12
            for i in 0..<ringCount {
                let radius = maxRadius * CGFloat(i + 1) / CGFloat(ringCount)
                var path = Path()
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .zero,
                    endAngle: .degrees(360),
                    clockwise: false
                )
                let alpha = 0.15 - Double(i) * 0.008
                context.stroke(
                    path,
                    with: .color(Color(red: 0.35, green: 0.55, blue: 0.80, opacity: max(alpha, 0.03))),
                    lineWidth: 1.5
                )
            }
        }
    }
}

/// 斜線パターン
private struct DiagonalStripesPattern: View {
    var body: some View {
        Canvas { context, size in
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(red: 0.12, green: 0.12, blue: 0.14))
            )

            let spacing: CGFloat = 8
            let totalLength = size.width + size.height
            let count = Int(totalLength / spacing)
            for i in 0..<count {
                let offset = CGFloat(i) * spacing
                var path = Path()
                path.move(to: CGPoint(x: offset, y: 0))
                path.addLine(to: CGPoint(x: offset - size.height, y: size.height))
                context.stroke(
                    path,
                    with: .color(Color(red: 0.22, green: 0.22, blue: 0.26, opacity: 0.6)),
                    lineWidth: 1.0
                )
            }
        }
    }
}

/// ドットグリッドパターン
private struct DotGridPattern: View {
    var body: some View {
        Canvas { context, size in
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(red: 0.95, green: 0.94, blue: 0.92))
            )

            let spacing: CGFloat = 12
            let dotRadius: CGFloat = 1.5
            let cols = Int(size.width / spacing) + 1
            let rows = Int(size.height / spacing) + 1
            for row in 0..<rows {
                for col in 0..<cols {
                    let x = CGFloat(col) * spacing + spacing / 2
                    let y = CGFloat(row) * spacing + spacing / 2
                    let rect = CGRect(
                        x: x - dotRadius,
                        y: y - dotRadius,
                        width: dotRadius * 2,
                        height: dotRadius * 2
                    )
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(Color(red: 0.65, green: 0.62, blue: 0.60, opacity: 0.45))
                    )
                }
            }
        }
    }
}

/// iOS 18 風メッシュグラデーション
private struct MeshGradientPattern: View {
    var body: some View {
        if #available(iOS 18.0, *) {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    Color(red: 0.15, green: 0.10, blue: 0.45),
                    Color(red: 0.30, green: 0.20, blue: 0.60),
                    Color(red: 0.55, green: 0.15, blue: 0.50),
                    Color(red: 0.20, green: 0.35, blue: 0.55),
                    Color(red: 0.40, green: 0.30, blue: 0.65),
                    Color(red: 0.60, green: 0.25, blue: 0.45),
                    Color(red: 0.10, green: 0.20, blue: 0.40),
                    Color(red: 0.25, green: 0.15, blue: 0.55),
                    Color(red: 0.45, green: 0.20, blue: 0.50)
                ]
            )
        } else {
            // iOS 17 フォールバック: AngularGradient で近似
            AngularGradient(
                colors: [
                    Color(red: 0.15, green: 0.10, blue: 0.45),
                    Color(red: 0.55, green: 0.15, blue: 0.50),
                    Color(red: 0.40, green: 0.30, blue: 0.65),
                    Color(red: 0.10, green: 0.20, blue: 0.40),
                    Color(red: 0.15, green: 0.10, blue: 0.45)
                ],
                center: .center
            )
        }
    }
}
