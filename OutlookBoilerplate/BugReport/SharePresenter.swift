//
//  SharePresenter.swift
//  OutlookBoilerplate
//
//  Presents the iOS share sheet (UIActivityViewController) via UIKit from the
//  top-most view controller. Doing this directly — rather than as a nested
//  SwiftUI `.sheet` inside the bug-report form — avoids the empty/black share
//  sheet that nested sheet presentation produces on device.
//

import UIKit

enum SharePresenter {
    /// Presents a share sheet for the given items from the front-most VC.
    static func present(items: [Any]) {
        guard let presenter = topViewController() else { return }

        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Show the confirmation toast whenever the share sheet closes. Many
        // share targets report `completed == false` even on a successful send,
        // so fire regardless. Rendered via UIKit so it can't be swallowed by
        // the SwiftUI overlay/notification chain.
        controller.completionWithItemsHandler = { _, _, _, _ in
            DispatchQueue.main.async {
                ToastPresenter.show("Bug report shared")
            }
        }

        // Required on iPad / regular-width — a nil anchor crashes there.
        if let popover = controller.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        presenter.present(controller, animated: true)
    }

    /// Walks the presented-controller chain from the key window's root to find
    /// the controller currently in front, so the share sheet stacks on top.
    private static func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }

        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
