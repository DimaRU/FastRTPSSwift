/////
////  FastRTPSSwiftTests.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


import XCTest
@testable import FastRTPSSwift

class FastRTPSSwiftTests: XCTestCase {

    var fastRTPSBridge: FastRTPSSwift?
    
    override func setUpWithError() throws {
        fastRTPSBridge = FastRTPSSwift()
        fastRTPSBridge?.setlogLevel(.warning)
    }

    override func tearDownWithError() throws {
        fastRTPSBridge = nil
    }

    func testCreateReader() throws {
        try fastRTPSBridge?.createParticipant(name: "TestParticipant")
        fastRTPSBridge?.setRTPSParticipantListener(delegate: self)
        try fastRTPSBridge?.registerReaderRaw(topic: ReaderTopic.rovDepth, ddsType: RovDepth.self) { (sequence, data) in
            print("Depth sequence, data count:", sequence, data.count)
        }
        print("Reader created")
        Thread.sleep(forTimeInterval: 2)
        try fastRTPSBridge?.removeReader(topic: ReaderTopic.rovDepth)
        fastRTPSBridge?.removeParticipant()
    }
    
    func testCreateMultipleReaders() throws {
        try fastRTPSBridge?.createParticipant(name: "TestParticipant")
        fastRTPSBridge?.setRTPSParticipantListener(delegate: self)
        try fastRTPSBridge?.registerReader(topic: ReaderTopic.rovDepth) { (depth: RovDepth) in
            print("Depth:", depth)
        }
        
        try fastRTPSBridge?.registerReader(topic: ReaderTopic.rovPressureInternal) { (baro: RovBarometer) in
            print("Barometer:", baro)
        }
        
        print("Readers created")
        fastRTPSBridge?.resignAll()
        print("Readers removed")
        fastRTPSBridge?.removeParticipant()
    }
    
    static var allTests = [
        ("testCreateReader", testCreateReader),
        ("testCreateMultipleReaders", testCreateMultipleReaders),
    ]
}

extension FastRTPSSwiftTests: RTPSParticipantListenerDelegate {
    func participantNotification(reason: RTPSParticipantNotification, participant: String, unicastLocators: String, properties: [String:String]) {
        print(reason,  participant, unicastLocators, properties)
    }
    
    func readerWriterNotificaton(reason: RTPSReaderWriterNotification, topic: String, type: String, remoteLocators: String) {
        print(reason, topic, type, remoteLocators)
    }
    
}


