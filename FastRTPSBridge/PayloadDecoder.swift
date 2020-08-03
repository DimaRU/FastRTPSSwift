/////
////  PayloadDecoder.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable

@objc public protocol PayloadDecoderInterface {
    func decode(sequence: Int,
                payloadSize: Int,
                payload: UnsafeMutableRawPointer)
}

public class PayloadDecoder<T: DDSType>:NSObject, PayloadDecoderInterface {
    typealias Completion = (T) -> Void
    let decoder = CDRDecoder()
    var topic: String
    var completion: Completion?
    
    public init(topic: String, completion:  ((T) -> Void)? = nil) {
        self.topic = topic
        self.completion = completion
        super.init()
    }

    public func decode(sequence: Int,
                       payloadSize: Int,
                       payload: UnsafeMutableRawPointer) {
        
        let data = Data(bytesNoCopy: payload, count: payloadSize, deallocator: .none)
        do {
            let t = try decoder.decode(T.self, from: data)
            completion?(t)
        } catch {
            print("\(topic): \(sequence) \(payloadSize) error decoding")
            print(error)
        }
    }
}
