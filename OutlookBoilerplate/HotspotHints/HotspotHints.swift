//
//  HotspotHints.swift
//  OutlookBoilerplate
//
//  Figma-style hotspot hinting for explicitly registered prototype controls.
//

import SwiftUI

private struct HotspotAnchorPreferenceKey: PreferenceKey {
    static let defaultValue: [Anchor<CGRect>] = []

    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value.append(contentsOf: nextValue())
    }
}

private struct HotspotTapRequest: Equatable {
    let id = UUID()
    let location: CGPoint
}

private struct HotspotRegistrationEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

private extension EnvironmentValues {
    var hotspotRegistrationEnabled: Bool {
        get { self[HotspotRegistrationEnabledKey.self] }
        set { self[HotspotRegistrationEnabledKey.self] = newValue }
    }
}

extension View {
    /// Registers this view's rendered bounds as a prototype hotspot.
    func hotspotTarget(isEnabled: Bool = true) -> some View {
        modifier(HotspotTargetModifier(isEnabled: isEnabled))
    }

    /// Excludes controls in covered navigation layers from the active hotspot set.
    func hotspotRegistrationEnabled(_ isEnabled: Bool) -> some View {
        environment(\.hotspotRegistrationEnabled, isEnabled)
    }

    /// Hosts hotspot discovery for one SwiftUI presentation hierarchy.
    func hotspotHintsSurface(isEnabled: Bool) -> some View {
        modifier(HotspotHintsSurfaceModifier(isEnabled: isEnabled))
    }
}

private struct HotspotTargetModifier: ViewModifier {
    let isEnabled: Bool
    @Environment(\.hotspotRegistrationEnabled) private var isRegistrationEnabled

    func body(content: Content) -> some View {
        content.anchorPreference(
            key: HotspotAnchorPreferenceKey.self,
            value: .bounds
        ) {
            isEnabled && isRegistrationEnabled ? [$0] : []
        }
    }
}

private struct HotspotHintsSurfaceModifier: ViewModifier {
    let isEnabled: Bool

    @State private var tapRequest: HotspotTapRequest?

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .simultaneousGesture(
                SpatialTapGesture().onEnded { tap in
                    guard isEnabled else { return }
                    tapRequest = HotspotTapRequest(location: tap.location)
                }
            )
            .overlayPreferenceValue(HotspotAnchorPreferenceKey.self) { anchors in
                GeometryReader { proxy in
                    HotspotHintsOverlay(
                        frames: normalized(
                            anchors.map { proxy[$0] },
                            within: CGRect(origin: .zero, size: proxy.size)
                        ),
                        tapRequest: tapRequest,
                        isEnabled: isEnabled
                    )
                }
            }
    }

    private func normalized(_ frames: [CGRect], within bounds: CGRect) -> [CGRect] {
        frames
            .compactMap { frame -> CGRect? in
                guard !frame.isNull, !frame.isInfinite else { return nil }
                let visibleFrame = frame.intersection(bounds)
                return visibleFrame.width >= 8 && visibleFrame.height >= 8
                    ? visibleFrame
                    : nil
            }
            .reduce(into: [CGRect]()) { uniqueFrames, frame in
                let duplicate = uniqueFrames.contains {
                    abs($0.minX - frame.minX) < 1
                        && abs($0.minY - frame.minY) < 1
                        && abs($0.width - frame.width) < 1
                        && abs($0.height - frame.height) < 1
                }
                if !duplicate {
                    uniqueFrames.append(frame)
                }
            }
    }

    private struct HotspotHintsOverlay: View {
            let frames: [CGRect]
            let tapRequest: HotspotTapRequest?
            let isEnabled: Bool

            @State private var isShowingHints = false
            @State private var hideID = UUID()

            var body: some View {
                ZStack {
                ForEach(Array(frames.enumerated()), id: \.offset) { _, frame in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cyan.opacity(0.14))
                        .stroke(Color.cyan.opacity(0.9), lineWidth: 1.5)
                        .frame(width: frame.width, height: frame.height)
                        .position(x: frame.midX, y: frame.midY)
                }
                }
                .opacity(isShowingHints ? 1 : 0)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .onChange(of: tapRequest) { _, request in
                guard let request else { return }
                handleTap(at: request.location)
                }
                .onChange(of: isEnabled) { _, enabled in
                if !enabled {
                    isShowingHints = false
                }
                }
            }

            private func handleTap(at location: CGPoint) {
                let tappedHotspot = frames.contains {
                $0.insetBy(dx: -2, dy: -2).contains(location)
                }
                guard !tappedHotspot, !frames.isEmpty else { return }

                let currentHideID = UUID()
                hideID = currentHideID

                withAnimation(.easeOut(duration: 0.08)) {
                isShowingHints = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                guard hideID == currentHideID else { return }
                withAnimation(.easeOut(duration: 0.2)) {
                    isShowingHints = false
                }
                }
            }
    }
}
