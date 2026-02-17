import SwiftUI

/// エレガントスタイル文字盤 — ダイヤモンド型マーカーとリーフ型の針
/// ラグジュアリーホテルのロビー時計を想起させるデザイン
struct ElegantClockFace: View {
    let size: CGFloat
    let indexColor: Color
    let isDarkMode: Bool

    private var radius: CGFloat { size / 2 }
    private var outerRadius: CGFloat { radius * 0.91 }

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            for i in 0..<12 {
                let angle = Angle.degrees(Double(i) * 30.0 - 90)
                let isQuarter = i % 3 == 0

                if isQuarter {
                    // ダイヤモンド型マーカー（12, 3, 6, 9）
                    drawDiamond(context: context, center: center, angle: angle,
                                radius: outerRadius, size: i == 0 ? radius * 0.045 : radius * 0.033)
                } else {
                    // 細いドットマーカー
                    let dotCenter = point(from: center, radius: outerRadius - radius * 0.02, angle: angle)
                    let dotRadius: CGFloat = radius * 0.009

                    var dotPath = Path()
                    dotPath.addEllipse(in: CGRect(
                        x: dotCenter.x - dotRadius,
                        y: dotCenter.y - dotRadius,
                        width: dotRadius * 2,
                        height: dotRadius * 2
                    ))
                    context.fill(dotPath, with: .color(indexColor.opacity(0.7)))
                }
            }

            // 内側の細い装飾リング
            let innerRingRadius = radius * 0.82
            var ringPath = Path()
            ringPath.addEllipse(in: CGRect(
                x: center.x - innerRingRadius,
                y: center.y - innerRingRadius,
                width: innerRingRadius * 2,
                height: innerRingRadius * 2
            ))
            context.stroke(ringPath, with: .color(indexColor.opacity(0.08)),
                          style: StrokeStyle(lineWidth: 0.5))
        }
        .frame(width: size, height: size)
    }

    private func drawDiamond(context: GraphicsContext, center: CGPoint,
                              angle: Angle, radius: CGFloat, size diamondSize: CGFloat) {
        let markerCenter = point(from: center, radius: radius - diamondSize, angle: angle)

        let radialAngle = angle
        let perpAngle = Angle(degrees: angle.degrees + 90)

        let top = CGPoint(
            x: markerCenter.x + diamondSize * cos(CGFloat(radialAngle.radians)),
            y: markerCenter.y + diamondSize * sin(CGFloat(radialAngle.radians))
        )
        let bottom = CGPoint(
            x: markerCenter.x - diamondSize * cos(CGFloat(radialAngle.radians)),
            y: markerCenter.y - diamondSize * sin(CGFloat(radialAngle.radians))
        )
        let left = CGPoint(
            x: markerCenter.x + diamondSize * 0.45 * cos(CGFloat(perpAngle.radians)),
            y: markerCenter.y + diamondSize * 0.45 * sin(CGFloat(perpAngle.radians))
        )
        let right = CGPoint(
            x: markerCenter.x - diamondSize * 0.45 * cos(CGFloat(perpAngle.radians)),
            y: markerCenter.y - diamondSize * 0.45 * sin(CGFloat(perpAngle.radians))
        )

        var path = Path()
        path.move(to: top)
        path.addLine(to: left)
        path.addLine(to: bottom)
        path.addLine(to: right)
        path.closeSubpath()

        context.fill(path, with: .color(indexColor))
    }

    private func point(from center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(CGFloat(angle.radians)),
            y: center.y + radius * sin(CGFloat(angle.radians))
        )
    }
}

// MARK: - Elegant Clock Hands

struct ElegantClockHands {
    /// 時針パス — リーフ型（中央が膨らむ優雅なシルエット）
    static func hourHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        let maxWidth = length * 0.09
        var path = Path()

        let tipPoint = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )
        let tailPoint = CGPoint(
            x: center.x - length * 0.12 * cos(CGFloat(angle.radians)),
            y: center.y - length * 0.12 * sin(CGFloat(angle.radians))
        )

        let perpendicular = Angle(degrees: angle.degrees + 90)
        let dx = cos(CGFloat(perpendicular.radians))
        let dy = sin(CGFloat(perpendicular.radians))

        // 中間点（最大幅の位置）
        let midPoint = CGPoint(
            x: center.x + length * 0.35 * cos(CGFloat(angle.radians)),
            y: center.y + length * 0.35 * sin(CGFloat(angle.radians))
        )

        // リーフ型カーブ
        path.move(to: tipPoint)
        path.addQuadCurve(
            to: tailPoint,
            control: CGPoint(x: midPoint.x + maxWidth * dx, y: midPoint.y + maxWidth * dy)
        )
        path.addQuadCurve(
            to: tipPoint,
            control: CGPoint(x: midPoint.x - maxWidth * dx, y: midPoint.y - maxWidth * dy)
        )
        path.closeSubpath()

        return path
    }

    /// 分針パス — 細いリーフ型
    static func minuteHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        let maxWidth = length * 0.05
        var path = Path()

        let tipPoint = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )
        let tailPoint = CGPoint(
            x: center.x - length * 0.15 * cos(CGFloat(angle.radians)),
            y: center.y - length * 0.15 * sin(CGFloat(angle.radians))
        )

        let perpendicular = Angle(degrees: angle.degrees + 90)
        let dx = cos(CGFloat(perpendicular.radians))
        let dy = sin(CGFloat(perpendicular.radians))

        let midPoint = CGPoint(
            x: center.x + length * 0.3 * cos(CGFloat(angle.radians)),
            y: center.y + length * 0.3 * sin(CGFloat(angle.radians))
        )

        path.move(to: tipPoint)
        path.addQuadCurve(
            to: tailPoint,
            control: CGPoint(x: midPoint.x + maxWidth * dx, y: midPoint.y + maxWidth * dy)
        )
        path.addQuadCurve(
            to: tipPoint,
            control: CGPoint(x: midPoint.x - maxWidth * dx, y: midPoint.y - maxWidth * dy)
        )
        path.closeSubpath()

        return path
    }
}
