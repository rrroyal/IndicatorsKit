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
				.padding(.top, 6)
				.transition(
					.asymmetric(
						insertion: .push(from: .top),
						removal: .push(from: .bottom)
					)
				)
			}
		}
	}
}

// MARK: - IndicatorsOverlay+Support

private extension IndicatorsOverlay {
	func onExpandedToggle(_ indicator: Indicator, isExpanded: Bool) {
		#if canImport(UIKit)
		if enableHaptics {
			UIImpactFeedbackGenerator(style: .soft).impactOccurred()
		}
		#endif

		isExpanded ? model.dismissTimerIfNeeded(for: indicator.id) : model.setupTimerIfNeeded(for: indicator)
	}

	func onDismiss(_ indicator: Indicator) {
		model.dismiss(indicator)
	}

	func scale(for index: Int, indicatorsCount: Int) -> Double {
		let indexFlipped = Double(indicatorsCount - index) - 1
		return 1 - (indexFlipped * 0.2)
	}
}

// MARK: - Previews

struct IndicatorsOverlay_Previews: PreviewProvider {
	static var previews: some View {
		var model: Indicators {
			let model = Indicators()

			for i in 0..<5 {
				DispatchQueue.global().asyncAfter(deadline: .now() + (Double(i * 2))) {
					let indicator = Indicator(id: UUID().uuidString,
											  icon: "xmark",
											  headline: "Headline \(i)",
											  subheadline: "Subheadline",
											  expandedText: "Expanded Text",
											  dismissType: .manual)
					model.display(indicator)
				}
			}

			return model
		}

		return Text("")
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			.indicatorOverlay(model: model)
	}
}
