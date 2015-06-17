import CoreMIDI

public class Client {
    let clientRef: MIDIClientRef
    public var inputPorts: [InputPort] = []

    public static func create(withName name: String = "com.swiftmidi.client") throws -> Client {
        return try Client(clientRef: createMIDIObject {
            return MIDIClientCreate(name, { (pointerToMIDINotification, _) in
                MIDIStateChange(notificationPointer: pointerToMIDINotification)
                }, nil, $0)
            })
    }

    init(clientRef: MIDIClientRef) {
        self.clientRef = clientRef
    }

    deinit {
        MIDIClientDispose(clientRef)
    }

    func name() throws -> String? {
        let name = try getMIDIObjectProperty {
            return MIDIObjectGetStringProperty(clientRef, kMIDIPropertyName, $0)
        }
        return name as String?
    }

    public func addInputPort(packetInput: MIDIPacketInput) throws {
        try inputPorts.append(InputPort.create(withName: "\(name()).port\(inputPorts.count)", clientRef: clientRef, packetInput: packetInput))
    }
}
