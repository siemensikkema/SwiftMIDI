import XCPlayground
import CoreMIDI

XCPSetExecutionShouldContinueIndefinitely(true)

func evaluateStatus(closure: Void -> OSStatus) throws {
    let status = closure()

    if status != noErr {
        throw SwiftMIDIError(status: status)
    }
}

func createMIDIObject<T>(createClosure: UnsafeMutablePointer<T> -> OSStatus) throws -> T {
    let pointerToMIDIObject = UnsafeMutablePointer<T>.alloc(1)
    defer { pointerToMIDIObject.destroy() }

    try evaluateStatus { createClosure(pointerToMIDIObject) }

    return pointerToMIDIObject.memory
}

func getMIDIObjectProperty<T>(createClosure: UnsafeMutablePointer<Unmanaged<T>?> -> OSStatus) throws -> T? {
    var t: Unmanaged<T>? = .None
    defer { t?.release() }

    try evaluateStatus {
        withUnsafeMutablePointer(&t) {
            return createClosure($0)
        }
    }

    return t?.takeUnretainedValue()
}

class Client {
    let clientRef: MIDIClientRef
    var inputPorts: [InputPort] = []

    static func create(withName name: String = "com.swiftmidi.client") throws -> Client {
        return try Client(clientRef: createMIDIObject {
            return MIDIClientCreate(name, { (pointerToMIDINotification, _) in
                MIDIStateChange(notificationPointer: pointerToMIDINotification)
                }, nil, $0)
        })
    }

    init(clientRef: MIDIClientRef) {
        self.clientRef = clientRef
    }

    func name() throws -> String? {
        let name = try getMIDIObjectProperty {
            return MIDIObjectGetStringProperty(self.clientRef, kMIDIPropertyName, $0)
        }
        return name as String?
    }

    func addInputPort() throws {
        try inputPorts.append(InputPort.create(withName: "\(name()).port\(inputPorts.count)", clientRef: clientRef))
    }
}

func packetsFromPointerToPacketList(pointerToPacketList: UnsafePointer<MIDIPacketList>) -> [MIDIPacket] {
    var packets: [MIDIPacket] = []
    let numPackets = pointerToPacketList.memory.numPackets // store before re-initing the packet list
    let pointerToPacket = MIDIPacketListInit(UnsafeMutablePointer(pointerToPacketList))

    for _ in 0..<numPackets {
        packets.append(pointerToPacket.memory)
        MIDIPacketNext(pointerToPacket)
    }

    pointerToPacket.destroy(Int(numPackets))

    return packets
}

class InputPort {
    let inputPortRef: MIDIPortRef
    var sources: [MIDIEndpointRef] = []

    static func create(withName name: String, clientRef: MIDIClientRef) throws -> InputPort {
        return try InputPort(inputPortRef: createMIDIObject {
            return MIDIInputPortCreate(clientRef, name, { (pointerToPacketList, _, _) in

                let packets = packetsFromPointerToPacketList(pointerToPacketList)

                for packet in packets {
                    packet.timeStamp
                }
                }, nil, $0)
            })
    }

    init(inputPortRef: MIDIPortRef) {
        self.inputPortRef = inputPortRef
    }

    func connectSource(source: MIDIEndpointRef) throws {
        try evaluateStatus {
            MIDIPortConnectSource(self.inputPortRef, source, nil)
        }

        sources.append(source)
    }
}

do {
    let client = try Client.create()
    try client.addInputPort()

    if let inputPort = client.inputPorts.first where MIDIGetNumberOfSources() > 0 {
        try inputPort.connectSource(MIDIGetSource(0))
    }
} catch {
    print(error)
}

