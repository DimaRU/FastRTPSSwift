/////
////  PayloadDecoder.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable

public class PayloadDecoderProxy {
    typealias Completion = (UInt64, Data) -> Void
    var completion: Completion
    
    init(completion: @escaping Completion) {
        self.completion = completion
    }
    
    public func decode(sequence: UInt64, payloadSize: Int, payload: UnsafeMutableRawPointer) {
        let data = Data(bytesNoCopy: payload, count: payloadSize, deallocator: .none)
        completion(sequence, data)
    }
}
