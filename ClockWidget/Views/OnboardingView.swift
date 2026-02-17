import SwiftUI

/// 初回起動時に壁紙設定を促すオンボーディング画面
struct OnboardingView: View {
    let onStart: () -> Void
    let onSkip: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // アイコン
                Image(systemName: "clock.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.bottom, 20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                // タイトル
                Text("Sync Clock")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                // サブタイトル
                Text("時間ごとに壁紙が変わる\nアナログ時計ウィジェット")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                // 機能説明
                VStack(alignment: .leading, spacing: 20) {
                    featureRow(
                        icon: "photo.on.rectangle.angled",
                        title: "24時間分の壁紙",
                        description: "時間帯ごとに異なる写真を設定できます"
                    )
                    featureRow(
                        icon: "paintpalette",
                        title: "6種類のスタイル",
                        description: "ミニマルからクラシックまで選べます"
                    )
                    featureRow(
                        icon: "square.grid.2x2",
                        title: "ホーム画面ウィジェット",
                        description: "設定した時計をウィジェットとして表示"
                    )
                }
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)

                Spacer()

                // CTAボタン
                Button(action: onStart) {
                    Text("壁紙を設定する")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 12)
                .opacity(appeared ? 1 : 0)

                // スキップ
                Button(action: onSkip) {
                    Text("あとで設定する")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.bottom, 40)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(0.1)) {
                appeared = true
            }
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}
