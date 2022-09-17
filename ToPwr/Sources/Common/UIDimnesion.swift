import SwiftUI

public enum UIDimensions {
    case small, normal, big, huge
    
    public var size: CGFloat {
        switch self {
        case .huge:
            return 36.0
        case .big:
            return 24.0
        case .normal:
            return 16.0
        case .small:
            return 8.0
        }
    }
    
    public var spacing: CGFloat {
        switch self {
        case .huge:
            return 36.0
        case .big:
            return 24.0
        case .normal:
            return 16.0
        case .small:
            return 8.0
        }
    }

    public var verticalPadding: EdgeInsets {
        switch self {
        case .huge:
            return .create(
                top: 36.0,
                bottom: 36.0
            )
        case .big:
            return .create(
                top: 24.0,
                bottom: 24.0
            )
        case .normal:
            return .create(
                top: 16.0,
                bottom: 16.0
            )
        case .small:
            return .create(
                top: 8.0,
                bottom: 8.0
            )
        }
    }
    
    public var horizontalPadding: EdgeInsets {
        switch self {
        case .huge:
            return .create(
                leading: 36.0,
                trailing: 36.0
            )
        case .big:
            return .create(
                leading: 24.0,
                trailing: 24.0
            )
        case .normal:
            return .create(
                leading: 16.0,
                trailing: 16.0
            )
        case .small:
            return .create(
                leading: 8.0,
                trailing: 8.0
            )
        }
    }
    
    public var padding: EdgeInsets {
        switch self {
        case .huge:
            return .create(
                top: 36.0,
                leading: 36.0,
                bottom: 36.0,
                trailing: 36.0
            )
        case .big:
            return .create(
                top: 24.0,
                leading: 24.0,
                bottom: 24.0,
                trailing: 24.0
            )
        case .normal:
            return .create(
                top: 16.0,
                leading: 16.0,
                bottom: 16.0,
                trailing: 16.0
            )
        case .small:
            return .create(
                top: 8.0,
                leading: 8.0,
                bottom: 8.0,
                trailing: 8.0
            )
        }
    }
    
    public var cornerRadius: CGFloat {
        switch self {
        case .huge:
            return 20
        case .big:
            return 16
        case .normal:
            return 8
        case .small:
            return 4
        }
    }
}

extension EdgeInsets {
    
    public static func create(
        top: CGFloat = .zero,
        leading: CGFloat = .zero,
        bottom: CGFloat = .zero,
        trailing: CGFloat = .zero
    ) -> EdgeInsets {
        EdgeInsets(
            top: top,
            leading: leading,
            bottom: bottom,
            trailing: trailing
        )
    }
    
    public static func create(
        top: CGFloat = .zero,
        horizontal: EdgeInsets,
        bottom: CGFloat = .zero
    ) -> EdgeInsets {
        EdgeInsets(
            top: top,
            leading: horizontal.leading,
            bottom: bottom,
            trailing: horizontal.trailing
        )
    }
    
    public static func create(
        leading: CGFloat = .zero,
        vertical: EdgeInsets,
        trailing: CGFloat = .zero
    ) -> EdgeInsets {
        EdgeInsets(
            top: vertical.top,
            leading: leading,
            bottom: vertical.bottom,
            trailing: trailing
        )
    }
}
