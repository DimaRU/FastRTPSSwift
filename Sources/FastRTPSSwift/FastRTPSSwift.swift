/////
////  FastRTPSSwift.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable
import FastRTPSWrapper

/// RTPS listener delegate requrements
public protocol RTPSListenerDelegate {
    /// Intercepts readers events, e.g. matching or liveliness change
    /// - Parameters:
    ///   - reason: event reason
    ///   - topic: topic name
    func RTPSReaderNotification(reason: RTPSReaderStatus, topic: String)

    /// Intercepts writers events, e.g. matching or liveliness change
    /// - Parameters:
    ///   - reason: event reason
    ///   - topic: topic name
    func RTPSWriterNotification(reason: RTPSWriterStatus, topic: String)
}

/// RTPS Participant listener delegate requrements
public protocol RTPSParticipantListenerDelegate {
    /// Intercepts paricipant discovery events
    /// - Parameters:
    ///   - reason: event reaason, see RTPSParticipantStatus
    ///   - discoveryInfo: discovered participant data
    func participantNotification(reason: RTPSParticipantDiscoveryStatus, discoveryInfo: ParticipantDiscoveryInfo)
    /// Intercepts reader discovery events
    /// - Parameters:
    ///   - reason: event reason, see RTPSReaderStatus enum
    ///   - discoveryInfo: discovered reader data
    func readerNotificaton(reason: RTPSReaderDiscoveryStatus, discoveryInfo: ReaderDiscoveryInfo)
    /// Intercepts writer discovery events
    /// - Parameters:
    ///   - reason: event reason, see RTPSWriterStatus enum
    ///   - discoveryInfo: discovered writer data
    func writerNotificaton(reason: RTPSWriterDiscoveryStatus, discoveryInfo: WriterDiscoveryInfo)
}


/// FastRTPSSwift errors enum
public enum FastRTPSSwiftError: Error {
    case fastRTPSError
}

/// Fast-DDS bridge class
open class FastRTPSSwift {
    private var wrapper: BridgedParticipant
    fileprivate var listenerDelegate: RTPSListenerDelegate?
    fileprivate var participantListenerDelegate: RTPSParticipantListenerDelegate?
    
    public init() {
        wrapper = BridgedParticipant()
        setupBridgeContainer()
    }
    
    private func setupBridgeContainer()
    {
        let decoderCallback: @convention(c) (UnsafeRawPointer, UInt64, Int32, UnsafeMutablePointer<UInt8>) -> Void = {
            payloadDecoder, sequence, payloadSize, payload in
            let payloadDecoder = Unmanaged<PayloadDecoderProxy>.fromOpaque(payloadDecoder).takeUnretainedValue()
            payloadDecoder.decode(sequence: sequence,
                                  payloadSize: Int(payloadSize),
                                  payload: payload)
        }
        
        let releaseCallback: @convention(c) (UnsafeRawPointer) -> Void = {
            payloadDecoder in
            Unmanaged<PayloadDecoderProxy>.fromOpaque(payloadDecoder).release()
        }
        
        let readerListenerCallback: @convention(c) (UnsafeRawPointer, UInt32, UnsafePointer<Int8>) -> Void = {
            listenerObject, reason, topicName in
            let mySelf = Unmanaged<FastRTPSSwift>.fromOpaque(listenerObject).takeUnretainedValue()
            guard let delegate = mySelf.listenerDelegate else { return }
            let topic = String(cString: topicName)
            delegate.RTPSReaderNotification(reason: RTPSReaderStatus(rawValue: reason)!, topic: topic)
        }

        let writerListenerCallback: @convention(c) (UnsafeRawPointer, UInt32, UnsafePointer<Int8>) -> Void = {
            listenerObject, reason, topicName in
            let mySelf = Unmanaged<FastRTPSSwift>.fromOpaque(listenerObject).takeUnretainedValue()
            guard let delegate = mySelf.listenerDelegate else { return }
            let topic = String(cString: topicName)
            delegate.RTPSWriterNotification(reason: RTPSWriterStatus(rawValue: reason)!, topic: topic)
        }

        let discoveryParticipantCallback: @convention(c) (UnsafeRawPointer, UInt32, UnsafeMutablePointer<BridgedParticipantProxyData>) -> Void = {
            listenerObject, reason, participantInfo in
            let mySelf = Unmanaged<FastRTPSSwift>.fromOpaque(listenerObject).takeUnretainedValue()
            guard let delegate = mySelf.participantListenerDelegate else { return }
            let participantDiscoveryInfo = ParticipantDiscoveryInfo(info: participantInfo)
            delegate.participantNotification(reason: RTPSParticipantDiscoveryStatus(rawValue: reason)!, discoveryInfo: participantDiscoveryInfo)
        }
        
        let discoveryReaderCallback: @convention(c) (UnsafeRawPointer, UInt32, UnsafeMutablePointer<BridgedReaderProxyData>) -> Void = {
            listenerObject, reason, info in
            let mySelf = Unmanaged<FastRTPSSwift>.fromOpaque(listenerObject).takeUnretainedValue()
            guard let delegate = mySelf.participantListenerDelegate else { return }
            let readerDiscoveryInfo = ReaderDiscoveryInfo(info: info)
            delegate.readerNotificaton(reason: RTPSReaderDiscoveryStatus(rawValue: reason)!, discoveryInfo: readerDiscoveryInfo)
        }
        
        let discoveryWriterCallback: @convention(c) (UnsafeRawPointer, UInt32,  UnsafeMutablePointer<BridgedWriterProxyData>) -> Void = {
            listenerObject, reason, writerInfo in
            let mySelf = Unmanaged<FastRTPSSwift>.fromOpaque(listenerObject).takeUnretainedValue()
            guard let delegate = mySelf.participantListenerDelegate else { return }
            let writerDiscoveryInfo = WriterDiscoveryInfo(info: writerInfo)
            delegate.writerNotificaton(reason: RTPSWriterDiscoveryStatus(rawValue: reason)!, discoveryInfo: writerDiscoveryInfo)
        }
        
        let container = BridgeContainer(
            decoderCallback: decoderCallback,
            releaseCallback: releaseCallback,
            readerListenerCallback: readerListenerCallback,
            writerListenerCallback: writerListenerCallback,
            discoveryParticipantCallback: discoveryParticipantCallback,
            discoveryReaderCallback: discoveryReaderCallback,
            discoveryWriterCallback: discoveryWriterCallback,
            listnerObject: Unmanaged.passUnretained(self).toOpaque())
        
        wrapper.setContainer(container)
    }
    
    // MARK: Public interface
    
    /// Get Fast-DDS linked version string
    /// - Returns: version string
    public static func fastDDSVersion() -> String {
        let version = fastDDSVersionString()
        return String(cString: version)
    }
    
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
        if let participantProfile = participantProfile {
            var wrapperProfile = FastRTPSWrapper.RTPSParticipantProfile.init(
                leaseDurationAnnouncementperiod: participantProfile.leaseDurationAnnouncementperiod,
                leaseDuration: participantProfile.leaseDuration,
                participantFilter: participantProfile.participantFilter.rawValue)
            result = wrapper.createParticipant(name, domainID, &wrapperProfile, localAddress)
        } else {
            result = wrapper.createParticipant(name, domainID, nil, localAddress)
        }
        guard result else {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
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
        let readerProfile = topic.readerProfile
        let wrapperProfile = FastRTPSWrapper.RTPSReaderProfile(
            keyed: readerProfile.keyed,
            reliability: FastRTPSWrapper.Reliability(rawValue: readerProfile.reliability.rawValue)!,
            durability: FastRTPSWrapper.Durability(rawValue: readerProfile.durability.rawValue)!)
        if !wrapper.addReader(topic.name,
                              topic.typeName,
                              wrapperProfile,
                              payloadDecoderProxy,
                              partition) {
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
        if !wrapper.removeReader(topic.name) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    /// Register a RTPS writer for topic
    /// Writer must be registered before send data
    /// - Parameters:
    /// - Parameter topic: DDSWriterTopic topic descriptor
    ///   - ddsType: data type descriptor
    public func registerWriter<T: DDSWriterTopic>(topic: T, partition: String? = nil) throws  {
        let writerProfile = topic.writerProfile
        let wrapperProfile = FastRTPSWrapper.RTPSWriterProfile(
            keyed: writerProfile.keyed,
            reliability: FastRTPSWrapper.Reliability(rawValue: writerProfile.reliability.rawValue)!,
            durability: FastRTPSWrapper.Durability(rawValue: writerProfile.durability.rawValue)!,
            disablePositiveACKs: writerProfile.disablePositiveACKs)
        if !wrapper.addWriter(topic.name,
                              topic.typeName,
                              wrapperProfile,
                              partition) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }
    
    /// Remove RTPS writer for topic
    /// - Parameter topic: DDSWriterTopic topic descriptor
    public func removeWriter<T: DDSWriterTopic>(topic: T) throws {
        if !wrapper.removeWriter(topic.name) {
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
        if !wrapper.send(topic.name, data.withUnsafeBytes { $0.baseAddress! }, UInt32(data.count), nil, 0) {
            throw FastRTPSSwiftError.fastRTPSError
        }
    }

    /// Send keyed data change for topic
    /// - Parameters:
    /// - Parameter topic: DDSWriter topic descriptor
    ///   - ddsData: data to be send
    public func send<D: DDSKeyed & Encodable, T: DDSWriterTopic>(topic: T, ddsData: D) throws {
        let encoder = CDREncoder()
        let data = try encoder.encode(ddsData)
        if !wrapper.send(topic.name,
                         data.withUnsafeBytes { $0.baseAddress! },
                         UInt32(data.count),
                         ddsData.key.withUnsafeBytes { $0.baseAddress! },
                         UInt32(ddsData.key.count)) {
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
        wrapper.removeRTPSParticipant()
    }
    
    /// Set FastRTPS log messages level
    /// - Parameter level: error, warning, info
    public func setlogLevel(_ level: FastRTPSLogLevel) {
        setRTPSLoglevel(FastRTPSWrapper.FastRTPSLogLevel(rawValue: level.rawValue)!)
    }
}
