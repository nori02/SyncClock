import SwiftUI

struct CodableColor: Codable, Equatable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(_ color: Color) {
        let resolved = UIColor(color)
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r); self.green = Double(g); self.blue = Double(b); self.alpha = Double(a)
    }

    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        switch hexSanitized.count {
        case 6:
            self.red = Double((rgb & 0xFF0000) >> 16) / 255.0
            self.green = Double((rgb & 0x00FF00) >> 8) / 255.0
            self.blue = Double(rgb & 0x0000FF) / 255.0
            self.alpha = 1.0
        case 8:
            self.red = Double((rgb & 0xFF000000) >> 24) / 255.0
            self.green = Double((rgb & 0x00FF0000) >> 16) / 255.0
            self.blue = Double((rgb & 0x0000FF00) >> 8) / 255.0
            self.alpha = Double(rgb & 0x000000FF) / 255.0
        default: return nil
        }
    }

    var color: Color { Color(red: red, green: green, blue: blue, opacity: alpha) }

    var hexString: String {
        let r = Int(red * 255); let g = Int(green * 255); let b = Int(blue * 255)
        if alpha < 1.0 { return String(format: "#%02X%02X%02X%02X", r, g, b, Int(alpha * 255)) }
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension CodableColor {
    static let defaultHourHand = CodableColor(red: 1.0, green: 1.0, blue: 1.0)
    static let defaultMinuteHand = CodableColor(red: 1.0, green: 1.0, blue: 1.0)
    static let defaultSecondHand = CodableColor(red: 1.0, green: 1.0, blue: 1.0)
    static let defaultIndex = CodableColor(red: 1.0, green: 1.0, blue: 1.0)
    static let defaultFaceBackground = CodableColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15)
    static let darkHourHand = CodableColor(red: 0.95, green: 0.95, blue: 0.95)
    static let darkMinuteHand = CodableColor(red: 0.85, green: 0.85, blue: 0.85)
    static let darkSecondHand = CodableColor(red: 1.0, green: 0.3, blue: 0.3)
    static let darkIndex = CodableColor(red: 0.95, green: 0.95, blue: 0.95)
    static let darkFaceBackground = CodableColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.15)
}

extension Color {
    init(_ codableColor: CodableColor) {
        self.init(red: codableColor.red, green: codableColor.green, blue: codableColor.blue, opacity: codableColor.alpha)
    }
}
