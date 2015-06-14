import XCPlayground
import CoreMIDI

XCPSetExecutionShouldContinueIndefinitely(true)

protocol Initable {
     init()
}

extension MIDIObjectRef: Initable {}

func createMIDIObject<T: Initable>(createClosure: UnsafeMutablePointer<T> -> OSStatus) throws -> T {
    var t = T()
    let status = withUnsafeMutablePointer(&t) {
        return createClosure($0)
    }
    if status == noErr {
        return t
    } else {
        throw SwiftMIDIError(status: status)
    }
}

func getMIDIObjectProperty<T>(createClosure: UnsafeMutablePointer<Unmanaged<T>?> -> OSStatus) throws -> T? {
    var t: Unmanaged<T>? = .None
    let status = withUnsafeMutablePointer(&t) {
        return createClosure($0)
    }
    if status == noErr {
        return t?.takeUnretainedValue()
    } else {
        throw SwiftMIDIError(status: status)
    }
}

class Client {

    let clientRef: MIDIObjectRef
    var inputPorts: [InputPort] = []

    init(clientName: String = "com.swiftmidi.client") throws {
        do {
            try clientRef = createMIDIObject {
                return MIDIClientCreate(clientName, {
                        let stateChange = MIDIStateChange(notificationPointer: $0.0)
                        stateChange
                    }, nil, $0)
            }
        } catch {
            clientRef = 0
            throw error
        }
    }

    var name: String? {
        do {
            let name = try getMIDIObjectProperty {
                return MIDIObjectGetStringProperty(self.clientRef, kMIDIPropertyName, $0)
            }
            return name as String?
        } catch {
            return nil
        }
    }

    func addInputPort() throws {
        if let name = name {
            try inputPorts.append(InputPort(clientRef: clientRef, portName: "\(name).port\(inputPorts.count)"))
        } else {
            throw SwiftMIDIError.Unknown
        }
    }
}

class InputPort {

    let inputPortRef: MIDIPortRef

    init(clientRef: MIDIObjectRef, portName: String) throws {
        do {
            try inputPortRef = createMIDIObject {
                return MIDIInputPortCreate(clientRef, portName, {
                    print($0.0)
                    }, nil, $0)
            }
        } catch {
            inputPortRef = 0
            throw error
        }
    }
}

do {
    if MIDIGetNumberOfSources() > 0 {
        let client = try Client()
        try client.addInputPort()

        let source = MIDIGetSource(0)
        MIDIPortConnectSource(client.inputPorts.first!.inputPortRef, source, nil)
    }
} catch {
    print(error)
}

