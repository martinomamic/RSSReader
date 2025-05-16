//
//  SnapshotLayout.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 09.05.25.
//

import SnapshotTesting
import UIKit

public enum SnapshotLayout: Sendable {
    case smallPhone
    case mediumPhone
    case largePhone
    case sizeThatFits
    case fixed(size: CGSize)
    
    public var name: String {
        switch self {
        case .smallPhone:
            return "smallPhone"
        case .mediumPhone:
            return "mediumPhone"
        case .largePhone:
            return "largePhone"
        case .sizeThatFits:
            return "sizeThatFits"
        case let .fixed(size):
            return "\(Int(size.width))x\(Int(size.height))"
        }
    }
    
    public var width: CGFloat {
        switch self {
        case .smallPhone:
            return ViewImageConfig.iPhoneSe3rdGen.size?.width ?? .zero
        case .mediumPhone:
            return ViewImageConfig.iPhone16.size?.width ?? .zero
        case .largePhone:
            return ViewImageConfig.iPhone16Plus.size?.width ?? .zero
        default:
            return .zero
        }
    }
    
    public static let defaults: [Self] = [.smallPhone, .mediumPhone, .largePhone]
}

extension Array where Element == SnapshotLayout {
    public static func defaults(height: CGFloat) -> Self {
        SnapshotLayout.defaults.map { $0.withFixedHeight(height) }
    }
}

extension SnapshotLayout {
    public var config: ViewImageConfig {
        switch self {
        case .smallPhone:
            return .iPhoneSe3rdGen
        case .mediumPhone:
            return .iPhone16
        case .largePhone:
            return .iPhone16Plus
        case .sizeThatFits:
            return .init()
        case let .fixed(size):
            return .init(size: size)
        }
    }
}

extension SnapshotLayout {
    public func withFixedHeight(_ height: CGFloat) -> SnapshotLayout {
        .fixed(size: .init(width: self.width, height: height))
    }
}

extension ViewImageConfig {
    public static let iPhoneSe3rdGen = ViewImageConfig.iPhone8(.portrait)
    public static let iPhone16 = ViewImageConfig.iPhone16(.portrait)
    public static let iPhone16Plus = ViewImageConfig.iPhone16Plus(.portrait)
    
    public static func iPhone16(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets = .init(top: 59, left: 0, bottom: 34, right: 0)
        let size: CGSize = .init(width: 393, height: 852)
        
        return .init(safeArea: safeArea, size: size)
    }
    
    public static func iPhone16Plus(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets = .init(top: 59, left: 0, bottom: 34, right: 0)
        let size: CGSize = .init(width: 430, height: 932)
        
        return .init(safeArea: safeArea, size: size)
    }
}
