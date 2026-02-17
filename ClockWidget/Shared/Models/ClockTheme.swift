import SwiftUI

/// Face Style + Wallpaper + Hand Colors をセットにしたテーマ
struct ClockTheme: Identifiable {
    let id: String
    let displayName: String
    let faceStyle: ClockFaceStyle
    let wallpaper: WallpaperConfig
    let hourHandColor: CodableColor
    let minuteHandColor: CodableColor
    let secondHandColor: CodableColor
    let indexColor: CodableColor
    let showNumbers: Bool

    /// テーマを ClockSettings に変換（壁紙を全24時間に適用）
    func toSettings(keepSecondHand: Bool = true) -> ClockSettings {
        ClockSettings(
            faceStyle: faceStyle,
            hourlyWallpapers: Array(repeating: wallpaper, count: 24),
            hourHandColor: hourHandColor,
            minuteHandColor: minuteHandColor,
            secondHandColor: secondHandColor,
            indexColor: indexColor,
            showNumbers: showNumbers,
            showSecondHand: keepSecondHand
        )
    }
}

// MARK: - Curated Themes

extension ClockTheme {
    static let allThemes: [ClockTheme] = [
        // Classic
        classicMarble,
        classicMidnight,
        classicRoseGold,
        // Modern
        modernDark,
        modernAurora,
        modernLavender,
        // Sport
        sportCarbon,
        sportSunset,
        sportMesh,
        // Minimal
        minimalMuji,
        minimalNoir,
        minimalSand,
        // Elegant
        elegantGold,
        elegantObsidian,
        elegantIvory,
        // Nordic
        nordicFrost,
        nordicAsh,
        nordicTwilight,
    ]

    // ── Classic ──────────────────────────────

    /// クラシック × マーブル — 白系エレガント
    static let classicMarble = ClockTheme(
        id: "classic_marble",
        displayName: "Marble",
        faceStyle: .classic,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.marble.rawValue),
        hourHandColor: CodableColor(red: 0.15, green: 0.12, blue: 0.10),
        minuteHandColor: CodableColor(red: 0.25, green: 0.22, blue: 0.20),
        secondHandColor: CodableColor(red: 0.72, green: 0.20, blue: 0.15),
        indexColor: CodableColor(red: 0.20, green: 0.18, blue: 0.15),
        showNumbers: true
    )

    /// クラシック × ミッドナイトブルー — 深い青
    static let classicMidnight = ClockTheme(
        id: "classic_midnight",
        displayName: "Midnight",
        faceStyle: .classic,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.midnightBlue.rawValue),
        hourHandColor: CodableColor(red: 0.85, green: 0.82, blue: 0.75),
        minuteHandColor: CodableColor(red: 0.75, green: 0.72, blue: 0.65),
        secondHandColor: CodableColor(red: 0.90, green: 0.35, blue: 0.25),
        indexColor: CodableColor(red: 0.80, green: 0.78, blue: 0.70),
        showNumbers: true
    )

    /// クラシック × ローズゴールド — 暖色エレガント
    static let classicRoseGold = ClockTheme(
        id: "classic_rosegold",
        displayName: "Rose Gold",
        faceStyle: .classic,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.rosegold.rawValue),
        hourHandColor: CodableColor(red: 0.45, green: 0.25, blue: 0.22),
        minuteHandColor: CodableColor(red: 0.55, green: 0.35, blue: 0.30),
        secondHandColor: CodableColor(red: 0.80, green: 0.25, blue: 0.20),
        indexColor: CodableColor(red: 0.40, green: 0.22, blue: 0.20),
        showNumbers: true
    )

    // ── Modern ──────────────────────────────

    /// モダン × カーボン — ダークミニマル
    static let modernDark = ClockTheme(
        id: "modern_dark",
        displayName: "Carbon",
        faceStyle: .modern,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.carbon.rawValue),
        hourHandColor: CodableColor(red: 0.90, green: 0.90, blue: 0.92),
        minuteHandColor: CodableColor(red: 0.75, green: 0.75, blue: 0.78),
        secondHandColor: CodableColor(red: 0.20, green: 0.65, blue: 0.95),
        indexColor: CodableColor(red: 0.85, green: 0.85, blue: 0.88),
        showNumbers: false
    )

    /// モダン × オーロラ — 神秘的な緑青
    static let modernAurora = ClockTheme(
        id: "modern_aurora",
        displayName: "Aurora",
        faceStyle: .modern,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.aurora.rawValue),
        hourHandColor: CodableColor(red: 0.88, green: 0.95, blue: 0.90),
        minuteHandColor: CodableColor(red: 0.72, green: 0.85, blue: 0.78),
        secondHandColor: CodableColor(red: 0.40, green: 0.90, blue: 0.70),
        indexColor: CodableColor(red: 0.82, green: 0.92, blue: 0.85),
        showNumbers: false
    )

    /// モダン × ラベンダー — やわらかいパープル
    static let modernLavender = ClockTheme(
        id: "modern_lavender",
        displayName: "Lavender",
        faceStyle: .modern,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.lavender.rawValue),
        hourHandColor: CodableColor(red: 0.95, green: 0.95, blue: 1.0),
        minuteHandColor: CodableColor(red: 0.82, green: 0.80, blue: 0.90),
        secondHandColor: CodableColor(red: 0.65, green: 0.40, blue: 0.85),
        indexColor: CodableColor(red: 0.95, green: 0.93, blue: 1.0),
        showNumbers: false
    )

    // ── Sport ──────────────────────────────

    /// スポーツ × カーボン — タフ＆夜光風
    static let sportCarbon = ClockTheme(
        id: "sport_carbon",
        displayName: "Tactical",
        faceStyle: .sport,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.carbon.rawValue),
        hourHandColor: CodableColor(red: 0.90, green: 0.92, blue: 0.88),
        minuteHandColor: CodableColor(red: 0.78, green: 0.80, blue: 0.75),
        secondHandColor: CodableColor(red: 0.95, green: 0.30, blue: 0.15),
        indexColor: CodableColor(red: 0.75, green: 0.95, blue: 0.65),
        showNumbers: true
    )

    /// スポーツ × サンセット — 暖色スポーティ
    static let sportSunset = ClockTheme(
        id: "sport_sunset",
        displayName: "Sunset",
        faceStyle: .sport,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.sunset.rawValue),
        hourHandColor: CodableColor(red: 1.0, green: 0.95, blue: 0.88),
        minuteHandColor: CodableColor(red: 0.95, green: 0.85, blue: 0.75),
        secondHandColor: CodableColor(red: 1.0, green: 0.85, blue: 0.30),
        indexColor: CodableColor(red: 1.0, green: 0.95, blue: 0.85),
        showNumbers: true
    )

    /// スポーツ × メッシュ — サイバー風
    static let sportMesh = ClockTheme(
        id: "sport_mesh",
        displayName: "Cyber",
        faceStyle: .sport,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.meshGradient.rawValue),
        hourHandColor: CodableColor(red: 0.92, green: 0.92, blue: 0.95),
        minuteHandColor: CodableColor(red: 0.78, green: 0.78, blue: 0.85),
        secondHandColor: CodableColor(red: 0.95, green: 0.25, blue: 0.55),
        indexColor: CodableColor(red: 0.90, green: 0.88, blue: 0.95),
        showNumbers: true
    )

    // ── Minimal ──────────────────────────────

    /// ミニマル × マーブル — MUJI風の白い静けさ
    static let minimalMuji = ClockTheme(
        id: "minimal_muji",
        displayName: "MUJI",
        faceStyle: .minimal,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.marble.rawValue),
        hourHandColor: CodableColor(red: 0.20, green: 0.20, blue: 0.22),
        minuteHandColor: CodableColor(red: 0.30, green: 0.30, blue: 0.32),
        secondHandColor: CodableColor(red: 0.85, green: 0.25, blue: 0.20),
        indexColor: CodableColor(red: 0.25, green: 0.25, blue: 0.28),
        showNumbers: false
    )

    /// ミニマル × カーボン — ダークミニマル
    static let minimalNoir = ClockTheme(
        id: "minimal_noir",
        displayName: "Noir",
        faceStyle: .minimal,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.carbon.rawValue),
        hourHandColor: CodableColor(red: 0.92, green: 0.92, blue: 0.90),
        minuteHandColor: CodableColor(red: 0.75, green: 0.75, blue: 0.73),
        secondHandColor: CodableColor(red: 0.95, green: 0.60, blue: 0.20),
        indexColor: CodableColor(red: 0.88, green: 0.88, blue: 0.86),
        showNumbers: false
    )

    /// ミニマル × ドットグリッド — 白×ベージュのナチュラル
    static let minimalSand = ClockTheme(
        id: "minimal_sand",
        displayName: "Sand",
        faceStyle: .minimal,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.dotGrid.rawValue),
        hourHandColor: CodableColor(red: 0.35, green: 0.30, blue: 0.25),
        minuteHandColor: CodableColor(red: 0.50, green: 0.45, blue: 0.40),
        secondHandColor: CodableColor(red: 0.75, green: 0.35, blue: 0.20),
        indexColor: CodableColor(red: 0.40, green: 0.35, blue: 0.30),
        showNumbers: false
    )

    // ── Elegant ──────────────────────────────

    /// エレガント × ローズゴールド — ゴールドアクセント
    static let elegantGold = ClockTheme(
        id: "elegant_gold",
        displayName: "Gold",
        faceStyle: .elegant,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.rosegold.rawValue),
        hourHandColor: CodableColor(red: 0.72, green: 0.58, blue: 0.38),
        minuteHandColor: CodableColor(red: 0.62, green: 0.50, blue: 0.32),
        secondHandColor: CodableColor(red: 0.80, green: 0.30, blue: 0.25),
        indexColor: CodableColor(red: 0.68, green: 0.55, blue: 0.35),
        showNumbers: false
    )

    /// エレガント × ミッドナイト — 深い青にシルバー
    static let elegantObsidian = ClockTheme(
        id: "elegant_obsidian",
        displayName: "Obsidian",
        faceStyle: .elegant,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.midnightBlue.rawValue),
        hourHandColor: CodableColor(red: 0.82, green: 0.85, blue: 0.90),
        minuteHandColor: CodableColor(red: 0.68, green: 0.72, blue: 0.78),
        secondHandColor: CodableColor(red: 0.30, green: 0.70, blue: 0.95),
        indexColor: CodableColor(red: 0.78, green: 0.82, blue: 0.88),
        showNumbers: false
    )

    /// エレガント × マーブル — アイボリー＆ブロンズ
    static let elegantIvory = ClockTheme(
        id: "elegant_ivory",
        displayName: "Ivory",
        faceStyle: .elegant,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.marble.rawValue),
        hourHandColor: CodableColor(red: 0.45, green: 0.35, blue: 0.25),
        minuteHandColor: CodableColor(red: 0.55, green: 0.45, blue: 0.35),
        secondHandColor: CodableColor(red: 0.70, green: 0.22, blue: 0.18),
        indexColor: CodableColor(red: 0.50, green: 0.40, blue: 0.30),
        showNumbers: false
    )

    // ── Nordic ──────────────────────────────

    /// ノルディック × マーブル — フロスト（白×グレー）
    static let nordicFrost = ClockTheme(
        id: "nordic_frost",
        displayName: "Frost",
        faceStyle: .nordic,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.marble.rawValue),
        hourHandColor: CodableColor(red: 0.18, green: 0.20, blue: 0.25),
        minuteHandColor: CodableColor(red: 0.30, green: 0.32, blue: 0.38),
        secondHandColor: CodableColor(red: 0.85, green: 0.30, blue: 0.22),
        indexColor: CodableColor(red: 0.22, green: 0.24, blue: 0.30),
        showNumbers: false
    )

    /// ノルディック × ダークウッド — アッシュ（温かみのあるダーク）
    static let nordicAsh = ClockTheme(
        id: "nordic_ash",
        displayName: "Ash",
        faceStyle: .nordic,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.darkWood.rawValue),
        hourHandColor: CodableColor(red: 0.90, green: 0.88, blue: 0.82),
        minuteHandColor: CodableColor(red: 0.78, green: 0.75, blue: 0.70),
        secondHandColor: CodableColor(red: 0.95, green: 0.55, blue: 0.25),
        indexColor: CodableColor(red: 0.88, green: 0.85, blue: 0.78),
        showNumbers: false
    )

    /// ノルディック × ラベンダー — トワイライト（夕暮れの北欧）
    static let nordicTwilight = ClockTheme(
        id: "nordic_twilight",
        displayName: "Twilight",
        faceStyle: .nordic,
        wallpaper: WallpaperConfig(type: .preset, presetId: PresetWallpaper.lavender.rawValue),
        hourHandColor: CodableColor(red: 0.95, green: 0.95, blue: 1.0),
        minuteHandColor: CodableColor(red: 0.85, green: 0.82, blue: 0.92),
        secondHandColor: CodableColor(red: 0.90, green: 0.45, blue: 0.65),
        indexColor: CodableColor(red: 0.95, green: 0.93, blue: 1.0),
        showNumbers: false
    )
}
