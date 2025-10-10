//
//  IndicatorBackgroundViewModifier.swift
//  IndicatorsKit
//
//  Created by royal on 08/10/2025.
//

import SwiftUI

struct IndicatorBackgroundViewModifier<S: Shape>: ViewModifier {
	let shape: S

	func body(content: Content) -> some View {
		if #available(iOS 26.0, macOS 26.0, *) {
			content
				.glassEffect(
					.regular.interactive(),
					in: shape
				)
		} else {
			content
				.background(.regularMaterial, in: shape)
		}
	}
}
