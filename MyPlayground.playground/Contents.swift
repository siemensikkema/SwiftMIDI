import XCPlayground
import CoreMIDI

XCPSetExecutionShouldContinueIndefinitely(true)

do {
    let client = try Client.create()
    try client.addInputPort { packets in
        ""
        packets.count
        for packet in packets {
            packet.timeStamp
        }
    }

    if let inputPort = client.inputPorts.first where MIDIGetNumberOfSources() > 0 {
        try inputPort.connectSource(MIDIGetSource(0))
        inputPort

    }
} catch {
    error
}

