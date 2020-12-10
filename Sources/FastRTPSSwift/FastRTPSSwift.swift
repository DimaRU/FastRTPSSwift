/////
////  FastRTPSSwift.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable

#if SWIFT_PACKAGE
@_exported import FastRTPSWrapper
#endif

public protocol RTPSListenerDelegate {
    func RTPSNotification(reason: RTPSNotification, topic: String)
}

public protocol RTPSParticipantListenerDelegate {
    func participantNotification(reason: RTPSParticipantNotification, participant: String, unicastLocators: String, properties: [String:String])
    func readerWriterNotificaton(reason: RTPSReaderWriterNotification, topic: String, type: String, remoteLocators: String)
}

public enum FastRTPSSwiftError: Error {
    case fastRTPSError
}

open class FastRTPSSwift {
    private var wrapper: FastRTPSWrapper
    fileprivate var listenerDelegate: RTPSListenerDelegate?
    fileprivate var participantListenerDelegate: RTPSParticipantListenerDelegate?
    
    public init() {
        wrapper = FastRTPSWrapper()
        setupBridgeContainer()
    }
    
    private func setupBridgeContainer()
    {
        let container = BridgeContainer(
            decoderCallback: {
                (payloadDecoder, sequence, payloadSize, payload) in
                let payloadDecoder = Unmanaged<PayloadDecoderProxy>.fromOpaque(payloadDecoder).takeUnretainedValue()
                payloadDecoder.decode(sequence: sequence,
                                      payloadSize: Int(payloadSize),
                                      payload: payload)
            }, releaseCallback: {
                (payloadDecoder) in
                Unmanaged<PayloadDecoderProxy>.fromOpaque(payloadDecoder).release()
            }, readerWriterListenerCallback: {
                (listenerObject, reason, topicName) in
                let mySelf = Unmanaged<FastRTPSSwift>.fromOpaque(listenerObject).takeUnretainedValue()
                guard let delegate = mySelf.listenerDelegate else { return }
                let topic = String(cString: topicName)
                delegate.RTPSNotification(reason: reason, topic: topic)
            }, discoveryParticipantCallback: {
                (listenerObject, reason, participantName, unicastLocators, properties) in
                let mySelf = Unmanaged<FastRTPSSwift>.fromOpaque(listenerObject).takeUnretainedValue()
                guard let delegate = mySelf.participantListenerDelegate else { return }
                var locators = ""
                var propertiesDict: [String:String] = [:]
                if let unicastLocators = unicastLocators {
                    locators = String(cString: unicastLocators)
                }
                if let properties = properties {
                    var i = 0
                    while properties[i] != nil {
                        let key = String(cString: properties[i]!)
                        let value = String(cString: properties[i+1]!)
                        propertiesDict[key] = value
                        i += 2
                    }
                }
                delegate.participantNotification(reason: reason,
                                                 participant: String(cString: participantName),
                                                 unicastLocators: locators,
                                                 properties: propertiesDict)
            }, discoveryReaderWriterCallback: {
                (listenerObject, reason, topicName, typeName, remoteLocators) in
                let mySelf = Unmanaged<FastRTPSSwift>.fromOpaque(listenerObject).takeUnretainedValue()
                guard let delegate = mySelf.participantListenerDelegate else { return }
                
                let topic = String(cString: topicName)
                let type = String(cString: typeName)
                var locators = ""
                if let remoteLocators = remoteLocators {
                    locators = String(cString: remoteLocators)
                }
                delegate.readerWriterNotificaton(reason: reason, topic: topic, type: type, remoteLocators: locators)
            }, listnerObject: Unmanaged.passUnretained(self).toOpaque())
        
        wrapper.setupBridgeContainer(container: container)
    }
    
    // MARK: Public interface
    
    /// Get Fast-DDS linked version string
    /// - Returns: version string
    public static func fastDDSVersion() -> String {
        let version = FastRTPSWrapper.fastDDSVersion()
        return String(cString: version)
    }
    
    #if FASTRTPS_WHITELIST
    /// Create a RTPS participant
    /// - Parameters:
    ///   - name: participant name
    ///   - domainID: DomainId to be used by the participant (0 by default)
    ///   - participantProfile: Defines configuration for created participant. See RTPSParticipantProfile struct
    ///   - localAddress: bind only to localAddress
    ///   - filerAddress: remote locators filter, eg "10.1.1.0/24"
    public func createParticipant(name: String,
                                  domainID: UInt32 = 0,
                                  participantProfile: RTPSParticipantProfile? = nil,
                                  localAddress: String? = nil,
                                  remoteWhitelistAddress: String? = nil) throws
    {
        let result: Bool
        if var participantProfile = participantProfile {
            result = wrapper.createParticipantFiltered(domain: domainID,
                                                       name: name.cString(using: .utf8)!,
                                                       participantProfile: &participantProfile,
                                                       localAddress: localAddress?.cString(using: .utf8),
                                                       remoteWhitelistAddress: remoteWhitelistAddress?.cString(using: .utf8))
        } else {
            result = wrapper.createParticipantFiltered(domain: domainID,
                                                       name: name.cString(using: .utf8)!,
                                                       participantProfile: nil,
                                                       localAddress: localAddress?.cString(using: .utf8),
                                                       remoteWhitelistAddress: remoteWhitelistAddress?.cString(using: .utf8))
        }
        guard result else {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    #else
    
    /// Create a RTPS participant
    /// - Parameters:
    ///   - name: participant name
    ///   - domainID: DomainId to be used by the participant (0 by default)
    ///   - participantProfile: Defines configuration for created participant. See RTPSParticipantProfile struct
    ///   - localAddress: bind only to localAddress
    public func createParticipant(name: String,
                                  domainID: UInt32 = 0,
                                  participantProfile: RTPSParticipantProfile? = nil,
                                  localAddress: String? = nil) throws
    {
        let result: Bool
        if var participantProfile = participantProfile {
            result = wrapper.createParticipant(domain: domainID,
                                               name: name.cString(using: .utf8)!,
                                               participantProfile: &participantProfile,
                                               localAddress: localAddress?.cString(using: .utf8))
        } else {
            result = wrapper.createParticipant(domain: domainID,
                                               name: name.cString(using: .utf8)!,
                                               participantProfile: nil,
                                               localAddress: localAddress?.cString(using: .utf8))
        }
        guard result else {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    #endif
    
    /// Set RTPS messages listener delegate
    /// Intercepts readers and writers messages - matching and liveliness state changes
    /// - Parameter delegate: RTPSListenerDelegate
    public func setRTPSListener(delegate: RTPSListenerDelegate?) {
        listenerDelegate = delegate
    }
    
    /// Set RTPS participant listener delegate
    /// Intercepts participant messages - discovery and remove participant;
    ///  discovery, remove and QoS change of readers and writers
    /// - Parameter delegate: RTPSParticipantListenerDelegate
    public func setRTPSParticipantListener(delegate: RTPSParticipantListenerDelegate?) {
        participantListenerDelegate = delegate
    }
    
    /// Register RTPS reader for topic with raw data callback
    /// - Parameters:
    ///   - topic: DDSReaderTopic topic description
    ///   - ddsType: DDSType topic DDS data type
    ///   - didReceive: The block to execute when topic data arrives. This block has no return value and sequence and data parameters
    ///      where sequence is topic sequence number
    ///      data is topic raw binary data
    public func registerReaderRaw<D: DDSType, T: DDSReaderTopic>(topic: T, ddsType: D.Type, partition: String? = nil, didReceive: @escaping (UInt64, Data)->Void) throws {
        let payloadDecoderProxy = Unmanaged.passRetained(PayloadDecoderProxy(didReceive: didReceive)).toOpaque()
        var profile = topic.readerProfile
        profile.keyed = ddsType is DDSKeyed.Type
        if !wrapper.registerReader(topicName: topic.rawValue.cString(using: .utf8)!,
                                   typeName: D.ddsTypeName.cString(using: .utf8)!,
                                   readerProfile: profile,
                                   payloadDecoder: payloadDecoderProxy,
                                   partition: partition?.cString(using: .utf8)!) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    /// Register a RTPS reader for topic with Result data callback
    /// - Parameters:
    ///   - topic: DDSReader topic description
    ///   - didReceive: The block to execute when topic data arrives. This block has no return value and Result<D, Error> parameter
    ///      with deserialized data when success deserialization or error otherwize
    public func registerReader<D: DDSType, T: DDSReaderTopic>(topic: T, partition: String? = nil, didReceive: @escaping (Result<D, Error>)->Void) throws {
        try registerReaderRaw(topic: topic, ddsType: D.self, partition: partition) { (_, data) in
            let decoder = CDRDecoder()
            let result = Result.init { try decoder.decode(D.self, from: data) }
            didReceive(result)
        }
    }
    
    /// Remove a RTPS reader for topic
    /// - Parameter topic: DDSReader topic descriptor
    public func removeReader<T: DDSReaderTopic>(topic: T) throws {
        if !wrapper.removeReader(topicName: topic.rawValue.cString(using: .utf8)!) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    /// Register a RTPS writer for topic
    /// Writer must be registered before send data
    /// - Parameters:
    /// - Parameter topic: DDSWriterTopic topic descriptor
    ///   - ddsType: data type descriptor
    public func registerWriter<D: DDSType, T: DDSWriterTopic>(topic: T, ddsType: D.Type, partition: String? = nil) throws  {
        var profile = topic.writerProfile
        profile.keyed = ddsType is DDSKeyed.Type
        if !wrapper.registerWriter(topicName: topic.rawValue.cString(using: .utf8)!,
                                   typeName: D.ddsTypeName.cString(using: .utf8)!,
                                   writerProfile: profile,
                                   partition: partition?.cString(using: .utf8)!) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    /// Remove RTPS writer for topic
    /// - Parameter topic: DDSWriterTopic topic descriptor
    public func removeWriter<T: DDSWriterTopic>(topic: T) throws {
        if !wrapper.removeWriter(topicName: topic.rawValue.cString(using: .utf8)!) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    /// Send data change for topic
    /// - Parameters:
    /// - Parameter topic: DDSWriter topic descriptor
    ///   - ddsData: data to be send
    public func send<D: DDSType, T: DDSWriterTopic>(topic: T, ddsData: D) throws {
        let encoder = CDREncoder()
        let data = try encoder.encode(ddsData)
        try data.withUnsafeBytes { dataPtr in
            if ddsData is DDSKeyed {
                let key = (ddsData as! DDSKeyed).key
                try key.withUnsafeBytes { keyPtr in
                    if !wrapper.sendDataWithKey(topicName: topic.rawValue.cString(using: .utf8)!,
                                                data: dataPtr.baseAddress!,
                                                length: UInt32(data.count),
                                                key: keyPtr.baseAddress!,
                                                keyLength: UInt32(key.count)) {
                        throw FastRTPSSwiftError.fastRTPSError
                    }
                }
            } else {
                if !wrapper.sendData(topicName: topic.rawValue.cString(using: .utf8)!,
                                     data: dataPtr.baseAddress!,
                                     length: UInt32(data.count)) {
                    throw FastRTPSSwiftError.fastRTPSError
                }
            }
        }
    }
    
    /// Remove all readers and writers from participant
    public func resignAll() {
        wrapper.resignAll()
    }
    
    /// Method to shut down all RTPS participants, readers, writers, etc. It may be called at the end of the process to avoid memory leaks.
    public func stopAll() {
        wrapper.stopAll()
    }
    
    /// Remove all readers/writers and then remove participant
    public func removeParticipant() {
        wrapper.removeParticipant()
    }
    
    /// Set FastRTPS log messages level
    /// - Parameter level: error, warning, info
    public func setlogLevel(_ level: FastRTPSLogLevel) {
        FastRTPSWrapper.logLevel(level: level)
    }
}
