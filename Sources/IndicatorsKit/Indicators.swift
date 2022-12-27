//
//  Indicators.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import Foundation

public final class Indicators: ObservableObject {
	@Published public private(set) var activeIndicator: Indicator?

	internal var timer: Timer?

	public init() { }

	@MainActor
	public func display(_ indicator: Indicator) {
		if activeIndicator?.id != indicator.id {
			timer?.invalidate()
		}

		activeIndicator = indicator
		updateTimer()
	}

	@MainActor
	public func dismiss() {
		activeIndicator = nil
		timer?.invalidate()
	}

	@MainActor
	public func dismiss(matching id: String) {
		if activeIndicator?.id == id {
			dismiss()
		}
	}

	internal func updateTimer() {
		if case .after(let timeout) = activeIndicator?.dismissType {
			let storedIndicator = activeIndicator

			timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
				guard let self else { return }
				
				// Check if activeIndicator is still the same as it was previously
				Task { @MainActor in
					if self.activeIndicator == storedIndicator {
						self.dismiss()
					}
				}
			}
		}
	}
}
