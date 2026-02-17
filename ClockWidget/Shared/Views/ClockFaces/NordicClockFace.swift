import SwiftUI

/// ノルディックスタイル文字盤 — Arne Jacobsen / 北欧インテリア風
/// 12時のみ三角マーカー、他は均一な矩形バー、数字なし
struct NordicClockFace: View {
    let size: CGFloat
    let indexColor: Color
    let isDarkMode: Bool

    private var radius: CGFloat { size / 2 }
    private var outerRadius: CGFloat { radius * 0.92 }

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            for i in 0..<12 {
                let angle = Angle.degrees(Double(i) * 30.0 - 90)

                if i == 0 {
                    drawTriangle(context: context, center: center, angle: angle)
                } else {
                    let barLength: CGFloat = radius * 0.13
                    let barWidth: CGFloat = radius * 0.04

                    let outerPoint = point(from: center, radius: outerRadius, angle: angle)
                    let innerPoint = point(from: center, radius: outerRadius - barLength, angle: angle)

                    var path = Path()
                    path.move(to: outerPoint)
                    path.addLine(to: innerPoint)

                    context.stroke(
                        path,
                        with: .color(indexColor),
                        style: StrokeStyle(lineWidth: barWidth, lineCap: .butt)
                    )
                }
            }
        }
        .frame(width: size, height: size)
    }

    private func drawTriangle(context: GraphicsContext, center: CGPoint, angle: Angle) {
        let triHeight = radius * 0.16
        let triWidth = radius * 0.12

        let tipPoint = point(from: center, radius: outerRadius, angle: angle)
        let baseCenter = point(from: center, radius: outerRadius - triHeight, angle: angle)

        let perpAngle = Angle(degrees: angle.degrees + 90)
        let dx = triWidth / 2 * cos(CGFloat(perpAngle.radians))
        let dy = triWidth / 2 * sin(CGFloat(perpAngle.radians))

        var path = Path()
        path.move(to: tipPoint)
        path.addLine(to: CGPoint(x: baseCenter.x + dx, y: baseCenter.y + dy))
        path.addLine(to: CGPoint(x: baseCenter.x - dx, y: baseCenter.y - dy))
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

// MARK: - Nordic Clock Hands

struct NordicClockHands {
    static func hourHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        var path = Path()
        let width = length * 0.10
        let tailLength = length * 0.08

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

        path.move(to: CGPoint(x: tipPoint.x + dx, y: tipPoint.y + dy))
        path.addLine(to: CGPoint(x: tipPoint.x - dx, y: tipPoint.y - dy))
        path.addLine(to: CGPoint(x: tailPoint.x - dx, y: tailPoint.y - dy))
        path.addLine(to: CGPoint(x: tailPoint.x + dx, y: tailPoint.y + dy))
        path.closeSubpath()

        return path
    }

    static func minuteHandPath(center: CGPoint, length: CGFloat, angle: Angle) -> Path {
        var path = Path()
        let width = length * 0.065
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

        path.move(to: CGPoint(x: tipPoint.x + dx, y: tipPoint.y + dy))
        path.addLine(to: CGPoint(x: tipPoint.x - dx, y: tipPoint.y - dy))
        path.addLine(to: CGPoint(x: tailPoint.x - dx, y: tailPoint.y - dy))
        path.addLine(to: CGPoint(x: tailPoint.x + dx, y: tailPoint.y + dy))
        path.closeSubpath()

        return path
    }
}
