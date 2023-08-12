//
//  IndicatorView.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

// MARK: - IndicatorView

struct IndicatorView: View {
	let indicator: Indicator
	let onDismiss: () -> Void
	let onExpandedToggle: (Bool) -> Void

	@State private var isExpanded: Bool = false
	@State private var dragOffset: CGSize = .zero

	private let dragInWrongDirectionMultiplier: Double = 0.028
	private let dragThreshold: Double = 20
	private let maxWidth: Double = 300
	private let padding: Double = 10
	private let backgroundShape: some Shape = RoundedRectangle(cornerRadius: 32, style: .circular)

	private var dragGesture: some Gesture {
		DragGesture()
			.onChanged {
				dragOffset.width = $0.translation.width * dragInWrongDirectionMultiplier
				dragOffset.height = $0.translation.height < 0 ? $0.translation.height : $0.translation.height * dragInWrongDirectionMultiplier
			}
			.onEnded {
				withAnimation(.bouncy) {
					dragOffset = .zero
				}

				if $0.translation.height < dragThreshold {
					// Dismiss
					onDismiss()
				} else if $0.translation.height > 0 {
					if indicator.expandedText != nil {
						isExpanded.toggle()
						onExpandedToggle(isExpanded)
					}
				}
			}
	}

	var body: some View {
		HStack {
			if let icon = indicator.icon {
				Image(systemName: icon)
					.font(indicator.subheadline != nil ? .title3 : .footnote)
					.symbolVariant(indicator.style.iconVariants)
					.foregroundStyle(indicator.style.iconStyle)
					.foregroundColor(indicator.style.iconColor)
					.contentTransition(.opacity)
					.geometryGroup()
			}

			VStack {
				Text(indicator.headline)
					.font(.footnote)
					.fontWeight(.medium)
					.geometryGroup()
					.lineLimit(isExpanded ? 2 : 1)
					.foregroundStyle(indicator.style.headlineStyle)
					.foregroundColor(indicator.style.headlineColor)
					.contentTransition(.opacity)
					.geometryGroup()

				ZStack {
					Group {
						if !isExpanded, let content = indicator.subheadline {
							Text(content)
						}

						if isExpanded, let content = indicator.expandedText {
							Text(content)
						}
					}
					.font(.footnote)
					.fontWeight(.medium)
					.geometryGroup()
					.lineLimit(isExpanded ? nil : 2)
					.foregroundStyle(indicator.style.subheadlineStyle)
					.foregroundColor(indicator.style.subheadlineColor)
					.transition(.scale(scale: 0.8).combined(with: .opacity))
				}
			}
			.padding(.trailing, indicator.icon != nil ? padding : 0)
			.padding(.horizontal, indicator.subheadline != nil ? padding : 0)
			.multilineTextAlignment(.center)
		}
		.padding(padding)
		.padding(.horizontal, padding)
		.background(.regularMaterial, in: backgroundShape)
		.frame(maxWidth: isExpanded ? nil : maxWidth, alignment: .center)
		.mask(backgroundShape)
		.shadow(color: .black.opacity(0.098), radius: 8, x: 0, y: 0)
		.animation(.spring, value: isExpanded)
		.optionalTapGesture(indicator.onTap)
		.offset(dragOffset)
		.gesture(dragGesture)
	}
}

// MARK: - IndicatorView+Identifiable

extension IndicatorView: Identifiable {
	var id: String { indicator.id }
}

// MARK: - Previews

/*
struct IndicatorView_Previews: PreviewProvider {
	static let isExpanded: Binding<Bool> = .constant(false)

	static var previews: some View {
		Group {
			IndicatorView(indicator: .init(id: "",
										   icon: nil,
										   headline: "Headline",
										   dismissType: .manual),
						  isExpanded: isExpanded)
			.previewDisplayName("Basic")

			IndicatorView(indicator: .init(id: "",
										   icon: "bolt.fill",
										   headline: "Headline",
										   dismissType: .manual),
						  isExpanded: isExpanded)
			.previewDisplayName("Icon")

			IndicatorView(indicator: .init(id: "",
										   headline: "Headline",
										   subheadline: "Subheadline",
										   dismissType: .manual),
						  isExpanded: isExpanded)
			.previewDisplayName("Subheadline")

			IndicatorView(indicator: .init(id: "",
										   icon: "bolt.fill",
										   headline: "Headline",
										   subheadline: "Subheadline",
										   dismissType: .manual),
						  isExpanded: isExpanded)
			.previewDisplayName("Subheadline with icon")

			IndicatorView(indicator: .init(id: "",
										   icon: "bolt.fill",
										   headline: "Headline",
										   subheadline: "Subheadline",
										   dismissType: .manual,
										   style: .init(subheadlineColor: .red, iconColor: .red)),
						  isExpanded: isExpanded)
			.previewDisplayName("Full colored")
		}
		.previewLayout(.sizeThatFits)
		.padding()
		//		.background(Color(uiColor: .systemBackground))
		.environment(\.colorScheme, .light)
	}
}
*/
