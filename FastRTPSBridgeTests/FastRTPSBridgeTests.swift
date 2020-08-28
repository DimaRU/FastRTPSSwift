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
        fastRTPSBridge?.setlogLevel(LogLevel(1))
    }

    override func tearDownWithError() throws {
        fastRTPSBridge = nil
    }

    func testCreateReader() {
        fastRTPSBridge?.createParticipant(name: "TestParticipant")
        fastRTPSBridge?.registerReader(topic: ReaderTopic.rovDepth) { (rovDepth: RovDepth) in
            print(rovDepth)
        }
        print("Reader created")
        fastRTPSBridge?.removeReader(topic: ReaderTopic.rovDepth)
        fastRTPSBridge?.removeParticipant()
    }
}
