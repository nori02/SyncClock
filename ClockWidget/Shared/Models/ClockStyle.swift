import Foundation

enum ClockFaceStyle: String, Codable, CaseIterable, Identifiable {
    case classic
    case modern
    case sport
    case minimal
    case elegant
    case nordic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "クラシック"
        case .modern:  return "モダン"
        case .sport:   return "スポーツ"
        case .minimal: return "ミニマル"
        case .elegant: return "エレガント"
        case .nordic:  return "ノルディック"
        }
    }

    var description: String {
        switch self {
        case .classic: return "ローマ数字の文字盤"
        case .modern:  return "ミニマルなバーインデックス"
        case .sport:   return "太く視認性の高いデザイン"
        case .minimal: return "究極にシンプルなデザイン"
        case .elegant: return "洗練されたラグジュアリーデザイン"
        case .nordic:  return "北欧インテリア風デザイン"
        }
    }
}
