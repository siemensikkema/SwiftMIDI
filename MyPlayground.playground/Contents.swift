import XCPlayground
import CoreMIDI

XCPSetExecutionShouldContinueIndefinitely(true)

protocol MIDINotificationConvertible {}

extension MIDIIOErrorNotification: MIDINotificationConvertible {}
extension MIDIObjectAddRemoveNotification: MIDINotificationConvertible {}
extension MIDIObjectPropertyChangeNotification: MIDINotificationConvertible {}

func convertMIDINotification<T: MIDINotificationConvertible>(notificationPointer: UnsafePointer<MIDINotification>) -> T {
    return UnsafePointer<T>(notificationPointer)[0]
}

enum MIDIStateChange {

    init(notificationPointer: UnsafePointer<MIDINotification>) {
        let notification = notificationPointer[0]

        // convert MIDINotification to MIDIStateChange. A safety check is performed whether the size corresponds to the size of the type of MIDI Notification used for the associated value when applicable.
        switch (notification.messageID, Int(notification.messageSize)) {
        case (.MsgIOError, sizeof(MIDIIOErrorNotification)):
            self = .IOError(convertMIDINotification(notificationPointer))
        case (.MsgObjectAdded, sizeof(MIDIObjectAddRemoveNotification)):
            self = .ObjectAdded(convertMIDINotification(notificationPointer))
        case (.MsgObjectRemoved, sizeof(MIDIObjectAddRemoveNotification)):
            self = .ObjectRemoved(convertMIDINotification(notificationPointer))
        case (.MsgPropertyChanged, sizeof(MIDIObjectPropertyChangeNotification)):
            self = .PropertyChanged(convertMIDINotification(notificationPointer))
        case (.MsgSerialPortOwnerChanged, _):
            self = .SerialPortOwnerChanged
        case (.MsgSetupChanged, _):
            self = .SetupChanged
        case (.MsgThruConnectionsChanged, _):
            self = .ThruConnectionsChanged
        default:
            self = .UnknownError
        }
    }

    case IOError(MIDIIOErrorNotification)
    case ObjectAdded(MIDIObjectAddRemoveNotification)
    case ObjectRemoved(MIDIObjectAddRemoveNotification)
    case PropertyChanged(MIDIObjectPropertyChangeNotification)
    case SerialPortOwnerChanged
    case SetupChanged
    case ThruConnectionsChanged
    case UnknownError
}

extension MIDIStateChange: CustomStringConvertible {
    var description: String {
        switch self {
        case .IOError(let errorNotification):
            return "IO error occured. \(errorNotification)"
        case .ObjectAdded(let addNotification):
            return "Object added. \(addNotification)"
        case .ObjectRemoved(let removeNotification):
            return "Object added. \(removeNotification)"
        case .PropertyChanged(let propertyChangeNotification):
            return "Property changed. \(propertyChangeNotification)"
        case .SerialPortOwnerChanged:
            return "Serial port owner changed"
        case .SetupChanged:
            return "Setup changed"
        case .ThruConnectionsChanged:
            return "Thru connections changed"
        case .UnknownError:
            return "An unknown error occured"
        }
    }
}

extension MIDIIOErrorNotification: CustomStringConvertible {
    public var description: String {
        return "Driver device: \(driverDevice), error: \(errorCode.MIDIErrorString)"
    }
}

extension MIDIObjectAddRemoveNotification: CustomStringConvertible {
    public var description: String {
        return "Parent: \(parent), parent type: \(parentType), child: \(child), child type: \(childType)"
    }
}

extension MIDIObjectPropertyChangeNotification: CustomStringConvertible {
    public var description: String {

        return "Object: \(object), object type: \(objectType), property name: \(propertyName.takeUnretainedValue())"
    }
}

extension OSStatus {
    var MIDIErrorString: String {
        switch Int(self) {
        case kMIDIInvalidClient: return "Invalid client"
        case kMIDIInvalidPort: return "Invalid port"
        case kMIDIWrongEndpointType: return "Wrong endpoint type"
        case kMIDINoConnection: return "No connection"
        case kMIDIUnknownEndpoint: return "Unknown endpoint"
        case kMIDIUnknownProperty: return "Unknown property"
        case kMIDIWrongPropertyType: return "Wrong property type"
        case kMIDINoCurrentSetup: return "No current setup"
        case kMIDIMessageSendErr: return "Message send error"
        case kMIDIServerStartErr: return "Server start error"
        case kMIDISetupFormatErr: return "Setup format error"
        case kMIDIWrongThread: return "Wrong thread"
        case kMIDIObjectNotFound: return "Object not found"
        case kMIDIIDNotUnique: return "Not unique"
        default: return "\(self)"
        }
    }
}

extension MIDIObjectType: CustomStringConvertible {
    public var description: String {
        switch self {
        case Other: return "Other"
        case Device: return "Device"
        case Entity: return "Entity"
        case Source: return "Source"
        case Destination: return "Destination"
        case ExternalDevice: return "External Device"
        case ExternalEntity: return "External Entity"
        case ExternalSource: return "External Source"
        case ExternalDestination: return "External Destination"
        }
    }
}

var client = MIDIClientRef()

let status = withUnsafeMutablePointer(&client) {
    return MIDIClientCreate("SwiftMIDI",
        { (notificationPointer, _) in
            let stateChange = MIDIStateChange(notificationPointer: notificationPointer)
            stateChange
        },
        nil, $0)
}
