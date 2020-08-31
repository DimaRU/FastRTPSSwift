/////
////  FastRTPS.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable

open class FastRTPS {
    public enum LogLevel: UInt32 {
        case error=0, warning, info
    }
    private var participant: UnsafeRawPointer
    
    init() {
        participant = makeBridgedParticipant({
            (payloadDecoder, sequence, payloadSize, payload) in
            let payloadDecoder = payloadDecoder as! PayloadDecoderInterface
            payloadDecoder.decode(sequence: sequence,
                                  payloadSize: Int(payloadSize),
                                  payload: payload)
        })
    }
    
     private func decoderCallback(_ payloadDecoder: UnsafeMutableRawPointer, _ sequence: UInt64, _ payloadSize: Int32, _ payload: UnsafeMutablePointer<UInt8>) {
        let payloadDecoder = payloadDecoder as! PayloadDecoderInterface
        payloadDecoder.decode(sequence: sequence,
                              payloadSize: Int(payloadSize),
                              payload: payload)
    }
    
    func createParticipant(name: String, localAddress: String? = nil, filerAddress: String? = nil) {
        createRTPSParticipantFilered(participant,
                                     name.cString(using: .utf8)!,
                                     localAddress?.cString(using: .utf8),
                                     filerAddress?.cString(using: .utf8))
    }
    
    func setPartition(name: String) {
        setRTPSPartition(participant, name.cString(using: .utf8)!)
    }

    func deleteParticipant() {
        removeRTPSParticipant(participant)
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

    func removeReader<T: DDSReaderTopic>(topic: T) {
        guard
            let payloadDecoderRaw = removeRTPSReader(participant, topic.rawValue) else { return
        }
        Unmanaged<NSObject>.fromOpaque(payloadDecoderRaw).release()
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
        removeRTPSWriter(participant,
                          topic.rawValue.cString(using: .utf8)!)
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

    func setlogLevel(_ level: LogLevel) {
        setRTPSLoglevel(.init(level.rawValue))
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