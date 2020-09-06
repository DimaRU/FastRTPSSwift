/////
////  FastRTPS.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable

public protocol RTPSListenerDelegate {
    func RTPSNotification(reason: RTPSNotification, topic: String)
}

public protocol RTPSParticipantListenerDelegate {
    func participantNotification(reason: RTPSParticipantNotification, participant: String, unicastLocators: [String], properties: [String:String])
    func readerWriterNotificaton(reason: RTPSReaderWriterNotification, topic: String, type: String, remoteLocators: [String])
}

open class FastRTPS {
    private var participant: UnsafeRawPointer
    fileprivate var listenerDelegate: RTPSListenerDelegate?
    fileprivate var participantListenerDelegate: RTPSParticipantListenerDelegate?
    
    init() {
        participant = makeBridgedParticipant()
    }
    
    func setupBridgeContainer()
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
            let mySelf = Unmanaged<FastRTPS>.fromOpaque(listenerObject).takeUnretainedValue()
            guard let delegate = mySelf.listenerDelegate else { return }
            let topic = String(cString: topicName)
            delegate.RTPSNotification(reason: reason, topic: topic)
        }, discoveryParticipantCallback: {
            (listenerObject, reason, participantName, unicastLocators, properties) in
            let mySelf = Unmanaged<FastRTPS>.fromOpaque(listenerObject).takeUnretainedValue()
            guard let delegate = mySelf.participantListenerDelegate else { return }
            var unicastLocatorsArr: [String] = []
            var propertiesDict: [String:String] = [:]
            if let unicastLocators = unicastLocators {
                var i = 0
                while unicastLocators[i] != nil {
                    unicastLocatorsArr.append(String(cString: unicastLocators[i]!))
                    i += 1
                }
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
                                             unicastLocators: unicastLocatorsArr,
                                             properties: propertiesDict)
        }, discoveryReaderWriterCallback: {
            (listenerObject, reason, topicName, typeName, remoteLocators) in
            let mySelf = Unmanaged<FastRTPS>.fromOpaque(listenerObject).takeUnretainedValue()
            guard let delegate = mySelf.participantListenerDelegate else { return }
            
            let topic = String(cString: topicName)
            let type = String(cString: typeName)
            var locators: [String] = []
            if let remoteLocators = remoteLocators {
                var i = 0
                while remoteLocators[i] != nil {
                    locators.append(String(cString: remoteLocators[i]!))
                    i += 1
                }
            }
            delegate.readerWriterNotificaton(reason: reason, topic: topic, type: type, remoteLocators: locators)
        }, listnerObject: Unmanaged.passUnretained(self).toOpaque())
        
        setupRTPSBridgeContainer(participant, container)
    }

    // MARK: Public interface

    
    /// Create RTPS participant
    /// - Parameters:
    ///   - name: participant name
    ///   - domainID: participant domain ID
    ///   - localAddress: bind only to localAddress
    ///   - filerAddress: remote locators filter, eg "10.1.1.0/24"
    func createParticipant(name: String, domainID: UInt32 = 0, localAddress: String? = nil, filerAddress: String? = nil) {
        setupBridgeContainer()
        createRTPSParticipantFilered(participant,
                                     domainID,
                                     name.cString(using: .utf8)!,
                                     localAddress?.cString(using: .utf8),
                                     filerAddress?.cString(using: .utf8))
    }

    func setRTPSListener(delegate: RTPSListenerDelegate?) {
        listenerDelegate = delegate
    }
    
    func setRTPSParticipantListener(delegate: RTPSParticipantListenerDelegate?) {
        participantListenerDelegate = delegate
    }
    
    func setPartition(name: String) {
        setRTPSPartition(participant, name.cString(using: .utf8)!)
    }
    
    /// Remove all readers/writers and then delete participant
    func deleteParticipant() {
        removeRTPSParticipant(participant)
    }

    func registerReaderRaw<D: DDSType, T: DDSReaderTopic>(topic: T, ddsType: D.Type, completion: @escaping (UInt64, Data)->Void) {
        let payloadDecoderProxy = Unmanaged.passRetained(PayloadDecoderProxy(completion: completion)).toOpaque()
        registerRTPSReader(participant,
                           topic.rawValue.cString(using: .utf8)!,
                           D.ddsTypeName.cString(using: .utf8)!,
                           D.isKeyed,
                           topic.transientLocal,
                           topic.reliable,
                           payloadDecoderProxy)
    }
    
    func registerReader<D: DDSType, T: DDSReaderTopic>(topic: T, completion: @escaping (Result<D, Error>)->Void) {
        registerReaderRaw(topic: topic, ddsType: D.self) { (_, data) in
            let decoder = CDRDecoder()
            let result = Result.init { try decoder.decode(D.self, from: data) }
            completion(result)
        }
    }
    
    func registerReader<D: DDSType, T: DDSReaderTopic>(topic: T, completion: @escaping (D)->Void) {
        registerReaderRaw(topic: topic, ddsType: D.self) { (_, data) in
            let decoder = CDRDecoder()
            do {
                let t = try decoder.decode(D.self, from: data)
                completion(t)
            } catch {
                print(topic.rawValue, error)
            }
        }
    }
    
    func removeReader<T: DDSReaderTopic>(topic: T) {
        removeRTPSReader(participant, topic.rawValue.cString(using: .utf8)!)
    }
    
    func registerWriter<D: DDSType, T: DDSWriterTopic>(topic: T, ddsType: D.Type)  {
        registerRTPSWriter(participant,
                            topic.rawValue.cString(using: .utf8)!,
                            D.ddsTypeName.cString(using: .utf8)!,
                            D.isKeyed,
                            topic.transientLocal,
                            topic.reliable)
    }
    
    func removeWriter<T: DDSReaderTopic>(topic: T) {
        removeRTPSWriter(participant, topic.rawValue.cString(using: .utf8)!)
    }

    func send<D: DDSType, T: DDSWriterTopic>(topic: T, ddsData: D) {
        let encoder = CDREncoder()
        do {
            var data = try encoder.encode(ddsData)
            if ddsData is DDSKeyed {
                var key = (ddsData as! DDSKeyed).key
                if key.isEmpty {
                    key = Data([0])
                }
                sendDataWithKey(participant,
                                topic.rawValue.cString(using: .utf8)!,
                                &data,
                                UInt32(data.count),
                                &key,
                                UInt32(key.count))
            } else {
                sendData(participant,
                         topic.rawValue.cString(using: .utf8)!,
                         &data,
                         UInt32(data.count))
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func resignAll() {
        resignRTPSAll(participant)
    }
    
    func removeParticipant() {
        removeRTPSParticipant(participant)
    }

    func setlogLevel(_ level: FastRTPSLogLevel) {
        setRTPSLoglevel(level)
    }
    
    class func getIP4Address() -> [String: String] {
        var localIP: [String: String] = [:]

        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else { return localIP }
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }

            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                let name: String = String(cString: (interface!.ifa_name))
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                let address = String(cString: hostname)
                localIP[name] = address
            }
        }
        freeifaddrs(ifaddr)

        return localIP
    }
    
    class func getIP6Address() -> [String: String] {
        var localIP: [String: String] = [:]

        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else { return localIP }
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }

            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET6) {
                let name: String = String(cString: (interface!.ifa_name))
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                let address = String(cString: hostname)
                localIP[name] = address
            }
        }
        freeifaddrs(ifaddr)

        return localIP
    }
}
