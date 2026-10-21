//
//  Indicator.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

// MARK: - Indicator

public struct Indicator: Sendable {
	public let id: String

	public var icon: Icon?
	public var title: String
	public var subtitle: String?
	public var expandedText: String?
	public var dismissType: DismissType
	public var style: Style
	public var action: ActionType?

	internal var presentedAt: Date?

	public init(
		id: String,
		icon: Icon? = nil,
		title: String,
		subtitle: String? = nil,
		expandedText: String? = nil,
		dismissType: DismissType = .automatic,
		style: Style = .default,
		action: ActionType? = nil
	) {
		self.id = id
		self.icon = icon
		self.title = title
		self.subtitle = subtitle
		self.expandedText = expandedText
		self.dismissType = dismissType
		self.style = style
		self.action = action
	}
}

// MARK: - Indicator+Identifiable

extension Indicator: Identifiable {
	public static func == (lhs: Indicator, rhs: Indicator) -> Bool {
		lhs.id == rhs.id
	}
}

// MARK: - Indicator+Hashable

extension Indicator: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

// MARK: - Indicator+

public extension Indicator {
	enum ActionType: Sendable {
		case toggleExpansion
		case execute(@Sendable () -> Void)
	}

	enum DismissType: Equatable, Sendable {
		case manual
		case after(TimeInterval)

		public static let automatic: DismissType = .after(5)
	}

	enum Icon: Equatable, Sendable {
		case image(Image)
		case systemImage(String)
		case progressIndicator
	}

	struct Style: Sendable {
		public static let `default` = Style()
		public static let error = Style(
			iconStyle: .primary,
			tintColor: .red
		)

		public var iconStyle: HierarchicalShapeStyle
		public var tintColor: Color?

		public init(
			iconStyle: HierarchicalShapeStyle = .secondary,
			tintColor: Color? = .primary
		) {
			self.iconStyle = iconStyle
			self.tintColor = tintColor
		}
	}
}

// MARK: - Indicator+Preview

#if DEBUG
internal extension Indicator {
	static let preview: Indicator = .init(id: "id", title: "Title")

	static let allPreviewCases: [Self] = [
		.preview,
		.preview._icon(),
		.preview._icon(.progressIndicator),
		.preview._icon()._subtitle(),
		.preview._icon(.progressIndicator)._subtitle(),
		.preview._icon()._subtitle()._expandedText(),
		.preview._icon()._subtitle()._style(.error)
	]

	func _icon(_ icon: Indicator.Icon = .systemImage("rectangle.arrowtriangle.2.inward")) -> Self {
		var s = self
		s.icon = icon
		return s
	}

	func _title(_ title: String = "Title") -> Self {
		var s = self
		s.title = title
		return s
	}

	func _subtitle(_ subtitle: String = "Subtitle") -> Self {
		var s = self
		s.subtitle = subtitle
		return s
	}

	func _expandedText(_ expandedText: String = "Expanded text, that will be longer. It could be a readable description of some error, or some other longer tooltip. The choice is yours.") -> Self {
		var s = self
		s.expandedText = expandedText
		return s
	}

	func _dismissType(_ dismissType: DismissType = .manual) -> Self {
		var s = self
		s.dismissType = dismissType
		return s
	}

	func _style(_ style: Style = .default) -> Self {
		var s = self
		s.style = style
		return s
	}

	func _action(_ action: ActionType = .toggleExpansion) -> Self {
		var s = self
		s.action = action
		return s
	}
}
#endif
