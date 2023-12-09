//
//  IndicatorsOverlay.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

@available(iOS 17.0, *)
public struct IndicatorsOverlay: View {
	@Environment(\.ikEnableHaptics) private var enableHaptics
	@ObservedObject private var model: Indicators

	public init(model: Indicators) {
		self.model = model
	}

	public var body: some View {
		ZStack {
			ForEach(model.indicators) { indicator in
				IndicatorView(
					indicator: indicator,
					onDismiss: { onDismiss(indicator) },
					onExpandedToggle: { onExpandedToggle(indicator, isExpanded: $0) }
				)
				.padding(.horizontal)
				.padding(.top, 4)
				.transition(
					.asymmetric(
						insertion: .push(from: .top),
						removal: .push(from: .bottom)
					)
				)
			}
		}
		.id(ViewID.indicatorsOverlayView)
	}
}

// MARK: - IndicatorsOverlay+Private

private extension IndicatorsOverlay {
	func onExpandedToggle(_ indicator: Indicator, isExpanded: Bool) {
		#if canImport(UIKit)
		if enableHaptics {
			UIImpactFeedbackGenerator(style: .soft).impactOccurred()
		}
		#endif

		isExpanded ? model.dismissTimer(for: indicator.id) : model.setupTimerIfNeeded(for: indicator)
	}

	func onDismiss(_ indicator: Indicator) {
		model.dismiss(indicator)
	}

	func scale(for index: Int, indicatorsCount: Int) -> Double {
		let indexFlipped = Double(indicatorsCount - index) - 1
		return 1 - (indexFlipped * 0.2)
	}
}

// MARK: - IndicatorsOverlay+ViewID

private extension IndicatorsOverlay {
	enum ViewID: String {
		case indicatorsOverlayView = "IndicatorsOverlayView"
	}
}

// MARK: - Previews

#if DEBUG
#Preview {
	IndicatorsOverlay(model: .preview(.titleSubtitleExpandedIcon, timeout: 1))
		.frame(maxHeight: .infinity, alignment: .top)
}
#endif
