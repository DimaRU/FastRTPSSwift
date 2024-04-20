/////
////  FastRTPSEnum.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

public enum RTPSReaderStatus: UInt32 {
    case discovered = 0
    case changedQos
    case removed
    case ignored
}

public enum RTPSWriterStatus: UInt32 {
    case discovered = 0
    case changedQos
    case removed
    case ignored
}

public enum RTPSStatus: UInt32 {
    case readerMatchedMatching = 0
    case readerRemovedMatching
    case readerLivelinessLost
    case writerMatchedMatching
    case writerRemovedMatching
    case writerLivelinessLost
}

public enum RTPSParticipantStatus: UInt32 {
    case discovered = 0
    case changedQos
    case removed
    case dropped
    case ignored
}
