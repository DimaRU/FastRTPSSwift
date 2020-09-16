/////
////  DDSTopic.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


import Foundation


public protocol DDSTopic: RawRepresentable where RawValue == String {
    var transientLocal: Bool { get }
    var reliable: Bool { get }
}

public protocol DDSReaderTopic: DDSTopic {}

public protocol DDSWriterTopic: DDSTopic {}
