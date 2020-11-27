/////
////  DDSTopic.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


import Foundation

public protocol DDSTopic: RawRepresentable where RawValue == String {}

public protocol DDSReaderTopic: DDSTopic {
    var readerParams: ReaderParams { get }
}

public protocol DDSWriterTopic: DDSTopic {
    var writerParams: WriterParams { get }
}
