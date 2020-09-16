import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FastRTPSBridgeTests.allTests),
    ]
}
#endif
