/////
////  PayloadDecoder.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable

public class PayloadDecoderProxy {
    typealias DidReceive = (UInt64, Data) -> Void
    var didReceive: DidReceive
    
    init(didReceive: @escaping DidReceive) {
        self.didReceive = didReceive
    }
    
    public func decode(sequence: UInt64, payloadSize: Int, payload: UnsafeMutableRawPointer) {
        let data = Data(bytesNoCopy: payload, count: payloadSize, deallocator: .none)
        didReceive(sequence, data)
    }
}
