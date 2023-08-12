//
//  Indicators.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

// MARK: - Indicators

public final class Indicators: ObservableObject {
	@Published
	public private(set) var indicators: [Indicator] = []
	
	internal var timers: [Indicator.ID: Timer] = [:]

	public init() { }

	public func display(_ indicator: Indicator) {
		withAnimation {
			indicators.append(indicator)
		}
		setupTimerIfNeeded(for: indicator)
	}

	@inlinable @MainActor
	public func dismiss(_ indicator: Indicator) {
		dismiss(matching: indicator.id)
	}

	@MainActor
	public func dismiss(matching id: String) {
		guard let index = indicators.firstIndex(where: { $0.id == id }) else {
			return
		}
		_ = withAnimation {
			indicators.remove(at: index)
		}
		dismissTimerIfNeeded(for: id)
	}
}

// MARK: - Indicators+Internal

internal extension Indicators {
	func setupTimerIfNeeded(for indicator: Indicator) {
		if case .after(let time) = indicator.dismissType {
			let timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { _ in
				Task { @MainActor [weak self] in
					self?.dismiss(matching: indicator.id)
				}
			}
			self.timers[indicator.id] = timer
		}
	}

	func dismissTimerIfNeeded(for id: Indicator.ID) {
		timers[id]?.invalidate()
		timers[id] = nil
	}
}
