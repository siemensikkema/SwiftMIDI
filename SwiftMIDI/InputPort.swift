import CoreMIDI
import Foundation

public class InputPort {

    public func connectSource(source: MIDIEndpointRef) throws {
        try evaluateStatus {
            MIDIPortConnectSource(self.inputPortRef, source, pointerToSelf)
        }
        
        sources.append(source)
    }

    static func create(withName name: String, clientRef: MIDIClientRef, packetInput: MIDIPacketInput) throws -> InputPort {
        let inputPortRef = try getMIDIObject { pointerToMIDIPortRef in

            MIDIInputPortCreate(clientRef, name, { (pointerToPacketList, _, srcConnRefCon) -> Void in

                let inputPort = UnsafeMutablePointer<InputPort>(srcConnRefCon).memory
                inputPort.packetInput(packetsFromPointerToPacketList(pointerToPacketList))
                }, nil, pointerToMIDIPortRef)
        }

        return InputPort(inputPortRef: inputPortRef, packetInput: packetInput)
    }
    
    func breakReferenceCycle() {
        pointerToSelf.destroy(1)
    }

    private let inputPortRef: MIDIPortRef
    private let packetInput: MIDIPacketInput
    private var sources: [MIDIEndpointRef] = []

    /// This pointer is used to identify the InputPort instance in the
    private let pointerToSelf: UnsafeMutablePointer<InputPort>

    private init(inputPortRef: MIDIPortRef, packetInput: MIDIPacketInput) {
        self.packetInput = packetInput
        self.inputPortRef = inputPortRef
        pointerToSelf = UnsafeMutablePointer.alloc(1)
        pointerToSelf.memory = self
    }

    deinit {
        MIDIPortDispose(inputPortRef)
    }
}

private func packetsFromPointerToPacketList(pointerToPacketList: UnsafePointer<MIDIPacketList>) -> [MIDIPacket] {
    var packets: [MIDIPacket] = []

    // get the pointer to MIDIPacket by advancing the pointer to the MIDIPacketList by 1 UInt32 to skip the numPackets field
    var pointerToPacket = UnsafeMutablePointer<MIDIPacket>(UnsafePointer<UInt32>(pointerToPacketList).advancedBy(1))

    for _ in 0..<pointerToPacketList.memory.numPackets {
        packets += [pointerToPacket.memory]
        pointerToPacket = MIDIPacketNext(pointerToPacket)
    }

    return packets
}
