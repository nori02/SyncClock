import SwiftUI

/// スポーツスタイル文字盤 — アラビア数字、太いインデックス、夜光塗料風配色
struct SportClockFace: View {
    let size: CGFloat
    let indexColor: Color
    let isDarkMode: Bool

    private let arabicNumerals = [
        "12", "1", "2", "3", "4", "5",
        "6", "7", "8", "9", "10", "11"
    ]

    private var radius: CGFloat { size / 2 }
    private var outerRadius: CGFloat { radius * 0.94 }
    private var minuteTrackOuterRadius: CGFloat { radius * 0.98 }
    private var minuteTrackInnerRadius: CGFloat { radius * 0.94 }
    private var numeralRadius: CGFloat { radius * 0.73 }
    private var hourMarkerOuterRadius: CGFloat { radius * 0.92 }
    private var hourMarkerInnerRadius: CGFloat { radius * 0.86 }

    /// 夜光塗料風のアクセントカラー（テーマの indexColor をそのまま使用）
    private var lumeColor: Color { indexColor }

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            // Outer minute track
            drawMinuteTrack(context: context, center: center)

            // Hour markers (thick bars)
            drawHourMarkers(context: context, center: center)

            // Arabic numerals
            drawNumerals(context: context, center: center)
        }
        .frame(width: size, height: size)
    }

    private func drawMinuteTrack(context: GraphicsContext, center: CGPoint) {
        for i in 0..<60 {
            let angle = Angle.degrees(Double(i) * 6.0 - 90)
            let isFiveMin = i % 5 == 0

            let outerR = minuteTrackOuterRadius
            let innerR = isFiveMin ? minuteTrackInnerRadius - radius * 0.02 : minuteTrackInnerRadius
            let lineWidth: CGFloat = isFiveMin ? 1.8 : 0.7

            let outerPoint = point(from: center, radius: outerR, angle: angle)
            let innerPoint = point(from: center, radius: innerR, angle: angle)

            var path = Path()
            path.move(to: outerPoint)
            path.addLine(to: innerPoint)

            let color = isFiveMin ? lumeColor : indexColor.opacity(0.5)
            context.stroke(path, with: .color(color), lineWidth: lineWidth)
        }
    }

    private func drawHourMarkers(context: GraphicsContext, center: CGPoint) {
        for i in 0..<12 {
            let angle = Angle.degrees(Double(i) * 30.0 - 90)

            let outerPoint = point(from: center, radius: hourMarkerOuterRadius, angle: angle)
            let innerPoint = point(from: center, radius: hourMarkerInnerRadius, angle: angle)

            var path = Path()
            path.move(to: outerPoint)
            path.addLine(to: innerPoint)

            let lineWidth: CGFloat = i % 3 == 0 ? radius * 0.028 : radius * 0.018
            context.stroke(
                path,
                with: .color(lumeColor),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
            )
        }
    }

    private func drawNumerals(context: GraphicsContext, center: CGPoint) {
        for (index, numeral) in arabicNumerals.enumerated() {
            let angle = Angle.degrees(Double(index) * 30.0 - 90)
            let pos = point(from: center, radius: numeralRadius, angle: angle)

            let fontSize = size * 0.09
            let font = Font.system(size: fontSize, weight: .bold, design: .rounded)
            let text = Text(numeral).font(font).foregroundColor(lumeColor)

            context.draw(
                context.resolve(text),
                at: pos,
                anchor: .center
            )
        }
    }

    private func point(from center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(CGFloat(angle.radians)),
            y: center.y + radius * sin(CGFloat(angle.radians))
        )
    }
}

// MARK: - Sport Clock Hands

struct SportClockHands {
    /// 時針パス — 太く視認性が高い
    static func hourHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        let width = length * 0.12
        let tipWidth = length * 0.06
        var path = Path()

        let perpendicular = Angle(degrees: angle.degrees + 90)
        let tipPoint = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )
        let tailPoint = CGPoint(
            x: center.x - length * 0.18 * cos(CGFloat(angle.radians)),
            y: center.y - length * 0.18 * sin(CGFloat(angle.radians))
        )

        let dx = cos(CGFloat(perpendicular.radians))
        let dy = sin(CGFloat(perpendicular.radians))

        path.move(to: CGPoint(x: tipPoint.x + tipWidth / 2 * dx, y: tipPoint.y + tipWidth / 2 * dy))
        path.addLine(to: CGPoint(x: tipPoint.x - tipWidth / 2 * dx, y: tipPoint.y - tipWidth / 2 * dy))
        path.addLine(to: CGPoint(x: tailPoint.x - width / 2 * dx, y: tailPoint.y - width / 2 * dy))
        path.addLine(to: CGPoint(x: tailPoint.x + width / 2 * dx, y: tailPoint.y + width / 2 * dy))
        path.closeSubpath()

        return path
    }

    /// 分針パス — やや太めだが時針より細い
    static func minuteHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        let width = length * 0.07
        let tipWidth = length * 0.035
        var path = Path()

        let perpendicular = Angle(degrees: angle.degrees + 90)
        let tipPoint = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )
        let tailPoint = CGPoint(
            x: center.x - length * 0.2 * cos(CGFloat(angle.radians)),
            y: center.y - length * 0.2 * sin(CGFloat(angle.radians))
        )

        let dx = cos(CGFloat(perpendicular.radians))
        let dy = sin(CGFloat(perpendicular.radians))

        path.move(to: CGPoint(x: tipPoint.x + tipWidth / 2 * dx, y: tipPoint.y + tipWidth / 2 * dy))
        path.addLine(to: CGPoint(x: tipPoint.x - tipWidth / 2 * dx, y: tipPoint.y - tipWidth / 2 * dy))
        path.addLine(to: CGPoint(x: tailPoint.x - width / 2 * dx, y: tailPoint.y - width / 2 * dy))
        path.addLine(to: CGPoint(x: tailPoint.x + width / 2 * dx, y: tailPoint.y + width / 2 * dy))
        path.closeSubpath()

        return path
    }
}
