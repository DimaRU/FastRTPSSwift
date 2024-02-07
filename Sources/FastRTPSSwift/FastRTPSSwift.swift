/////
////  FastRTPSSwift.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable

#if SWIFT_PACKAGE
@_exported import FastRTPSWrapper
#endif

/// RTPS listener delegate requrements
public protocol RTPSListenerDelegate {
    /// Intercepts readers and writers events, e.g. matching or liveliness change
    /// - Parameters:
    ///   - reason: event reason
    ///   - topic: topic name
    func RTPSNotification(reason: RTPSStatus, topic: String)
}

/// RTPS Participant listener delegate requrements
public protocol RTPSParticipantListenerDelegate {
    /// Intercepts paricipant discovery events
    /// - Parameters:
    ///   - reason: event reaason, see RTPSParticipantStatus
    ///   - participant: participant name
    ///   - unicastLocators: participant unicast locators list
    ///   - properties: participant properties strings
    func participantNotification(reason: RTPSParticipantStatus, participant: String, unicastLocators: String, properties: [String:String])
    /// Intercepts reader discovery events
    /// - Parameters:
    ///   - reason: event reason, see RTPSReaderStatus enum
    ///   - topic: topic name
    ///   - type: topic data type name
    ///   - remoteLocators: remote locators list
    ///   - readerProfile: reader qos data
    func readerNotificaton(reason: RTPSReaderStatus, topic: String, type: String, remoteLocators: String, readerProfile: RTPSReaderProfile)
    /// Intercepts writer discovery events
    /// - Parameters:
    ///   - reason: event reason, see RTPSWriterStatus enum
    ///   - topic: topic name
    ///   - type: topic data type name
    ///   - remoteLocators: remote locators list
    ///   - writerProfile: writer qos data
    func writerNotificaton(reason: RTPSWriterStatus, topic: String, type: String, remoteLocators: String, writerProfile: RTPSWriterProfile)
}

/// FastRTPSSwift errors enum
public enum FastRTPSSwiftError: Error {
    case fastRTPSError
}

/// Fast-DDS bridge class
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
            }, discoveryReaderCallback: {
                (listenerObject, reason, readerInfo) in
                let mySelf = Unmanaged<FastRTPSSwift>.fromOpaque(listenerObject).takeUnretainedValue()
                guard let delegate = mySelf.participantListenerDelegate else { return }
                
                let topic = String(cString: readerInfo.pointee.topic)
                let type = String(cString: readerInfo.pointee.ddstype)
                var locators = ""
                if let remoteLocators = readerInfo.pointee.locators {
                    locators = String(cString: remoteLocators)
                }
                let readerProfile = RTPSReaderProfile(keyed: readerInfo.pointee.readerProfile.keyed,
                                                      reliability: readerInfo.pointee.readerProfile.reliability,
                                                      durability: readerInfo.pointee.readerProfile.durability)
                delegate.readerNotificaton(reason: reason, topic: topic, type: type, remoteLocators: locators, readerProfile: readerProfile)
            }, discoveryWriterCallback: {
                (listenerObject, reason, writerInfo) in
                let mySelf = Unmanaged<FastRTPSSwift>.fromOpaque(listenerObject).takeUnretainedValue()
                guard let delegate = mySelf.participantListenerDelegate else { return }
                
                let topic = String(cString: writerInfo.pointee.topic)
                let type = String(cString: writerInfo.pointee.ddstype)
                var locators = ""
                if let remoteLocators = writerInfo.pointee.locators {
                    locators = String(cString: remoteLocators)
                }
                let writerProfile = RTPSWriterProfile(keyed: writerInfo.pointee.writerProfile.keyed,
                                                      reliability: writerInfo.pointee.writerProfile.reliability,
                                                      durability: writerInfo.pointee.writerProfile.durability,
                                                      disablePositiveACKs: writerInfo.pointee.writerProfile.disablePositiveACKs)
                delegate.writerNotificaton(reason: reason, topic: topic, type: type, remoteLocators: locators, writerProfile: writerProfile)
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
                                                       name: name,
                                                       participantProfile: &participantProfile,
                                                       localAddress: localAddress,
                                                       remoteWhitelistAddress: remoteWhitelistAddress)
        } else {
            result = wrapper.createParticipantFiltered(domain: domainID,
                                                       name: name,
                                                       participantProfile: nil,
                                                       localAddress: localAddress,
                                                       remoteWhitelistAddress: remoteWhitelistAddress)
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
    ///   - localAddress: bind only to localAddress, nil by default
    public func createParticipant(name: String,
                                  domainID: UInt32 = 0,
                                  participantProfile: RTPSParticipantProfile? = nil,
                                  localAddress: String? = nil) throws
    {
        let result: Bool
        if var participantProfile = participantProfile {
            result = wrapper.createParticipant(domain: domainID,
                                               name: name,
                                               participantProfile: &participantProfile,
                                               localAddress: localAddress)
        } else {
            result = wrapper.createParticipant(domain: domainID,
                                               name: name,
                                               participantProfile: nil,
                                               localAddress: localAddress)
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
    ///   - block: The block to execute when topic data arrives. This block has no return value and sequence and data parameters:
    ///      - sequence: topic sequence number
    ///      - data: topic raw binary data
    public func registerReaderRaw<T: DDSReaderTopic>(topic: T, partition: String? = nil, block: @escaping (UInt64, Data)->Void) throws {
        let payloadDecoderProxy = Unmanaged.passRetained(PayloadDecoderProxy(block: block)).toOpaque()
        if !wrapper.registerReader(topicName: topic.name,
                                   typeName: topic.typeName,
                                   readerProfile: topic.readerProfile,
                                   payloadDecoder: payloadDecoderProxy,
                                   partition: partition) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    /// Register a RTPS reader for topic with Result data callback
    /// - Parameters:
    ///   - topic: DDSReader topic description
    ///   - block: The block to execute when topic data arrives. This block has no return value and Result<D, Error> parameter
    ///      with deserialized data when success deserialization or error otherwize
    public func registerReader<D: Decodable, T: DDSReaderTopic>(topic: T, partition: String? = nil, block: @escaping (Result<D, Error>)->Void) throws {
        try registerReaderRaw(topic: topic, partition: partition) { (_, data) in
            let decoder = CDRDecoder()
            let result = Result.init { try decoder.decode(D.self, from: data) }
            block(result)
        }
    }
    
    /// Remove a RTPS reader for topic
    /// - Parameter topic: DDSReader topic descriptor
    public func removeReader<T: DDSReaderTopic>(topic: T) throws {
        if !wrapper.removeReader(topicName: topic.name) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    /// Register a RTPS writer for topic
    /// Writer must be registered before send data
    /// - Parameters:
    /// - Parameter topic: DDSWriterTopic topic descriptor
    ///   - ddsType: data type descriptor
    public func registerWriter<T: DDSWriterTopic>(topic: T, partition: String? = nil) throws  {
        if !wrapper.registerWriter(topicName: topic.name,
                                   typeName: topic.typeName,
                                   writerProfile: topic.writerProfile,
                                   partition: partition) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    /// Remove RTPS writer for topic
    /// - Parameter topic: DDSWriterTopic topic descriptor
    public func removeWriter<T: DDSWriterTopic>(topic: T) throws {
        if !wrapper.removeWriter(topicName: topic.name) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    /// Send unkeyed data change for topic
    /// - Parameters:
    /// - Parameter topic: DDSWriter topic descriptor
    ///   - ddsData: data to be send
    public func send<D: Encodable, T: DDSWriterTopic>(topic: T, ddsData: D) throws {
        let encoder = CDREncoder()
        let data = try encoder.encode(ddsData)
        try data.withUnsafeBytes { dataPtr in
            if !wrapper.sendData(topicName: topic.name,
                                 data: dataPtr.baseAddress!,
                                 length: UInt32(data.count)) {
                throw FastRTPSSwiftError.fastRTPSError
            }
        }
    }

    /// Send keyed data change for topic
    /// - Parameters:
    /// - Parameter topic: DDSWriter topic descriptor
    ///   - ddsData: data to be send
    public func send<D: DDSKeyed & Encodable, T: DDSWriterTopic>(topic: T, ddsData: D) throws {
        let encoder = CDREncoder()
        let data = try encoder.encode(ddsData)
        if !wrapper.sendDataWithKey(topicName: topic.name,
                                    data: data.withUnsafeBytes { $0.baseAddress! },
                                    length: UInt32(data.count),
                                    key: ddsData.key.withUnsafeBytes { $0.baseAddress! },
                                    keyLength: UInt32(ddsData.key.count)) {
            throw FastRTPSSwiftError.fastRTPSError
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
