/////
////  FastRTPSBridgeTests.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


import XCTest
@testable import FastRTPSBridge

class FastRTPSBridgeTests: XCTestCase {

    var fastRTPSBridge: FastRTPS?
    
    override func setUpWithError() throws {
        fastRTPSBridge = FastRTPS()
        fastRTPSBridge?.setlogLevel(.warning)
    }

    override func tearDownWithError() throws {
        fastRTPSBridge = nil
    }

    func testCreateReader() {
        fastRTPSBridge?.createParticipant(name: "TestParticipant")
        fastRTPSBridge?.registerReaderRaw(topic: ReaderTopic.rovDepth, ddsType: RovDepth.self) { (sequence, data) in
            print(sequence, data.count)
        }
        print("Reader created")
        fastRTPSBridge?.removeReader(topic: ReaderTopic.rovDepth)
        fastRTPSBridge?.removeParticipant()
    }
}
