/////
////  WriterDiscoveryInfo.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CxxStdlib

public struct WriterDiscoveryInfo {
    var info: UnsafeMutablePointer<BridgedWriterProxyData>

    init(info: UnsafeMutablePointer<BridgedWriterProxyData>) {
        self.info = info
    }

    public var topicName: String {
        String(cString: info.pointee.topicName())
    }
    
    public var typeName: String {
        String(cString: info.pointee.typeName())
    }

    public var disablePositiveAcks: Bool {
        info.pointee.disable_positive_acks()
    }

    public var unicastLocators: String {
        return String(info.pointee.getUnicastLocators())
    }

    public var multicastLocators: String {
        return String(info.pointee.getMutlicastLocators())
    }
}
