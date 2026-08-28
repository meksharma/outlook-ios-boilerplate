import ImageIO
import SwiftUI
import UIKit

struct AnimatedGIFView: UIViewRepresentable {
    let assetName: String
    let size: CGSize

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        guard let asset = NSDataAsset(name: assetName),
              let image = UIImage.animatedGIF(data: asset.data)
        else {
            assertionFailure("Unable to load animated GIF asset: \(assetName)")
            return imageView
        }

        imageView.image = image
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {}

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UIImageView,
        context: Context
    ) -> CGSize? {
        size
    }
}

private extension UIImage {
    static func animatedGIF(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        var frames: [UIImage] = []
        var duration: TimeInterval = 0

        for index in 0..<CGImageSourceGetCount(source) {
            guard let image = CGImageSourceCreateImageAtIndex(source, index, nil) else {
                return nil
            }

            guard let transparentImage = image.removingWhiteBackground() else {
                return nil
            }

            frames.append(UIImage(cgImage: transparentImage))
            duration += frameDuration(source: source, index: index)
        }

        guard !frames.isEmpty else {
            return nil
        }

        return UIImage.animatedImage(
            with: frames,
            duration: max(duration, 0.1)
        )
    }

    static func frameDuration(
        source: CGImageSource,
        index: Int
    ) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(
            source,
            index,
            nil
        ) as? [CFString: Any],
            let gifProperties = properties[kCGImagePropertyGIFDictionary]
                as? [CFString: Any]
        else {
            return 0.1
        }

        let unclampedDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime]
            as? TimeInterval
        let delay = gifProperties[kCGImagePropertyGIFDelayTime]
            as? TimeInterval
        return max(unclampedDelay ?? delay ?? 0.1, 0.02)
    }
}

private extension CGImage {
    func removingWhiteBackground() -> CGImage? {
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixels = [UInt8](
            repeating: 0,
            count: height * bytesPerRow
        )
        let pixelCount = pixels.count

        return pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return nil
            }

            context.draw(
                self,
                in: CGRect(x: 0, y: 0, width: width, height: height)
            )

            let bytes = buffer.bindMemory(to: UInt8.self)
            for offset in stride(
                from: 0,
                to: pixelCount,
                by: bytesPerPixel
            ) {
                let red = bytes[offset]
                let green = bytes[offset + 1]
                let blue = bytes[offset + 2]

                if red >= 240, green >= 240, blue >= 240 {
                    bytes[offset] = 0
                    bytes[offset + 1] = 0
                    bytes[offset + 2] = 0
                    bytes[offset + 3] = 0
                }
            }

            return context.makeImage()
        }
    }
}
