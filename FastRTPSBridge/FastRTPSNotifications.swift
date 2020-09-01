/////
////  FastRTPSNotifications.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//


import Foundation

public extension FastRTPS {
    @frozen
    enum RTPSParticipantNotification: Int {
        case discoveredReader
        case changedQosReader
        case removedReader
        case discoveredWriter
        case changedQosWriter
        case removedWriter
        case discoveredParticipant
        case changedQosParticipant
        case removedParticipant
        case droppedParticipant
    }

    @frozen
    enum RTPSNotification: Int {
        case readerMatchedMatching
        case readerRemovedMatching
        case readerLivelinessLost
        case writerMatchedMatching
        case writerRemovedMatching
        case writerLivelinessLost
    }

    @frozen
    enum RTPSNotificationKey: Int {
        case participant
        case reason
        case topic
        case locators
        case metaLocators
        case properties
        case typeName
    }
}
