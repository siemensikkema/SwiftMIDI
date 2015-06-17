import CoreMIDI
import Foundation

public typealias MIDIPacketInput = [MIDIPacket] -> Void

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

/// packet input closures for each input port
var availablePacketInputIndex = 0
public var packetInputs: [Int: MIDIPacketInput] = [:]

public class InputPort {
    let inputPortRef: MIDIPortRef
    let packetInputIndex: Int
    var sources: [MIDIEndpointRef] = []

    static func create(withName name: String, clientRef: MIDIClientRef, packetInput: MIDIPacketInput) throws -> InputPort {

        // register packet input closure while ensuring thread safety
        objc_sync_enter(availablePacketInputIndex)
        defer { objc_sync_exit(availablePacketInputIndex) }
        packetInputs[availablePacketInputIndex++] = packetInput

        let inputPortRef = try createMIDIObject { pointerToMIDIPortRef in
            withUnsafeMutablePointer(&availablePacketInputIndex) { pointerToIndex in

                MIDIInputPortCreate(clientRef, name, { (pointerToPacketList, _, pointerToIndex) -> Void in

                    packetInputs[0]?([])

//                    let index = UnsafePointer<Int>(pointerToIndex).memory
//                    if let packetInput = packetInputs[index] {
//                        packetInput(packetsFromPointerToPacketList(pointerToPacketList))
//                    }
                    }, pointerToIndex, pointerToMIDIPortRef)
            }
        }

        return InputPort(inputPortRef: inputPortRef, packetInputIndex: availablePacketInputIndex)
    }

    init(inputPortRef: MIDIPortRef, packetInputIndex: Int) {
        self.packetInputIndex = packetInputIndex
        self.inputPortRef = inputPortRef
    }

    deinit {
        MIDIPortDispose(inputPortRef)
        packetInputs[packetInputIndex] = nil
    }

    public func connectSource(source: MIDIEndpointRef) throws {
        var p = packetInputIndex
        try evaluateStatus {
            withUnsafeMutablePointer(&p) {
                MIDIPortConnectSource(self.inputPortRef, source, $0)
            }
        }

        sources.append(source)
    }
}
