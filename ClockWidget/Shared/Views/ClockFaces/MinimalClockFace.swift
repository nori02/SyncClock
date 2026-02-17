import SwiftUI

/// ミニマルスタイル文字盤 — Bauhaus / MUJI 風のシンプルなデザイン
/// 12・3・6・9 のみショートバー、他は何もなし
struct MinimalClockFace: View {
    let size: CGFloat
    let indexColor: Color
    let isDarkMode: Bool

    private var radius: CGFloat { size / 2 }
    private var outerRadius: CGFloat { radius * 0.90 }

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            for i in [0, 3, 6, 9] {
                let angle = Angle.degrees(Double(i) * 30.0 - 90)
                let isTwelve = i == 0

                let barLength: CGFloat = isTwelve ? radius * 0.18 : radius * 0.13
                let barWidth: CGFloat = isTwelve ? radius * 0.065 : radius * 0.048

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

// MARK: - Minimal Clock Hands

struct MinimalClockHands {
    static func hourHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        var path = Path()
        let width = length * 0.09

        let tipPoint = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )

        let perpendicular = Angle(degrees: angle.degrees + 90)
        let dx = width / 2 * cos(CGFloat(perpendicular.radians))
        let dy = width / 2 * sin(CGFloat(perpendicular.radians))

        path.move(to: CGPoint(x: tipPoint.x + dx * 0.3, y: tipPoint.y + dy * 0.3))
        path.addLine(to: CGPoint(x: tipPoint.x - dx * 0.3, y: tipPoint.y - dy * 0.3))
        path.addLine(to: CGPoint(x: center.x - dx, y: center.y - dy))
        path.addLine(to: CGPoint(x: center.x + dx, y: center.y + dy))
        path.closeSubpath()

        return path
    }

    static func minuteHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        var path = Path()
        let width = length * 0.055

        let tipPoint = CGPoint(
            x: center.x + length * cos(CGFloat(angle.radians)),
            y: center.y + length * sin(CGFloat(angle.radians))
        )

        let perpendicular = Angle(degrees: angle.degrees + 90)
        let dx = width / 2 * cos(CGFloat(perpendicular.radians))
        let dy = width / 2 * sin(CGFloat(perpendicular.radians))

        path.move(to: CGPoint(x: tipPoint.x + dx * 0.2, y: tipPoint.y + dy * 0.2))
        path.addLine(to: CGPoint(x: tipPoint.x - dx * 0.2, y: tipPoint.y - dy * 0.2))
        path.addLine(to: CGPoint(x: center.x - dx, y: center.y - dy))
        path.addLine(to: CGPoint(x: center.x + dx, y: center.y + dy))
        path.closeSubpath()

        return path
    }
}
