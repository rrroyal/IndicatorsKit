//
//  Indicators.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

// MARK: - Indicators

@Observable
public final class Indicators {
	internal static let animation: Animation = .smooth

	public private(set) var indicators: [Indicator] = []

	internal var timers: [Indicator.ID: Timer] = [:]

	public init() { }

	public func display(_ indicator: Indicator) {
		withAnimation(Self.animation) {
			if let alreadyExistingIndex = indicators.firstIndex(where: { $0.id == indicator.id }) {
				indicators[alreadyExistingIndex] = indicator
			} else {
				indicators.append(indicator)
			}
		}
		setupTimerIfNeeded(for: indicator)
	}

	@inlinable @MainActor
	public func dismiss(_ indicator: Indicator) {
		dismiss(with: indicator.id)
	}

	@MainActor
	public func dismiss(with id: String) {
		guard let index = indicators.firstIndex(where: { $0.id == id }) else {
			return
		}
		_ = withAnimation(Self.animation) {
			indicators.remove(at: index)
		}
		dismissTimer(for: id)
	}
}

// MARK: - Indicators+Internal

internal extension Indicators {
	func setupTimerIfNeeded(for indicator: Indicator) {
		self.timers[indicator.id]?.invalidate()

		if case .after(let time) = indicator.dismissType {
			let timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { _ in
				Task { @MainActor [weak self] in
					self?.dismiss(indicator)
				}
			}
			self.timers[indicator.id] = timer
		}
	}

	func dismissTimer(for id: Indicator.ID) {
		timers[id]?.invalidate()
		timers[id] = nil
	}
}

// MARK: - Indicators+Preview

#if DEBUG
internal extension Indicators {
	static func preview(indicators: [Indicator] = [.titleSubtitleExpandedIcon], interval: TimeInterval = 2) -> Indicators {
		let model = Indicators()

		Task {
			try? await Task.sleep(for: .seconds(1))
			for indicator in indicators {
				model.display(indicator)
				try? await Task.sleep(for: .seconds(interval))
			}
		}

		return model
	}
}
#endif
