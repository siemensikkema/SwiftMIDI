import CoreMIDI

public class Client {
    public var inputPorts: [InputPort] = []

    public static func create(withName name: String = "com.swiftmidi.client") throws -> Client {
        return try Client(clientRef: getMIDIObject {
            return MIDIClientCreate(name, { (pointerToMIDINotification, _) in
                MIDIStateChange(notificationPointer: pointerToMIDINotification)
                }, nil, $0)
            })
    }

    public func addInputPort(packetInput: MIDIPacketInput) throws {
        try inputPorts.append(InputPort.create(withName: "\(name()).port\(inputPorts.count)", clientRef: clientRef, packetInput: packetInput))
    }

    private init(clientRef: MIDIClientRef) {
        self.clientRef = clientRef
    }

    deinit {
        MIDIClientDispose(clientRef)
        for inputPort in inputPorts {
            inputPort.breakReferenceCycle()
        }
    }

    private let clientRef: MIDIClientRef

    private func name() throws -> String? {
        let name = try getMIDIObject {
            return MIDIObjectGetStringProperty(clientRef, kMIDIPropertyName, $0)
        }
        return name as String?
    }
}
