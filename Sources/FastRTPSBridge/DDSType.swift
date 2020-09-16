/////
////  DDSType.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation

public protocol DDSType: Codable {
    static var ddsTypeName: String { get }
    static var isKeyed: Bool { get }
}

public protocol DDSKeyed: DDSType {
    var key: Data { get }
}
public extension DDSKeyed {
    static var isKeyed: Bool { true }
}

public protocol DDSUnkeyed: DDSType {}
public extension DDSUnkeyed {
    static var isKeyed: Bool { false }
}
