/////
////  FastRTPSNotifications.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//


import Foundation

public extension Notification.Name {
    static let RTPSParticipantNotification = Notification.Name(RTPSParticipantNotificationName)
    static let RTPSReaderWriterNotification = Notification.Name(RTPSReaderWriterNotificationName)
}

@objc
public enum RTPSParticipantNotificationReason: Int {
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

@objc
public enum RTPSReaderWriterNotificationReason: Int {
    case readerMatchedMatching
    case readerRemovedMatching
    case readerLivelinessLost
    case writerMatchedMatching
    case writerRemovedMatching
    case writerLivelinessLost
}

