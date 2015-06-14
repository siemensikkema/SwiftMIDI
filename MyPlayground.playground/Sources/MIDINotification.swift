import CoreMIDI

protocol MIDINotificationConvertible {}

extension MIDIIOErrorNotification: MIDINotificationConvertible {}
extension MIDIObjectAddRemoveNotification: MIDINotificationConvertible {}
extension MIDIObjectPropertyChangeNotification: MIDINotificationConvertible {}

func convertMIDINotification<T: MIDINotificationConvertible>(notificationPointer: UnsafePointer<MIDINotification>) -> T {
    return UnsafePointer<T>(notificationPointer)[0]
}

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
