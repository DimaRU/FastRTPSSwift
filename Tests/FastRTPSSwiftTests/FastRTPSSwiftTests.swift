/////
////  FastRTPSSwiftTests.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


import XCTest
@testable import FastRTPSSwift

class FastRTPSSwiftTests: XCTestCase {

    var fastRTPSSwift: FastRTPSSwift?
    
    override func setUpWithError() throws {
        fastRTPSSwift = FastRTPSSwift()
        fastRTPSSwift?.setlogLevel(.warning)
    }

    override func tearDownWithError() throws {
        fastRTPSSwift = nil
    }

    func testCreateReader() throws {
        try fastRTPSSwift?.createParticipant(name: "TestParticipant")
        fastRTPSSwift?.setRTPSParticipantListener(delegate: self)
        try fastRTPSSwift?.registerReaderRaw(topic: ReaderTopic.rovDepth, partition: "*") { (sequence, data) in
            print("Depth sequence, data count:", sequence, data.count)
        }
        print("Reader created")
        Thread.sleep(forTimeInterval: 2)
        try fastRTPSSwift?.removeReader(topic: ReaderTopic.rovDepth)
        fastRTPSSwift?.removeParticipant()
    }
    
    func testCreateMultipleReaders() throws {
        try fastRTPSSwift?.createParticipant(name: "TestParticipant")
        fastRTPSSwift?.setRTPSParticipantListener(delegate: self)
        try fastRTPSSwift?.registerReader(topic: ReaderTopic.rovDepth, partition: "*") { (result: Result<RovDepth, Error>) in
            switch result {
            case .success(let depth):
                print("Depth:", depth)
            case .failure(let error):
                print(error)
            }
        }
        
        try fastRTPSSwift?.registerReader(topic: ReaderTopic.rovPressureInternal, partition: "*") { (result: Result<RovBarometer, Error>) in
            switch result {
            case .success(let baro):
                print("Barometer:", baro)
            case .failure(let error):
                print(error)
            }
        }
        
        print("Readers created")
        Thread.sleep(forTimeInterval: 2)
        fastRTPSSwift?.resignAll()
        print("Readers removed")
        fastRTPSSwift?.removeParticipant()
    }
}

extension FastRTPSSwiftTests: RTPSParticipantListenerDelegate {
    func participantNotification(reason: RTPSParticipantDiscoveryStatus, discoveryInfo: ParticipantDiscoveryInfo) {
        print(reason, discoveryInfo.name, discoveryInfo.unicastLocators, discoveryInfo.properties, discoveryInfo.guid)
    }
    
    func readerNotificaton(reason: RTPSReaderDiscoveryStatus, discoveryInfo: ReaderDiscoveryInfo) {
        print(reason, discoveryInfo.topicName, discoveryInfo.typeName, discoveryInfo.unicastLocators, discoveryInfo.profile, discoveryInfo.guid)
    }
    
    func writerNotificaton(reason: RTPSWriterDiscoveryStatus, discoveryInfo: WriterDiscoveryInfo) {
        print(reason, discoveryInfo.topicName, discoveryInfo.typeName, discoveryInfo.unicastLocators, discoveryInfo.profile, discoveryInfo.guid)
    }
    
}
