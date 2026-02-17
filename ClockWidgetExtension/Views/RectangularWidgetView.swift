import SwiftUI
import WidgetKit

/// ロック画面用 Rectangular ウィジェット — 左にアナログ時計、右にデジタル表示
struct RectangularWidgetView: View {
    let entry: ClockTimelineEntry

    var body: some View {
        HStack(spacing: 8) {
            // 左: ミニアナログ時計
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                let radius = min(canvasSize.width, canvasSize.height) / 2

                drawCompactClock(context: context, center: center, radius: radius)
            }
            .frame(width: 44, height: 44)

            // 右: デジタル表示
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date, style: .time)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)

                Text(entry.date, style: .date)
                    .font(.system(.caption2, design: .rounded))
                    .opacity(0.7)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Current time: \(entry.date, style: .time)"))
    }

    // MARK: - Compact Clock Drawing

    private func drawCompactClock(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // 外枠の円
        let circleRect = CGRect(
            x: center.x - radius * 0.9,
            y: center.y - radius * 0.9,
            width: radius * 1.8,
            height: radius * 1.8
        )
        context.stroke(
            Path(ellipseIn: circleRect),
            with: .foreground,
            lineWidth: 1.2
        )

        // 12, 3, 6, 9 のインデックス
        let markerAngles: [Double] = [0, 90, 180, 270]
        let outerR = radius * 0.85
        let innerR = radius * 0.68

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
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
            )
        }

        // 時計の針
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: entry.date)
        let minute = calendar.component(.minute, from: entry.date)

        let hourAngle = Angle.degrees(Double(hour % 12) * 30.0 + Double(minute) / 2.0 - 90)
        let minuteAngle = Angle.degrees(Double(minute) * 6.0 - 90)

        // 時針
        let hourTip = pointOnCircle(center: center, radius: radius * 0.45, angle: hourAngle)
        var hourPath = Path()
        hourPath.move(to: center)
        hourPath.addLine(to: hourTip)
        context.stroke(
            hourPath,
            with: .foreground,
            style: StrokeStyle(lineWidth: 2.0, lineCap: .round)
        )

        // 分針
        let minuteTip = pointOnCircle(center: center, radius: radius * 0.65, angle: minuteAngle)
        var minutePath = Path()
        minutePath.move(to: center)
        minutePath.addLine(to: minuteTip)
        context.stroke(
            minutePath,
            with: .foreground,
            style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
        )

        // 中心点
        let dotSize: CGFloat = 2.5
        let dotRect = CGRect(
            x: center.x - dotSize / 2,
            y: center.y - dotSize / 2,
            width: dotSize,
            height: dotSize
        )
        context.fill(Path(ellipseIn: dotRect), with: .foreground)
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
    RectangularWidgetView(entry: ClockTimelineEntry(date: .now, settings: .default))
}
