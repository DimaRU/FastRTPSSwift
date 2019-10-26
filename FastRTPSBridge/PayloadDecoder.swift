//
//  PayloadDecoder.swift
//  TestIntegration
//
//  Created by Dmitriy Borovikov on 14/08/2019.
//  Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable

@objc public protocol PayloadDecoderInterface {
    func decode(sequence: Int,
                payloadSize: Int,
                payload: UnsafePointer<CUnsignedChar>)
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
                payload: UnsafePointer<UInt8>) {
        
        let data = Data(bytes: payload + 4, count: payloadSize - 4)
        do {
            let t = try decoder.decode(T.self, from: data)
            completion?(t)
        } catch {
            print("\(topic): \(sequence) \(payloadSize) error decoding")
            print(error)
        }
    }
}
