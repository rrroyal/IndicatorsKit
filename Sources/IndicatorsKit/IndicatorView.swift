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
	let onDismiss: (() -> Void)?
	let onExpandedToggle: ((Bool) -> Void)?

	@Namespace private var animationNamespace

	@State private var isPressed: Bool = false
	@State private var isExpanded: Bool
	@State private var dragOffset: CGSize = .zero

	private let dragInWrongDirectionMultiplier: Double = 0.028
	private let dragThreshold: Double = 20

	private let backgroundShape: some Shape = RoundedRectangle(cornerRadius: 28, style: .circular)

	private var minWidth: Double {
		if indicator.subtitle != nil {
			return 112
		}
		return 64
	}
	private let maxWidth: Double = 300

	private let spacingVertical: Double = 8
	private var spacingHorizontal: Double {
		if isExpanded {
			return 6
		}
		if indicator.subtitle != nil {
			return 14
		}
		return 6
	}

	private var paddingHorizontal: Double {
		if isExpanded {
			return paddingVertical
		}
		if indicator.subtitle != nil {
			return 26
		}
		return 14
	}
	private var paddingVertical: Double {
		if isExpanded {
			return 18
		}
		if indicator.subtitle != nil {
			return 12
		}
		return 10
	}

	private var iconFont: Font {
		if isExpanded {
			return titleFont
		}
		if indicator.subtitle != nil {
			return .title2
		}
		return .footnote
	}

	private var titleFont: Font {
		if isExpanded {
			return .title3
		}
		return .footnote
	}

	private var dragGesture: some Gesture {
		DragGesture()
			.onChanged {
				dragOffset.width = $0.translation.width * dragInWrongDirectionMultiplier
				dragOffset.height = $0.translation.height < 0 ? $0.translation.height : $0.translation.height * dragInWrongDirectionMultiplier
			}
			.onEnded {
				withAnimation(.snappy) {
					dragOffset = .zero
				}

				if $0.translation.height < dragThreshold {
					onDismiss?()
				} else if $0.translation.height > 0 {
					if indicator.expandedText != nil {
						toggleExpansionIfPossible()
					}
				}
			}
	}

	init(
		indicator: Indicator,
		onDismiss: (() -> Void)? = nil,
		onExpandedToggle: ((Bool) -> Void)? = nil
	) {
		self.indicator = indicator
		self.onDismiss = onDismiss
		self.onExpandedToggle = onExpandedToggle
		self._isExpanded = .init(initialValue: false)
	}

	#if DEBUG
	init(
		indicator: Indicator,
		onDismiss: (() -> Void)? = nil,
		onExpandedToggle: ((Bool) -> Void)? = nil,
		isExpanded: Bool = false
	) {
		self.indicator = indicator
		self.onDismiss = onDismiss
		self.onExpandedToggle = onExpandedToggle
		self._isExpanded = .init(initialValue: isExpanded)
	}
	#endif

	var body: some View {
		VStack(spacing: spacingVertical) {
			HStack(spacing: spacingHorizontal) {
				if let icon = indicator.icon {
					Group {
						switch icon {
						case .image(let image):
							image
						case .systemImage(let systemName):
							Image(systemName: systemName)
								.font(iconFont)
								.fontWeight(.medium)
								.foregroundStyle(indicator.style.iconStyle)
								.foregroundColor(indicator.style.tintColor)
								.symbolRenderingMode(.hierarchical)
//								.geometryGroup()
						case .progressIndicator:
							ProgressView()
						}
					}
					.padding(.leading, -2)
					.id(ViewID.iconView)
				}

				VStack {
					Text(indicator.title)
						.font(titleFont)
						.fontWeight(.medium)
						.lineLimit(isExpanded ? 2 : 1)
						.foregroundStyle(.primary)
						.foregroundColor(indicator.style.tintColor)
//						.geometryGroup()
						.frame(
							maxWidth: isExpanded ? .infinity : nil,
							alignment: isExpanded ? .leading : .center
						)
						.id(ViewID.titleLabel)

					if !isExpanded, let content = indicator.subtitle {
						Text(content)
							.font(.footnote)
							.fontWeight(.medium)
							.lineLimit(2)
							.foregroundStyle(.secondary)
//							.geometryGroup()
							.matchedGeometryEffect(
								id: AnimationID.subtitleOrExpandedTextLabel,
								in: animationNamespace,
								properties: .position,
								anchor: .topLeading
							)
							.transition(.blurReplace)
							.id(ViewID.subtitleLabel)
					}
				}
				.multilineTextAlignment(isExpanded ? .leading : .center)
			}

			if isExpanded, let content = indicator.expandedText {
				Text(content)
					.font(.footnote)
					.fontWeight(.medium)
					.foregroundStyle(.secondary)
					.frame(maxWidth: .infinity, alignment: .leading)
//					.geometryGroup()
					.matchedGeometryEffect(
						id: AnimationID.subtitleOrExpandedTextLabel,
						in: animationNamespace,
						properties: .position,
						anchor: .topLeading
					)
					.transition(.blurReplace)
					.id(ViewID.expandedContentLabel)
			}
		}
		.padding(.horizontal, paddingHorizontal)
		.padding(.vertical, paddingVertical)
		.frame(minWidth: minWidth)
		.background(.regularMaterial, in: backgroundShape)
		.mask(backgroundShape)
		.scaleEffect(isPressed ? 0.96 : 1)
		.offset(dragOffset)
		.shadow(color: .black.opacity(0.14), radius: 10, x: 0, y: 0)
		.opacity(isPressed ? 0.8 : 1)
		.gesture(dragGesture)
		.animation(.spring, value: isExpanded)
		.animation(.spring, value: isPressed)
		.onLongPressGesture(minimumDuration: 0) {
			didTapIndicator()
		} onPressingChanged: {
			if indicator.action != nil {
				self.isPressed = $0
			}
		}
	}
}

// MARK: - IndicatorView+Identifiable

extension IndicatorView: Identifiable {
	var id: String { indicator.id }
}

// MARK: - IndicatorView+Private

private extension IndicatorView {
	func toggleExpansionIfPossible() {
		guard indicator.expandedText != nil else {
			return
		}

		isExpanded.toggle()
		onExpandedToggle?(isExpanded)
	}

	func didTapIndicator() {
		guard let action = indicator.action else {
			return
		}
		switch action {
		case .toggleExpansion:
			toggleExpansionIfPossible()
		case .execute(let actionToExecute):
			actionToExecute()
		}
	}
}

// MARK: - IndicatorView+ViewID

private extension IndicatorView {
	enum ViewID: String {
		case iconView = "IconView"
		case titleLabel = "TitleLabel"
		case subtitleLabel = "SubtitleLabel"
		case expandedContentLabel = "ExpandedContentLabel"
	}
}

// MARK: - IndicatorView+AnimationID

private extension IndicatorView {
	enum AnimationID: String {
		case subtitleOrExpandedTextLabel = "SubtitleOrExpandedTextLabel"
	}
}

// MARK: - Previews

#if DEBUG
#Preview("Title", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .title)
}

#Preview("Icon + Title", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .titleIcon)
}

#Preview("Title + Subtitle", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .titleSubtitleExpanded)
}

#Preview("Icon + Title + Subtitle", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .titleSubtitleExpandedIcon)
}

#Preview("Title + Subtitle (Expanded)", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .titleSubtitleExpanded, isExpanded: true)
}

#Preview("Icon + Title + Subtitle (Expanded)", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .titleSubtitleExpandedIcon, isExpanded: true)
}
#endif
