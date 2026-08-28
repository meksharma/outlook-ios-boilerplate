import OutlookBackdrop
import SwiftUI

struct LoaderDemoView: View {
    @AppStorage("loaderDemoAppearance")
    private var appearance = LoaderDemoAppearance.light.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: .odsSize200) {
            toolbarSkeleton
            subjectSkeleton
            loaderRow
            senderSkeleton
            bodySkeleton
            Spacer(minLength: 0)
            actionBarSkeleton
        }
        .padding(.horizontal, .odsSize160)
        .padding(.bottom, .odsSize200)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.odsNeutralBackground1)
        .preferredColorScheme(selectedAppearance.colorScheme)
    }

    private var toolbarSkeleton: some View {
        HStack {
            skeletonCircle(size: 44)
            Spacer(minLength: 0)
            appearanceToggle
        }
    }

    private var appearanceToggle: some View {
        Button {
            appearance = selectedAppearance.toggled.rawValue
        } label: {
            Image(systemName: selectedAppearance.toggleSystemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.odsNeutralForeground1)
                .frame(width: 44, height: 44)
                .background(skeletonFill)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(selectedAppearance.toggleAccessibilityLabel)
    }

    private var subjectSkeleton: some View {
        VStack(alignment: .leading, spacing: .odsSize80) {
            skeletonCapsule(width: 240, height: 22)
            skeletonCapsule(width: 104, height: 16)
        }
    }

    private var loaderRow: some View {
        HStack(spacing: .odsSize40) {
            AnimatedGIFView(
                assetName: "card_latency_animation",
                size: CGSize(width: 12, height: 12)
            )
            .frame(width: 12, height: 12)
            .clipped()
            .frame(width: 20, height: 20)

            Text("Loading")
                .odsBody2Strong()
                .foregroundStyle(Color.odsNeutralForeground1)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, .odsSize160)
        .frame(maxWidth: .infinity, minHeight: 44)
        .accessibilityElement(children: .combine)
    }

    private var senderSkeleton: some View {
        HStack(spacing: .odsSize120) {
            skeletonCircle(size: 40)

            VStack(alignment: .leading, spacing: .odsSize60) {
                skeletonCapsule(width: 132, height: 16)
                skeletonCapsule(width: 92, height: 12)
            }

            Spacer(minLength: 0)
        }
    }

    private var bodySkeleton: some View {
        VStack(alignment: .leading, spacing: .odsSize120) {
            ForEach([300.0, 336.0, 280.0, 320.0, 210.0], id: \.self) { width in
                skeletonCapsule(width: width, height: 13)
            }

            Spacer()
                .frame(height: .odsSize120)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(skeletonFill)
                .frame(maxWidth: .infinity)
                .frame(height: 180)
        }
    }

    private var actionBarSkeleton: some View {
        HStack(spacing: .odsSize160) {
            ForEach(0..<5, id: \.self) { _ in
                skeletonCircle(size: 24)
            }
        }
        .padding(.horizontal, .odsSize200)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(skeletonFill)
        .clipShape(Capsule())
    }

    private var skeletonFill: Color {
        Color.odsNeutralForeground3.opacity(0.14)
    }

    private var selectedAppearance: LoaderDemoAppearance {
        LoaderDemoAppearance(rawValue: appearance) ?? .light
    }

    private func skeletonCircle(size: CGFloat) -> some View {
        Circle()
            .fill(skeletonFill)
            .frame(width: size, height: size)
    }

    private func skeletonCapsule(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Capsule()
            .fill(skeletonFill)
            .frame(width: width, height: height)
    }
}

#Preview {
    LoaderDemoView()
}

private enum LoaderDemoAppearance: String {
    case light
    case dark

    var toggled: LoaderDemoAppearance {
        switch self {
        case .light:
            .dark
        case .dark:
            .light
        }
    }

    var toggleSystemImage: String {
        switch self {
        case .light:
            "moon.fill"
        case .dark:
            "sun.max.fill"
        }
    }

    var toggleAccessibilityLabel: String {
        switch self {
        case .light:
            "Switch to dark mode"
        case .dark:
            "Switch to light mode"
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}
