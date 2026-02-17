import SwiftUI

/// クラシックスタイル文字盤 — ローマ数字とエレガントな細い針
struct ClassicClockFace: View {
    let size: CGFloat
    let indexColor: Color
    let isDarkMode: Bool

    private let romanNumerals = [
        "XII", "I", "II", "III", "IV", "V",
        "VI", "VII", "VIII", "IX", "X", "XI"
    ]

    private var radius: CGFloat { size / 2 }
    private var numeralRadius: CGFloat { radius * 0.78 }
    private var minuteMarkerOuterRadius: CGFloat { radius * 0.92 }
    private var minuteMarkerInnerRadius: CGFloat { radius * 0.90 }
    private var fiveMinMarkerInnerRadius: CGFloat { radius * 0.87 }

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            // 60 minute markers
            for i in 0..<60 {
                let angle = Angle.degrees(Double(i) * 6.0 - 90)
                let isFiveMin = i % 5 == 0
                let innerR = isFiveMin ? fiveMinMarkerInnerRadius : minuteMarkerInnerRadius
                let lineWidth: CGFloat = isFiveMin ? 1.4 : 0.6

                let outerPoint = point(from: center, radius: minuteMarkerOuterRadius, angle: angle)
                let innerPoint = point(from: center, radius: innerR, angle: angle)

                var path = Path()
                path.move(to: outerPoint)
                path.addLine(to: innerPoint)

                context.stroke(path, with: .color(indexColor), lineWidth: lineWidth)
            }

            // Roman numerals
            for (index, numeral) in romanNumerals.enumerated() {
                let angle = Angle.degrees(Double(index) * 30.0 - 90)
                let pos = point(from: center, radius: numeralRadius, angle: angle)

                let fontSize = size * 0.075
                let font = Font.system(size: fontSize, design: .serif)
                let text = Text(numeral).font(font).foregroundColor(indexColor)

                context.draw(
                    context.resolve(text),
                    at: pos,
                    anchor: .center
                )
            }
        }
        .frame(width: size, height: size)
    }

    private func point(from center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(CGFloat(angle.radians)),
            y: center.y + radius * sin(CGFloat(angle.radians))
        )
    }
}

// MARK: - Classic Clock Hands

struct ClassicClockHands {
    /// 時針パス — 細めのエレガントなデザイン
    static func hourHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        let width = length * 0.08
        var path = Path()
        let tip = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )
        let perpendicular = Angle(degrees: angle.degrees + 90)
        let left = CGPoint(
            x: center.x + width * cos(CGFloat(perpendicular.radians)),
            y: center.y + width * sin(CGFloat(perpendicular.radians))
        )
        let right = CGPoint(
            x: center.x - width * cos(CGFloat(perpendicular.radians)),
            y: center.y - width * sin(CGFloat(perpendicular.radians))
        )
        let tail = CGPoint(
            x: center.x - length * 0.15 * cos(CGFloat(angle.radians)),
            y: center.y - length * 0.15 * sin(CGFloat(angle.radians))
        )

        path.move(to: tip)
        path.addLine(to: left)
        path.addLine(to: tail)
        path.addLine(to: right)
        path.closeSubpath()
        return path
    }

    /// 分針パス — 細くて長いエレガントなデザイン
    static func minuteHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        let width = length * 0.045
        var path = Path()
        let tip = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )
        let perpendicular = Angle(degrees: angle.degrees + 90)
        let left = CGPoint(
            x: center.x + width * cos(CGFloat(perpendicular.radians)),
            y: center.y + width * sin(CGFloat(perpendicular.radians))
        )
        let right = CGPoint(
            x: center.x - width * cos(CGFloat(perpendicular.radians)),
            y: center.y - width * sin(CGFloat(perpendicular.radians))
        )
        let tail = CGPoint(
            x: center.x - length * 0.18 * cos(CGFloat(angle.radians)),
            y: center.y - length * 0.18 * sin(CGFloat(angle.radians))
        )

        path.move(to: tip)
        path.addLine(to: left)
        path.addLine(to: tail)
        path.addLine(to: right)
        path.closeSubpath()
        return path
    }
}
