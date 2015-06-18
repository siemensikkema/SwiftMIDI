import XCTest
import AppKit
import CoreMIDI
@testable import SwiftMIDIMac

class SwiftMIDITests: XCTestCase {

    func testInputPort() {
        do {
            expectationWithDescription("")
            let client = try Client.create()
            try client.addInputPort { packets in
                print(packets.count)
             }

            if let inputPort = client.inputPorts.first { //where MIDIGetNumberOfSources() > 0 {
                try inputPort.connectSource(MIDIGetSource(0))
                print(inputPort)
            }
            waitForExpectationsWithTimeout(30, handler: nil)
        } catch {
            print(error)
        }
    }
}
