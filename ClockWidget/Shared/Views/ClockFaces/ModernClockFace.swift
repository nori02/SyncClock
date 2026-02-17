import SwiftUI

/// モダンスタイル文字盤 — ミニマルバーインデックス、数字なし
struct ModernClockFace: View {
    let size: CGFloat
    let indexColor: Color
    let isDarkMode: Bool

    private var radius: CGFloat { size / 2 }
    private var outerRadius: CGFloat { radius * 0.92 }

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            for i in 0..<60 {
                let angle = Angle.degrees(Double(i) * 6.0 - 90)
                let isHour = i % 5 == 0

                if isHour {
                    let isTwelve = i == 0
                    let isQuarter = i % 15 == 0 && !isTwelve

                    let barLength: CGFloat
                    let barWidth: CGFloat

                    if isTwelve {
                        barLength = radius * 0.20
                        barWidth = radius * 0.065
                    } else if isQuarter {
                        barLength = radius * 0.15
                        barWidth = radius * 0.05
                    } else {
                        barLength = radius * 0.11
                        barWidth = radius * 0.035
                    }

                    let outerPoint = point(from: center, radius: outerRadius, angle: angle)
                    let innerPoint = point(from: center, radius: outerRadius - barLength, angle: angle)

                    var path = Path()
                    path.move(to: outerPoint)
                    path.addLine(to: innerPoint)

                    context.stroke(
                        path,
                        with: .color(indexColor),
                        style: StrokeStyle(lineWidth: barWidth, lineCap: .round)
                    )
                } else {
                    let dotRadius: CGFloat = radius * 0.012
                    let dotCenter = point(from: center, radius: outerRadius - radius * 0.01, angle: angle)

                    var dotPath = Path()
                    dotPath.addEllipse(in: CGRect(
                        x: dotCenter.x - dotRadius,
                        y: dotCenter.y - dotRadius,
                        width: dotRadius * 2,
                        height: dotRadius * 2
                    ))

                    context.fill(dotPath, with: .color(indexColor.opacity(0.3)))
                }
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

// MARK: - Modern Clock Hands

struct ModernClockHands {
    static func hourHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        var path = Path()
        let width = length * 0.10
        let tailLength = length * 0.1

        let tipPoint = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )
        let tailPoint = CGPoint(
            x: center.x - tailLength * cos(CGFloat(angle.radians)),
            y: center.y - tailLength * sin(CGFloat(angle.radians))
        )

        let perpendicular = Angle(degrees: angle.degrees + 90)
        let dx = width / 2 * cos(CGFloat(perpendicular.radians))
        let dy = width / 2 * sin(CGFloat(perpendicular.radians))

        path.move(to: CGPoint(x: tipPoint.x + dx * 0.3, y: tipPoint.y + dy * 0.3))
        path.addLine(to: CGPoint(x: tipPoint.x - dx * 0.3, y: tipPoint.y - dy * 0.3))
        path.addLine(to: CGPoint(x: tailPoint.x - dx, y: tailPoint.y - dy))
        path.addLine(to: CGPoint(x: tailPoint.x + dx, y: tailPoint.y + dy))
        path.closeSubpath()

        return path
    }

    static func minuteHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        var path = Path()
        let width = length * 0.065
        let tailLength = length * 0.12

        let tipPoint = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )
        let tailPoint = CGPoint(
            x: center.x - tailLength * cos(CGFloat(angle.radians)),
            y: center.y - tailLength * sin(CGFloat(angle.radians))
        )

        let perpendicular = Angle(degrees: angle.degrees + 90)
        let dx = width / 2 * cos(CGFloat(perpendicular.radians))
        let dy = width / 2 * sin(CGFloat(perpendicular.radians))

        path.move(to: CGPoint(x: tipPoint.x + dx * 0.2, y: tipPoint.y + dy * 0.2))
        path.addLine(to: CGPoint(x: tipPoint.x - dx * 0.2, y: tipPoint.y - dy * 0.2))
        path.addLine(to: CGPoint(x: tailPoint.x - dx, y: tailPoint.y - dy))
        path.addLine(to: CGPoint(x: tailPoint.x + dx, y: tailPoint.y + dy))
        path.closeSubpath()

        return path
    }
}
