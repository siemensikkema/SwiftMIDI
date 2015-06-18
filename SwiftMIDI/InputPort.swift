import CoreMIDI
import Foundation

func packetsFromPointerToPacketList(pointerToPacketList: UnsafePointer<MIDIPacketList>) -> [MIDIPacket] {
    var packets: [MIDIPacket] = []

    // get the pointer to MIDIPacket by offsetting the pointer to the MIDIPacketList 1 UInt32 ahead
    var pointerToPacket = UnsafeMutablePointer<MIDIPacket>(UnsafePointer<UInt32>(pointerToPacketList).advancedBy(1))

    for _ in 0..<pointerToPacketList.memory.numPackets {
        packets += [pointerToPacket.memory]
        pointerToPacket = MIDIPacketNext(pointerToPacket)
    }

    return packets
}

public class InputPort {
    let inputPortRef: MIDIPortRef
    let packetInput: MIDIPacketInput
    var sources: [MIDIEndpointRef] = []

    static func create(withName name: String, clientRef: MIDIClientRef, packetInput: MIDIPacketInput) throws -> InputPort {

        let inputPortRef = try getMIDIObject { pointerToMIDIPortRef in

            MIDIInputPortCreate(clientRef, name, { (pointerToPacketList, _, pointerToInputPort) -> Void in

                let inputPort = UnsafeMutablePointer<InputPort>(pointerToInputPort).memory
                inputPort.packetInput(packetsFromPointerToPacketList(pointerToPacketList))

                }, nil, pointerToMIDIPortRef)
        }

        return InputPort(inputPortRef: inputPortRef, packetInput: packetInput)
    }

    init(inputPortRef: MIDIPortRef, packetInput: MIDIPacketInput) {
        self.packetInput = packetInput
        self.inputPortRef = inputPortRef
    }

    deinit {
        MIDIPortDispose(inputPortRef)
    }

    public func connectSource(source: MIDIEndpointRef) throws {

        var localSelf = self

        try evaluateStatus {
            withUnsafeMutablePointer(&localSelf) {
                MIDIPortConnectSource(self.inputPortRef, source, $0)
            }
        }

        sources.append(source)
    }
}
