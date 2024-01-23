//
//  Indicator.swift
//  IndicatorsKit
//
//  Created by royal on 17/07/2022.
//

import SwiftUI

// MARK: - Indicator

public struct Indicator {
	public let id: String

	public var icon: String?
	public var title: String
	public var subtitle: String?
	public var expandedText: String?
	public var dismissType: DismissType
	public var style: Style
	public var action: ActionStyle?

	public init(
		id: String,
		icon: String? = nil,
		title: String,
		subtitle: String? = nil,
		expandedText: String? = nil,
		dismissType: DismissType = .automatic,
		style: Style = .default,
		action: ActionStyle? = nil
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
	enum DismissType {
		case manual
		case after(TimeInterval)

		public static let automatic: DismissType = .after(5)
	}

	enum ActionStyle {
		case toggleExpansion
		case execute(() -> Void)
	}

	struct Style {
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
	private static let _id = "id"
	private static let _icon = "command"
	private static let _title = "Title"
	private static let _subtitle = "Subtitle"
	private static let _expandedText = "Expanded text, that will be longer. It could be a readable description of some error, or some other longer tooltip. The choice is yours."
	private static let _dismissType = DismissType.manual
	private static let _style = Style.default
	private static let _action = ActionStyle.toggleExpansion

	static let allCases: [Indicator] = [
		.title,
		.titleIcon,
		.titleSubtitle,
		.titleSubtitleIcon,
		.titleSubtitleExpanded,
		.titleSubtitleExpandedIcon,
	]

	static let title = Indicator(
		id: Self._id,
		title: Self._title,
		dismissType: Self._dismissType,
		style: Self._style,
		action: Self._action
	)
	static let titleIcon = Indicator(
		id: Self._id,
		icon: Self._icon,
		title: Self._title,
		dismissType: Self._dismissType,
		style: Self._style,
		action: Self._action
	)
	static let titleSubtitle = Indicator(
		id: Self._id,
		title: Self._title,
		subtitle: Self._subtitle,
		dismissType: Self._dismissType,
		style: Self._style,
		action: Self._action
	)
	static let titleSubtitleIcon = Indicator(
		id: Self._id,
		icon: Self._icon,
		title: Self._title,
		subtitle: Self._subtitle,
		dismissType: Self._dismissType,
		style: Self._style,
		action: Self._action
	)
	static let titleSubtitleExpanded = Indicator(
		id: Self._id,
		title: Self._title,
		subtitle: Self._subtitle,
		expandedText: Self._expandedText,
		dismissType: Self._dismissType,
		style: Self._style,
		action: Self._action
	)
	static let titleSubtitleExpandedIcon = Indicator(
		id: Self._id,
		icon: Self._icon,
		title: Self._title,
		subtitle: Self._subtitle,
		expandedText: Self._expandedText,
		dismissType: Self._dismissType,
		style: Self._style,
		action: Self._action
	)
}
#endif
