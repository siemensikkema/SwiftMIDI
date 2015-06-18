import XCTest
import CoreMIDI
@testable import SwiftMIDI

class SwiftMIDITests: XCTestCase {

    func testInputPort() {
        do {
            let e = expectationWithDescription("Wait for user input")
            let client = try Client.create()
            try client.addInputPort { packets in

                for packet in packets {
                    print(packet.timeStamp)
                }

                dispatch_async(dispatch_get_main_queue()) {
                    e.fulfill()
                }
            }

            if let inputPort = client.inputPorts.first where MIDIGetNumberOfSources() > 0 {
                try inputPort.connectSource(MIDIGetSource(0))
                print(inputPort)
            }
            waitForExpectationsWithTimeout(30, handler: nil)
        } catch {
            print(error)
        }
    }
}
