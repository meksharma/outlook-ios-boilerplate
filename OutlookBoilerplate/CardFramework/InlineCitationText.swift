import OutlookBackdrop
import SwiftUI
import UIKit

struct InlineCitationText: UIViewRepresentable {
    let text: String
    let referenceCount: Int
    let tint: Color
    let onOpen: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onOpen: onOpen)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = true
        textView.linkTextAttributes = [:]
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.onOpen = onOpen
        textView.attributedText = attributedText()
        textView.accessibilityLabel = text
        textView.accessibilityHint = "Opens \(referenceCount) summary source\(referenceCount == 1 ? "" : "s")"
        textView.invalidateIntrinsicContentSize()
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UITextView,
        context: Context
    ) -> CGSize? {
        guard let width = proposal.width else {
            return nil
        }

        let size = uiView.sizeThatFits(
            CGSize(width: width, height: .greatestFiniteMagnitude)
        )
        return CGSize(width: width, height: ceil(size.height))
    }

    private func attributedText() -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 15, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 20
        paragraphStyle.maximumLineHeight = 20
        paragraphStyle.lineBreakMode = .byWordWrapping

        let result = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: UIColor(Color.odsNeutralForeground1),
                .kern: -0.23,
                .paragraphStyle: paragraphStyle
            ]
        )
        result.append(
            NSAttributedString(
                string: " ",
                attributes: [.font: font]
            )
        )

        let attachment = NSTextAttachment()
        attachment.image = citationImage()
        attachment.bounds = CGRect(
            x: 0,
            y: round((font.capHeight - 20) / 2),
            width: citationWidth,
            height: 20
        )

        let attachmentString = NSMutableAttributedString(
            attachment: attachment
        )
        attachmentString.addAttribute(
            .link,
            value: "outlook-citation://sources",
            range: NSRange(location: 0, length: attachmentString.length)
        )
        result.append(attachmentString)
        return result
    }

    private var citationWidth: CGFloat {
        referenceCount > 1 ? 42 : 28
    }

    private func citationImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: citationWidth, height: 20)
        )

        return renderer.image { _ in
            UIImage(.mail16Regular)?
                .withTintColor(
                    UIColor(tint),
                    renderingMode: .alwaysOriginal
                )
                .draw(in: CGRect(x: 8, y: 5, width: 12, height: 10))

            guard referenceCount > 1 else {
                return
            }

            let font = UIFont.systemFont(ofSize: 9, weight: .regular)
            let label = "+\(referenceCount - 1)" as NSString
            label.draw(
                at: CGPoint(
                    x: 24,
                    y: round((20 - font.lineHeight) / 2)
                ),
                withAttributes: [
                    .font: font,
                    .foregroundColor: UIColor(tint)
                ]
            )
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var onOpen: () -> Void

        init(onOpen: @escaping () -> Void) {
            self.onOpen = onOpen
        }

        func textView(
            _ textView: UITextView,
            primaryActionFor textItem: UITextItem,
            defaultAction: UIAction
        ) -> UIAction? {
            guard case let .link(url) = textItem.content,
                  url.scheme == "outlook-citation"
            else {
                return defaultAction
            }

            return UIAction { [weak self] _ in
                self?.onOpen()
            }
        }
    }
}
