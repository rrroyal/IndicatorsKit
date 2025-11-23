//
//  IndicatorView.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

// MARK: - IndicatorView

struct IndicatorView: View {
	var indicator: Indicator
	var dismissAction: () -> Void
	var toggleExpansionAction: (Bool) -> Void

	@Namespace private var animationNamespace

	@State private var isPressed = false
	@State private var isExpanded = false
	@State private var isIconVisible = false
	@State private var dragOffset = CGSize.zero

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
					dismissAction()
				} else if $0.translation.height > 0 {
					if indicator.expandedText != nil {
						toggleExpansionIfPossible()
					}
				}
			}
	}

	init(
		indicator: Indicator,
		dismissAction: @escaping () -> Void,
		toggleExpansionAction: @escaping (Bool) -> Void
	) {
		self.indicator = indicator
		self.dismissAction = dismissAction
		self.toggleExpansionAction = toggleExpansionAction
	}

	#if DEBUG
	init(
		indicator: Indicator,
		dismissAction: @escaping () -> Void = {},
		toggleExpansionAction: @escaping (Bool) -> Void = { _ in },
		isExpanded: Bool = false
	) {
		self.indicator = indicator
		self.dismissAction = dismissAction
		self.toggleExpansionAction = toggleExpansionAction
		self.isExpanded = isExpanded
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
								.onAppear { isIconVisible = false }
						case .systemImage(let systemName):
							Image(systemName: systemName)
								.font(iconFont)
								.fontWeight(.medium)
//								.foregroundStyle(indicator.style.iconStyle)
								.foregroundColor(indicator.style.tintColor)
								.symbolRenderingMode(.hierarchical)
								.symbolEffect(.bounce, options: .nonRepeating, value: isIconVisible)
								.symbolEffect(.bounce, options: .nonRepeating, value: indicator.presentedAt)
//								.transition(.symbolEffect(.appear))
								.onAppear { isIconVisible = true }
								.onDisappear { isIconVisible = false }
						case .progressIndicator:
							ProgressView()
								#if os(macOS)
								.controlSize(.small)
								#endif
								.onAppear { isIconVisible = false }
						}
					}
					.contentTransition(.symbolEffect(.replace.magic(fallback: .replace)))
//					.geometryGroup()
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
						.frame(
							maxWidth: isExpanded ? .infinity : nil,
							alignment: isExpanded ? .leading : .center
						)
						.fixedSize(horizontal: !isExpanded && indicator.title.count < 16, vertical: false)
						.geometryGroup()
						.id(ViewID.titleLabel)

					if !isExpanded, let content = indicator.subtitle {
						Text(content)
							.font(.footnote)
							.fontWeight(.medium)
							.lineLimit(2)
							.foregroundStyle(.secondary)
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
		.geometryGroup()
		.mask(backgroundShape)
		.contentShape(backgroundShape)
		.modifier(IndicatorBackgroundViewModifier(shape: backgroundShape))
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

// MARK: - Identifiable

extension IndicatorView {
	var id: String { indicator.id }
}

// MARK: - UI

private extension IndicatorView {
	var dragInWrongDirectionMultiplier: Double { 0.028 }
	var dragThreshold: Double { 20 }

	var backgroundShape: some Shape { RoundedRectangle(cornerRadius: 28, style: .circular) }

	var minWidth: Double {
		if indicator.subtitle != nil {
			return 112
		}
		return 64
	}

	var maxWidth: Double { 300 }

	var spacingVertical: Double { 8 }

	var spacingHorizontal: Double {
		if isExpanded {
			return 6
		}
		if indicator.subtitle != nil {
			return 12
		}
		return 6
	}

	var paddingHorizontal: Double {
		if isExpanded {
			return paddingVertical
		}
		if indicator.subtitle != nil {
			return 26
		}
		return 18
	}

	var paddingVertical: Double {
		if isExpanded {
			return 18
		}
		if indicator.subtitle != nil {
			return 12
		}
		return 12
	}

	var iconFont: Font {
		if isExpanded {
			return titleFont
		}
		if indicator.subtitle != nil {
			return .title2
		}
		return .footnote
	}

	var titleFont: Font {
		if isExpanded {
			return .title3
		}
		return .footnote
	}
}

// MARK: - Actions

private extension IndicatorView {
	func toggleExpansionIfPossible() {
		guard indicator.expandedText != nil else {
			return
		}

		isExpanded.toggle()
		toggleExpansionAction(isExpanded)
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

// MARK: - ViewID

private extension IndicatorView {
	enum ViewID: String {
		case iconView = "IconView"
		case titleLabel = "TitleLabel"
		case subtitleLabel = "SubtitleLabel"
		case expandedContentLabel = "ExpandedContentLabel"
	}
}

// MARK: - AnimationID

private extension IndicatorView {
	enum AnimationID: String {
		case subtitleOrExpandedTextLabel = "SubtitleOrExpandedTextLabel"
	}
}

// MARK: - Previews

#if DEBUG
#Preview("Title", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .title)
		.padding()
		.background(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Icon + Title", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .titleIcon)
		.padding()
		.background(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Title + Subtitle", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .titleSubtitleExpanded)
		.padding()
		.background(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Icon + Title + Subtitle", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .titleSubtitleExpandedIcon)
		.padding()
		.background(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Title + Subtitle (Expanded)", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .titleSubtitleExpanded, isExpanded: true)
		.padding()
		.background(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("Icon + Title + Subtitle (Expanded)", traits: .sizeThatFitsLayout) {
	IndicatorView(indicator: .titleSubtitleExpandedIcon, isExpanded: true)
		.padding()
		.background(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
}
#endif
