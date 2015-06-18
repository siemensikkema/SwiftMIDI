import CoreMIDI
import Foundation

/// Wrapper class for CoreMIDI's MIDIPortRef
public class InputPort {

    /// Connects a source endpoint to the port so the source's MIDI packets will be sent to the packetInput closure passed to InputPort.create.
    public func connectSource(source: MIDIEndpointRef) throws {
        try evaluateStatus {
            MIDIPortConnectSource(self.inputPortRef, source, pointerToSelf)
        }
        
        sources.append(source)
    }

    /// Designated way to create an InputPort
    static func create(withName name: String, clientRef: MIDIClientRef, packetInput: MIDIPacketInput) throws -> InputPort {

        let inputPortRef = try getMIDIObject { pointerToMIDIPortRef in

            MIDIInputPortCreate(clientRef, name, { (pointerToPacketList, _, pointerToInputPort) -> Void in

                // get InputPort instance from pointer
                let inputPort = UnsafeMutablePointer<InputPort>(pointerToInputPort).memory

                // extract MIDI packets from packet list and send them to the InportPort's packet input
                inputPort.packetInput(packetsFromPointerToPacketList(pointerToPacketList))

                }, nil, pointerToMIDIPortRef)
        }

        return InputPort(inputPortRef: inputPortRef, packetInput: packetInput)
    }

    // MARK: - Internal

    func breakReferenceCycle() {
        pointerToSelf.destroy(1)
    }

    // MARK: - Private
    private init(inputPortRef: MIDIPortRef, packetInput: MIDIPacketInput) {
        self.packetInput = packetInput
        self.inputPortRef = inputPortRef
        pointerToSelf = UnsafeMutablePointer.alloc(1)

        pointerToSelf.memory = self
    }

    deinit {
        MIDIPortDispose(inputPortRef)
    }

    private let inputPortRef: MIDIPortRef
    private let packetInput: MIDIPacketInput
    private var sources: [MIDIEndpointRef] = []

    /// Used to identify the InputPort instance in the MIDI read proc
    private let pointerToSelf: UnsafeMutablePointer<InputPort>
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
