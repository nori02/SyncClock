import SwiftUI
import WidgetKit

/// ロック画面用 Circular ウィジェット — 小さな丸形のアナログ時計
struct CircularWidgetView: View {
    let entry: ClockTimelineEntry

    var body: some View {
        ZStack {
            // 背景の円
            AccessoryWidgetBackground()

            // シンプル化されたアナログ時計
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                let radius = min(canvasSize.width, canvasSize.height) / 2

                // インデックス（12, 3, 6, 9 のみ）
                drawMinimalIndices(context: context, center: center, radius: radius)

                // 時計の針
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: entry.date)
                let minute = calendar.component(.minute, from: entry.date)

                let hourAngle = Angle.degrees(Double(hour % 12) * 30.0 + Double(minute) / 2.0 - 90)
                let minuteAngle = Angle.degrees(Double(minute) * 6.0 - 90)

                // 時針
                drawHand(
                    context: context,
                    center: center,
                    length: radius * 0.5,
                    width: radius * 0.08,
                    angle: hourAngle
                )

                // 分針
                drawHand(
                    context: context,
                    center: center,
                    length: radius * 0.72,
                    width: radius * 0.05,
                    angle: minuteAngle
                )

                // 中心点
                let dotSize = radius * 0.08
                let dotRect = CGRect(
                    x: center.x - dotSize / 2,
                    y: center.y - dotSize / 2,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(Path(ellipseIn: dotRect), with: .foreground)
            }
            .padding(4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Current time: \(entry.date, style: .time)"))
    }

    // MARK: - Drawing Helpers

    private func drawMinimalIndices(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let markerAngles: [Double] = [0, 90, 180, 270] // 12, 3, 6, 9
        let outerR = radius * 0.88
        let innerR = radius * 0.72

        for angleDeg in markerAngles {
            let angle = Angle.degrees(angleDeg - 90)
            let outer = pointOnCircle(center: center, radius: outerR, angle: angle)
            let inner = pointOnCircle(center: center, radius: innerR, angle: angle)

            var path = Path()
            path.move(to: outer)
            path.addLine(to: inner)

            context.stroke(
                path,
                with: .foreground,
                style: StrokeStyle(lineWidth: radius * 0.04, lineCap: .round)
            )
        }
    }

    private func drawHand(
        context: GraphicsContext,
        center: CGPoint,
        length: CGFloat,
        width: CGFloat,
        angle: Angle
    ) {
        let tip = pointOnCircle(center: center, radius: length, angle: angle)

        var path = Path()
        path.move(to: center)
        path.addLine(to: tip)

        context.stroke(
            path,
            with: .foreground,
            style: StrokeStyle(lineWidth: width, lineCap: .round)
        )
    }

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(CGFloat(angle.radians)),
            y: center.y + radius * sin(CGFloat(angle.radians))
        )
    }
}

// MARK: - Preview

#Preview {
    CircularWidgetView(entry: ClockTimelineEntry(date: .now, settings: .default))
}
