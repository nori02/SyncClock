import SwiftUI

/// 写真トリミングUI — ピンチズーム・ドラッグ移動で正方形に切り抜き
struct ImageCropView: View {
    let image: UIImage
    let onCrop: (UIImage) -> Void
    var onCancel: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let outputDimension: CGFloat = 400
    private var cropSize: CGFloat {
        UIScreen.main.bounds.width - 48
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                // クロップエリア
                ZStack {
                    Color.black

                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(dragGesture)
                        .gesture(magnificationGesture)

                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                }
                .frame(width: cropSize, height: cropSize)
                .clipped()

                Text("ピンチで拡大・ドラッグで移動")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.top, 12)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(white: 0.1))
            .navigationTitle("トリミング")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        onCancel?()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        performCrop()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - ジェスチャー

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = lastScale * value.magnification
                scale = min(max(newScale, 0.5), 5.0)
            }
            .onEnded { _ in
                lastScale = scale
            }
    }

    // MARK: - クロップ実行

    private func performCrop() {
        let imageSize = image.size
        let viewAspect = imageSize.width / imageSize.height
        let fitSize: CGSize
        if viewAspect > 1 {
            fitSize = CGSize(width: cropSize, height: cropSize / viewAspect)
        } else {
            fitSize = CGSize(width: cropSize * viewAspect, height: cropSize)
        }

        let scaledImageSize = CGSize(
            width: fitSize.width * scale,
            height: fitSize.height * scale
        )
        let imageOrigin = CGPoint(
            x: (cropSize - scaledImageSize.width) / 2 + offset.width,
            y: (cropSize - scaledImageSize.height) / 2 + offset.height
        )

        let renderScale = outputDimension / cropSize
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let outputSize = CGSize(width: outputDimension, height: outputDimension)
        let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)
        let croppedImage = renderer.image { _ in
            image.draw(in: CGRect(
                x: imageOrigin.x * renderScale,
                y: imageOrigin.y * renderScale,
                width: scaledImageSize.width * renderScale,
                height: scaledImageSize.height * renderScale
            ))
        }

        onCrop(croppedImage)
    }
}
