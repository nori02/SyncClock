import SwiftUI

/// 時計の針を描画するビュー
struct ClockHandsView: View {
    let date: Date
    let settings: ClockSettings
    let size: CGFloat
    /// 秒針表示（メインアプリプレビュー用。ウィジェットでは false）
    var showSecondHand: Bool = false

    private var radius: CGFloat { size / 2 }
    private var center: CGPoint { CGPoint(x: size / 2, y: size / 2) }

    // MARK: - Angle Calculations

    private var calendar: Calendar { Calendar.current }

    private var hour: Int { calendar.component(.hour, from: date) }
    private var minute: Int { calendar.component(.minute, from: date) }
    private var second: Int { calendar.component(.second, from: date) }

    /// 時針角度: 12時間で360度 + 分による微調整（12時=上=−90°）
    private var hourAngle: Angle {
        let degrees = (Double(hour % 12) / 12.0 + Double(minute) / 720.0) * 360.0 - 90.0
        return .degrees(degrees)
    }

    /// 分針角度: 60分で360度
    private var minuteAngle: Angle {
        let degrees = Double(minute) / 60.0 * 360.0 - 90.0
        return .degrees(degrees)
    }

    /// 秒針角度
    private var secondAngle: Angle {
        let degrees = Double(second) / 60.0 * 360.0 - 90.0
        return .degrees(degrees)
    }

    // MARK: - Hand lengths

    private var hourHandLength: CGFloat { radius * 0.52 }
    private var minuteHandLength: CGFloat { radius * 0.75 }
    private var secondHandLength: CGFloat { radius * 0.82 }

    // MARK: - Colors

    private var hourColor: Color { settings.hourHandColor.color }
    private var minuteColor: Color { settings.minuteHandColor.color }
    private var secondColor: Color { settings.secondHandColor.color }

    // MARK: - Body

    var body: some View {
        Canvas { context, canvasSize in
            let c = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            // Hour hand（影 + ハイライトエッジ）
            let hourPath = handPath(for: .hour, center: c)
            context.drawLayer { handCtx in
                handCtx.addFilter(.shadow(color: .black.opacity(0.55), radius: 3.5, x: 0, y: 2))
                handCtx.fill(hourPath, with: .color(hourColor))
            }
            // 時針のエッジハイライト
            context.stroke(hourPath, with: .color(.white.opacity(0.18)), lineWidth: 0.7)

            // Minute hand（影 + ハイライトエッジ）
            let minutePath = handPath(for: .minute, center: c)
            context.drawLayer { handCtx in
                handCtx.addFilter(.shadow(color: .black.opacity(0.55), radius: 3, x: 0, y: 1.5))
                handCtx.fill(minutePath, with: .color(minuteColor))
            }
            context.stroke(minutePath, with: .color(.white.opacity(0.18)), lineWidth: 0.7)

            // Second hand (app preview only)
            if showSecondHand && settings.showSecondHand {
                context.drawLayer { secCtx in
                    secCtx.addFilter(.shadow(color: .black.opacity(0.5), radius: 2.5, x: 0, y: 1))
                    drawSecondHand(context: secCtx, center: c)
                }
            }

            // Center pivot（影付きで立体感）
            let pivotRadius = radius * 0.04
            let pivotRect = CGRect(
                x: c.x - pivotRadius,
                y: c.y - pivotRadius,
                width: pivotRadius * 2,
                height: pivotRadius * 2
            )
            context.drawLayer { pivotCtx in
                pivotCtx.addFilter(.shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 1.5))
                var pivotPath = Path()
                pivotPath.addEllipse(in: pivotRect)
                pivotCtx.fill(pivotPath, with: .color(hourColor))
            }

            // Highlight on pivot（ハイライト）
            let highlightRadius = pivotRadius * 0.55
            let highlightRect = CGRect(
                x: c.x - highlightRadius,
                y: c.y - highlightRadius - pivotRadius * 0.15,
                width: highlightRadius * 2,
                height: highlightRadius * 2
            )
            var highlightPath = Path()
            highlightPath.addEllipse(in: highlightRect)
            context.fill(highlightPath, with: .color(.white.opacity(0.35)))

            // Small inner circle on pivot
            let innerPivotRadius = pivotRadius * 0.35
            let innerRect = CGRect(
                x: c.x - innerPivotRadius,
                y: c.y - innerPivotRadius,
                width: innerPivotRadius * 2,
                height: innerPivotRadius * 2
            )
            var innerPivotPath = Path()
            innerPivotPath.addEllipse(in: innerRect)
            context.fill(innerPivotPath, with: .color(secondColor))
        }
        .frame(width: size, height: size)
    }

    // MARK: - Hand Path Dispatch

    private enum HandType {
        case hour, minute
    }

    private func handPath(for type: HandType, center c: CGPoint) -> Path {
        let length: CGFloat
        let angle: Angle

        switch type {
        case .hour:
            length = hourHandLength
            angle = hourAngle
        case .minute:
            length = minuteHandLength
            angle = minuteAngle
        }

        switch settings.faceStyle {
        case .classic:
            return type == .hour
                ? ClassicClockHands.hourHandPath(center: c, length: length, angle: angle)
                : ClassicClockHands.minuteHandPath(center: c, length: length, angle: angle)
        case .modern:
            return type == .hour
                ? ModernClockHands.hourHandPath(center: c, length: length, angle: angle)
                : ModernClockHands.minuteHandPath(center: c, length: length, angle: angle)
        case .sport:
            return type == .hour
                ? SportClockHands.hourHandPath(center: c, length: length, angle: angle)
                : SportClockHands.minuteHandPath(center: c, length: length, angle: angle)
        case .minimal:
            return type == .hour
                ? MinimalClockHands.hourHandPath(center: c, length: length, angle: angle)
                : MinimalClockHands.minuteHandPath(center: c, length: length, angle: angle)
        case .elegant:
            return type == .hour
                ? ElegantClockHands.hourHandPath(center: c, length: length, angle: angle)
                : ElegantClockHands.minuteHandPath(center: c, length: length, angle: angle)
        case .nordic:
            return type == .hour
                ? NordicClockHands.hourHandPath(center: c, length: length, angle: angle)
                : NordicClockHands.minuteHandPath(center: c, length: length, angle: angle)
        }
    }

    // MARK: - Second Hand

    private func drawSecondHand(context: GraphicsContext, center c: CGPoint) {
        let tipPoint = CGPoint(
            x: c.x + secondHandLength * cos(CGFloat(secondAngle.radians)),
            y: c.y + secondHandLength * sin(CGFloat(secondAngle.radians))
        )
        let tailLength = radius * 0.22
        let tailPoint = CGPoint(
            x: c.x - tailLength * cos(CGFloat(secondAngle.radians)),
            y: c.y - tailLength * sin(CGFloat(secondAngle.radians))
        )

        var path = Path()
        path.move(to: tailPoint)
        path.addLine(to: tipPoint)

        context.stroke(
            path,
            with: .color(secondColor),
            style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
        )

        // Second hand circle at tip
        let circleRadius = radius * 0.035
        var circle = Path()
        circle.addEllipse(in: CGRect(
            x: tipPoint.x - circleRadius,
            y: tipPoint.y - circleRadius,
            width: circleRadius * 2,
            height: circleRadius * 2
        ))
        context.fill(circle, with: .color(secondColor))
    }
}
