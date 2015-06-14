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
    public var MIDIErrorString: String {
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
