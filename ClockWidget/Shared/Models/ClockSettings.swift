import Foundation

/// アナログ時計の全体設定
struct ClockSettings: Codable, Equatable {
    var faceStyle: ClockFaceStyle
    var hourlyWallpapers: [WallpaperConfig]
    var hourHandColor: CodableColor
    var minuteHandColor: CodableColor
    var secondHandColor: CodableColor
    var indexColor: CodableColor
    var showNumbers: Bool
    var showSecondHand: Bool

    // MARK: - Computed (現在時刻の壁紙 — 後方互換)

    /// 現在時刻の壁紙を返す
    var wallpaper: WallpaperConfig {
        get {
            let hour = Calendar.current.component(.hour, from: Date())
            return wallpaper(forHour: hour)
        }
        set {
            let hour = Calendar.current.component(.hour, from: Date())
            setWallpaper(newValue, forHour: hour)
        }
    }

    // MARK: - Hourly Accessors

    /// 指定時刻(0–23)の壁紙を返す
    func wallpaper(forHour hour: Int) -> WallpaperConfig {
        let index = max(0, min(23, hour))
        guard hourlyWallpapers.indices.contains(index) else { return .default }
        return hourlyWallpapers[index]
    }

    /// 指定時刻(0–23)の壁紙を設定
    mutating func setWallpaper(_ config: WallpaperConfig, forHour hour: Int) {
        let index = max(0, min(23, hour))
        guard hourlyWallpapers.indices.contains(index) else { return }
        hourlyWallpapers[index] = config
    }

    /// 使用中の全写真ファイル名
    var allPhotoFileNames: Set<String> {
        Set(hourlyWallpapers.compactMap { $0.photoFileName })
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case faceStyle, wallpaper, hourlyWallpapers
        case hourHandColor, minuteHandColor, secondHandColor
        case indexColor, showNumbers, showSecondHand
    }

    init(
        faceStyle: ClockFaceStyle,
        hourlyWallpapers: [WallpaperConfig],
        hourHandColor: CodableColor,
        minuteHandColor: CodableColor,
        secondHandColor: CodableColor,
        indexColor: CodableColor,
        showNumbers: Bool,
        showSecondHand: Bool
    ) {
        self.faceStyle = faceStyle
        self.hourlyWallpapers = hourlyWallpapers
        self.hourHandColor = hourHandColor
        self.minuteHandColor = minuteHandColor
        self.secondHandColor = secondHandColor
        self.indexColor = indexColor
        self.showNumbers = showNumbers
        self.showSecondHand = showSecondHand
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        faceStyle = try container.decode(ClockFaceStyle.self, forKey: .faceStyle)
        hourHandColor = try container.decode(CodableColor.self, forKey: .hourHandColor)
        minuteHandColor = try container.decode(CodableColor.self, forKey: .minuteHandColor)
        secondHandColor = try container.decode(CodableColor.self, forKey: .secondHandColor)
        indexColor = try container.decode(CodableColor.self, forKey: .indexColor)
        showNumbers = try container.decode(Bool.self, forKey: .showNumbers)
        showSecondHand = try container.decode(Bool.self, forKey: .showSecondHand)

        if let wallpapers = try? container.decode([WallpaperConfig].self, forKey: .hourlyWallpapers),
           wallpapers.count == 24 {
            hourlyWallpapers = wallpapers
        } else if let single = try? container.decode(WallpaperConfig.self, forKey: .wallpaper) {
            hourlyWallpapers = Array(repeating: single, count: 24)
        } else {
            hourlyWallpapers = Array(repeating: .default, count: 24)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(faceStyle, forKey: .faceStyle)
        try container.encode(hourlyWallpapers, forKey: .hourlyWallpapers)
        try container.encode(hourHandColor, forKey: .hourHandColor)
        try container.encode(minuteHandColor, forKey: .minuteHandColor)
        try container.encode(secondHandColor, forKey: .secondHandColor)
        try container.encode(indexColor, forKey: .indexColor)
        try container.encode(showNumbers, forKey: .showNumbers)
        try container.encode(showSecondHand, forKey: .showSecondHand)
        let hour = Calendar.current.component(.hour, from: Date())
        try container.encode(wallpaper(forHour: hour), forKey: .wallpaper)
    }

    // MARK: - Default

    static var `default`: ClockSettings {
        let defaultWallpaper = WallpaperConfig(type: .userPhoto)
        return ClockSettings(
            faceStyle: .minimal,
            hourlyWallpapers: Array(repeating: defaultWallpaper, count: 24),
            hourHandColor: CodableColor(red: 1.0, green: 1.0, blue: 1.0),
            minuteHandColor: CodableColor(red: 1.0, green: 1.0, blue: 1.0),
            secondHandColor: CodableColor(red: 1.0, green: 1.0, blue: 1.0),
            indexColor: CodableColor(red: 1.0, green: 1.0, blue: 1.0),
            showNumbers: true,
            showSecondHand: true
        )
    }
}
