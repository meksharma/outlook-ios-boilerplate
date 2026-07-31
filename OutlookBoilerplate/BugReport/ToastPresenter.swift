//
//  ToastPresenter.swift
//  OutlookBoilerplate
//
//  UIKit confirmation toast rendered in its OWN dedicated UIWindow at alert
//  level. Using a separate window — rather than adding a subview to the key
//  window — guarantees the toast is visible regardless of what is being
//  presented/dismissed (share sheets, other sheets) at the moment it fires.
//
//  Visual language matches the app's "Mail Sent" banner: a full-width
//  dark-navy rounded bar with light-blue text, sliding up from the bottom.
//

import UIKit

enum ToastPresenter {
    /// Retained for the lifetime of the toast so the window isn't deallocated
    /// mid-animation.
    private static var window: UIWindow?

    static func show(_ message: String) {
        guard let scene = activeScene() else { return }

        // Tear down any in-flight toast before showing a new one.
        window?.isHidden = true
        window = nil

        let toastWindow = UIWindow(windowScene: scene)
        toastWindow.windowLevel = .alert + 1
        toastWindow.backgroundColor = .clear
        let passthrough = PassthroughController()
        toastWindow.rootViewController = passthrough
        toastWindow.isHidden = false
        window = toastWindow

        let container = passthrough.view!

        let label = UILabel()
        label.text = message
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(red: 0.60, green: 0.75, blue: 0.94, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        let bar = UIView()
        bar.backgroundColor = UIColor(red: 0.07, green: 0.20, blue: 0.35, alpha: 1)
        bar.layer.cornerRadius = 12
        bar.layer.cornerCurve = .continuous
        bar.layer.shadowColor = UIColor.black.cgColor
        bar.layer.shadowOpacity = 0.25
        bar.layer.shadowRadius = 16
        bar.layer.shadowOffset = CGSize(width: 0, height: 6)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(label)
        container.addSubview(bar)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: bar.topAnchor, constant: 18),
            label.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -18),

            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            bar.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            bar.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -100),
        ])

        container.layoutIfNeeded()

        bar.transform = CGAffineTransform(translationX: 0, y: 40)
        bar.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            bar.transform = .identity
            bar.alpha = 1
        }

        UIView.animate(withDuration: 0.3, delay: 2.4, options: .curveEaseIn) {
            bar.alpha = 0
            bar.transform = CGAffineTransform(translationX: 0, y: 20)
        } completion: { _ in
            toastWindow.isHidden = true
            if window === toastWindow { window = nil }
        }
    }

    private static func activeScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
    }
}

/// Root VC whose view ignores touches outside its subviews, so the toast
/// window never blocks interaction with the app beneath it.
private final class PassthroughController: UIViewController {
    override func loadView() {
        view = PassthroughView()
    }
}

private final class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit === self ? nil : hit
    }
}
