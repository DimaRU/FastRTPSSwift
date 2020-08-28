/////
////  PayloadDecoder.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable

public protocol PayloadDecoderInterface {
    func decode(sequence: UInt64,
                payloadSize: Int,
                payload: UnsafeMutableRawPointer)
}

public protocol PayloadDecoderProtocol {
    associatedtype ddsType
    associatedtype ddsTopic
    
    init(topic: ddsTopic, completion:  ((ddsType) -> Void)?)
}

public class PayloadDecoder<D: DDSType, T: DDSReaderTopic>: PayloadDecoderInterface, PayloadDecoderProtocol {
    typealias Completion = (D) -> Void
    let decoder = CDRDecoder()
    var topic: T
    var completion: Completion?
    
    public required init(topic: T, completion: ((D) -> Void)?) {
        self.topic = topic
        self.completion = completion
    }
    
    #if DEBUG
    deinit {
        print(#file, #function)
    }
    #endif
    
    public func decode(sequence: UInt64,
                       payloadSize: Int,
                       payload: UnsafeMutableRawPointer) {
        
        let data = Data(bytesNoCopy: payload, count: payloadSize, deallocator: .none)
        do {
            let t = try decoder.decode(D.self, from: data)
            completion?(t)
        } catch {
            print("\(topic.rawValue): \(sequence) \(payloadSize) error decoding")
            print(error)
        }
    }
}
