import SwiftUI

/// ウィジェット用のアナログ時計ビュー
/// 影・エッジハイライトで写真背景上でも視認性を確保
struct WidgetAnalogClockView: View {
    let date: Date
    let settings: ClockSettings
    let size: CGFloat

    private var calendar: Calendar { Calendar.current }
    private var hour: Int { calendar.component(.hour, from: date) }
    private var minute: Int { calendar.component(.minute, from: date) }

    private var hourAngle: Angle {
        Angle.degrees(Double(hour % 12) * 30.0 + Double(minute) / 2.0 - 90)
    }
    private var minuteAngle: Angle {
        Angle.degrees(Double(minute) * 6.0 - 90)
    }

    private var indexColor: Color { Color(settings.indexColor) }
    private var hourColor: Color { Color(settings.hourHandColor) }
    private var minuteColor: Color { Color(settings.minuteHandColor) }

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let radius = min(canvasSize.width, canvasSize.height) / 2

            let vignetteRect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )

            // アウターリング（影付き）
            context.drawLayer { ringCtx in
                ringCtx.addFilter(.shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1))
                ringCtx.stroke(
                    Path(ellipseIn: vignetteRect),
                    with: .color(indexColor.opacity(0.25)),
                    lineWidth: radius * 0.01
                )
            }

            // インデックス（影付き）
            context.drawLayer { idxCtx in
                idxCtx.addFilter(.shadow(color: .black.opacity(0.5), radius: 1.5, x: 0, y: 1))
                drawIndices(context: idxCtx, center: center, radius: radius)
            }

            // 数字（showNumbers有効時、影付き）
            if settings.showNumbers {
                context.drawLayer { numCtx in
                    numCtx.addFilter(.shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1))
                    drawNumbers(context: numCtx, center: center, radius: radius)
                }
            }

            // 時針（影 + エッジハイライト）
            let hourHandPath = handPath(
                center: center,
                length: radius * 0.55,
                width: radius * 0.06,
                tailRatio: 0.15,
                angle: hourAngle
            )
            context.drawLayer { handCtx in
                handCtx.addFilter(.shadow(color: .black.opacity(0.55), radius: 3.5, x: 0, y: 2))
                handCtx.fill(hourHandPath, with: .color(hourColor))
            }
            context.stroke(hourHandPath, with: .color(.white.opacity(0.18)), lineWidth: 0.7)

            // 分針（影 + エッジハイライト）
            let minuteHandPath = handPath(
                center: center,
                length: radius * 0.78,
                width: radius * 0.035,
                tailRatio: 0.18,
                angle: minuteAngle
            )
            context.drawLayer { handCtx in
                handCtx.addFilter(.shadow(color: .black.opacity(0.55), radius: 3, x: 0, y: 1.5))
                handCtx.fill(minuteHandPath, with: .color(minuteColor))
            }
            context.stroke(minuteHandPath, with: .color(.white.opacity(0.18)), lineWidth: 0.7)

            // 中心ピボット（影 + ハイライト）
            let dotRadius = radius * 0.04
            let dotRect = CGRect(
                x: center.x - dotRadius,
                y: center.y - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2
            )
            context.drawLayer { pivotCtx in
                pivotCtx.addFilter(.shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 1.5))
                pivotCtx.fill(Path(ellipseIn: dotRect), with: .color(hourColor))
            }

            // ピボットハイライト
            let hlRadius = dotRadius * 0.55
            let hlRect = CGRect(
                x: center.x - hlRadius,
                y: center.y - hlRadius - dotRadius * 0.15,
                width: hlRadius * 2,
                height: hlRadius * 2
            )
            context.fill(Path(ellipseIn: hlRect), with: .color(.white.opacity(0.35)))
        }
        .frame(width: size, height: size)
    }

    // MARK: - Index Drawing

    private func drawIndices(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let outerR = radius * 0.92
        let hourInnerR = radius * 0.82
        let minuteInnerR = radius * 0.88

        for i in 0..<60 {
            let angle = Angle.degrees(Double(i) * 6.0 - 90)
            let isHour = i % 5 == 0
            let innerR = isHour ? hourInnerR : minuteInnerR
            let lineWidth: CGFloat = isHour ? 2.0 : 0.8

            let outer = pointOnCircle(center: center, radius: outerR, angle: angle)
            let inner = pointOnCircle(center: center, radius: innerR, angle: angle)

            var path = Path()
            path.move(to: outer)
            path.addLine(to: inner)

            context.stroke(path, with: .color(indexColor), lineWidth: lineWidth)
        }
    }

    // MARK: - Number Drawing

    private func drawNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let numbers: [String]
        let fontDesign: Font.Design

        switch settings.faceStyle {
        case .classic:
            numbers = ["XII", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI"]
            fontDesign = .serif
        case .sport:
            numbers = ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
            fontDesign = .rounded
        case .modern, .minimal, .elegant, .nordic:
            return
        }

        let numeralRadius = radius * 0.72
        let fontSize = size * 0.075

        for (index, numeral) in numbers.enumerated() {
            let angle = Angle.degrees(Double(index) * 30.0 - 90)
            let pos = pointOnCircle(center: center, radius: numeralRadius, angle: angle)

            let font = Font.system(size: fontSize, design: fontDesign)
            let text = Text(numeral).font(font).foregroundColor(indexColor)

            context.draw(context.resolve(text), at: pos, anchor: .center)
        }
    }

    // MARK: - Hand Path

    private func handPath(
        center: CGPoint,
        length: CGFloat,
        width: CGFloat,
        tailRatio: CGFloat,
        angle: Angle
    ) -> Path {
        let tip = pointOnCircle(center: center, radius: length, angle: angle)
        let tail = CGPoint(
            x: center.x - length * tailRatio * cos(CGFloat(angle.radians)),
            y: center.y - length * tailRatio * sin(CGFloat(angle.radians))
        )

        let perpendicular = Angle(degrees: angle.degrees + 90)
        let dx = width / 2 * cos(CGFloat(perpendicular.radians))
        let dy = width / 2 * sin(CGFloat(perpendicular.radians))

        var path = Path()
        path.move(to: tip)
        path.addLine(to: CGPoint(x: center.x + dx, y: center.y + dy))
        path.addLine(to: tail)
        path.addLine(to: CGPoint(x: center.x - dx, y: center.y - dy))
        path.closeSubpath()
        return path
    }

    // MARK: - Helpers

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(CGFloat(angle.radians)),
            y: center.y + radius * sin(CGFloat(angle.radians))
        )
    }
}
