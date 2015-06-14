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
        case .UnknownError:
            return "An unknown error occured"
        }
    }
}
