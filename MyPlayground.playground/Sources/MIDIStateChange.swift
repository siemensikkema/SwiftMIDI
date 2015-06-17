import CoreMIDI

public enum MIDIStateChange {
    public init(notificationPointer: UnsafePointer<MIDINotification>) {
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
            self = .OtherError(.Unknown)
        }
    }

    case IOError(MIDIIOErrorNotification)
    case ObjectAdded(MIDIObjectAddRemoveNotification)
    case ObjectRemoved(MIDIObjectAddRemoveNotification)
    case PropertyChanged(MIDIObjectPropertyChangeNotification)
    case SerialPortOwnerChanged
    case SetupChanged
    case ThruConnectionsChanged
    case OtherError(SwiftMIDIError)
}

extension MIDIStateChange: CustomStringConvertible {
    public var description: String {
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
        case .OtherError(let error):
            return "An unknown error occured. \(error)"
        }
    }
}

// MARK: - MIDI Notification

protocol MIDINotificationConvertible {}

func convertMIDINotification<T: MIDINotificationConvertible>(notificationPointer: UnsafePointer<MIDINotification>) -> T {
    return UnsafePointer<T>(notificationPointer)[0]
}

extension MIDIIOErrorNotification: MIDINotificationConvertible {}
extension MIDIObjectAddRemoveNotification: MIDINotificationConvertible {}
extension MIDIObjectPropertyChangeNotification: MIDINotificationConvertible {}

extension MIDIIOErrorNotification: CustomStringConvertible {
    public var description: String {
        return "Driver device: \(driverDevice), error: \(SwiftMIDIError(status: errorCode))"
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

// MARK: - MIDIObjectType

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
