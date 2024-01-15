/////
////  PayloadDecoder.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable

class PayloadDecoderProxy {
    typealias Block = (UInt64, Data) -> Void
    var block: Block
    
    init(block: @escaping Block) {
        self.block = block
    }
    
    func decode(sequence: UInt64, payloadSize: Int, payload: UnsafeMutableRawPointer) {
        let data = Data(bytesNoCopy: payload, count: payloadSize, deallocator: .none)
        block(sequence, data)
    }
}
