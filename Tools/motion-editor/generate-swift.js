/**
 * generate-swift.js
 * 
 * Reads motion-tokens.json and generates MotionToken.swift
 * with the current easing curves, durations, and component assignments.
 * 
 * Usage: node generate-swift.js
 */

const fs = require('fs');
const path = require('path');

const TOKENS_PATH = path.join(__dirname, '..', '..', 'Tokens', 'motion-tokens.json');
const SWIFT_PATH = path.join(__dirname, '..', '..', 'OutlookBoilerplate', 'MotionToken.swift');

function generate() {
  const raw = fs.readFileSync(TOKENS_PATH, 'utf8');
  const tokens = JSON.parse(raw);

  const easings = tokens.motion.easing;
  const durations = tokens.motion.duration;
  const components = tokens.motion.components || {};

  // Build easing cases
  let easingCases = '';
  let easingProperties = '';
  Object.entries(easings).forEach(([name, data]) => {
    const pts = data.$value.match(/cubic-bezier\(([^)]+)\)/)[1].split(',').map(v => v.trim());
    easingCases += `    case ${name}\n`;
    easingProperties += `        case .${name}: return (${pts[0]}, ${pts[1]}, ${pts[2]}, ${pts[3]})\n`;
  });

  // Build duration cases
  let durationCases = '';
  let durationProperties = '';
  Object.entries(durations).forEach(([name, data]) => {
    const val = parseFloat(data.$value);
    durationCases += `    case ${name}\n`;
    durationProperties += `        case .${name}: return ${val}\n`;
  });

  // Build component cases and resolution
  let componentCases = '';
  let componentEasingMap = '';
  let componentDurationMap = '';
  const componentEntries = Object.entries(components).filter(([_, v]) => v._easing || v._duration);

  componentEntries.forEach(([id, spec]) => {
    componentCases += `    case ${id}\n`;
    if (spec._easing) {
      componentEasingMap += `        case .${id}: return .${spec._easing}\n`;
    } else {
      componentEasingMap += `        case .${id}: return .standard\n`;
    }
    if (spec._duration) {
      componentDurationMap += `        case .${id}: return .${spec._duration}\n`;
    } else {
      componentDurationMap += `        case .${id}: return .normal\n`;
    }
  });

  // If no components assigned, add a placeholder
  if (!componentEntries.length) {
    componentCases = '    case none\n';
    componentEasingMap = '        case .none: return .standard\n';
    componentDurationMap = '        case .none: return .normal\n';
  }

  const swift = `//
//  MotionToken.swift
//  OutlookBoilerplate
//
//  AUTO-GENERATED from motion-tokens.json — do not edit manually.
//  Regenerate with: node Tools/motion-editor/generate-swift.js
//

import SwiftUI

// MARK: - Easing Tokens

enum MotionEasing: String, CaseIterable {
${easingCases}
    var controlPoints: (Double, Double, Double, Double) {
        switch self {
${easingProperties}        }
    }

    var animation: (Double) -> Animation {
        let cp = controlPoints
        return { duration in .timingCurve(cp.0, cp.1, cp.2, cp.3, duration: duration) }
    }
}

// MARK: - Duration Tokens

enum MotionDuration: String, CaseIterable {
${durationCases}
    var seconds: Double {
        switch self {
${durationProperties}        }
    }

    var milliseconds: Int { Int(seconds * 1000) }
}

// MARK: - Component Motion Assignment

enum MotionComponent: String, CaseIterable {
${componentCases}
    var easing: MotionEasing {
        switch self {
${componentEasingMap}        }
    }

    var duration: MotionDuration {
        switch self {
${componentDurationMap}        }
    }

    /// Resolved SwiftUI animation for this component.
    var animation: Animation {
        easing.animation(duration.seconds)
    }
}

// MARK: - View Extension

extension View {
    /// Apply the motion token animation for a component.
    ///
    ///     .offset(y: isShowing ? 0 : 20)
    ///     .motionAnimation(.tabPill, value: isShowing)
    ///
    func motionAnimation<V: Equatable>(_ component: MotionComponent, value: V) -> some View {
        animation(component.animation, value: value)
    }
}

// MARK: - Reduce Motion Support

extension View {
    /// Motion-safe animation that respects Reduce Motion accessibility setting.
    func motionAnimationSafe<V: Equatable>(
        _ component: MotionComponent,
        value: V,
        reduceMotion: Bool
    ) -> some View {
        animation(
            reduceMotion ? .easeOut(duration: 0.15) : component.animation,
            value: value
        )
    }
}
`;

  fs.writeFileSync(SWIFT_PATH, swift, 'utf8');
  console.log(`✓ Generated ${SWIFT_PATH}`);
  console.log(`  Easings: ${Object.keys(easings).length}`);
  console.log(`  Durations: ${Object.keys(durations).length}`);
  console.log(`  Components: ${componentEntries.length}`);
}

generate();
module.exports = { generate };
