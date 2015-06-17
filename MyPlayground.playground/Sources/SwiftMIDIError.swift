import CoreMIDI

/// Represents any error in SwiftMIDI including Core MIDI errors from OSStatus error codes.
public enum SwiftMIDIError: String, ErrorType {

    // CoreMIDI errors
    case IDNotUnique = "Not unique"
    case InvalidClient = "Invalid client"
    case InvalidPort = "Invalid port"
    case MessageSendError = "Message send error"
    case NoConnection = "No connection"
    case NoCurrentSetup = "No current setup"
    case ObjectNotFound = "Object not found"
    case ServerStartError = "Server start error"
    case SetupFormatError = "Setup format error"
    case UnknownEndpoint = "Unknown endpoint"
    case UnknownProperty = "Unknown property"
    case WrongEndpointType = "Wrong endpoint type"
    case WrongPropertyType = "Wrong property type"
    case WrongThread = "Wrong thread"

    case NoError = "No error"
    case Unknown = "Unknown MIDI Error"

    public init(status: OSStatus) {
        switch Int(status) {
        case kMIDIIDNotUnique: self = .IDNotUnique
        case kMIDIInvalidClient: self = .InvalidClient
        case kMIDIInvalidPort: self = .InvalidPort
        case kMIDIMessageSendErr: self = .MessageSendError
        case kMIDINoConnection: self = .NoConnection
        case kMIDINoCurrentSetup: self = .NoCurrentSetup
        case kMIDIObjectNotFound: self = .ObjectNotFound
        case kMIDIServerStartErr: self = .ServerStartError
        case kMIDISetupFormatErr: self = .SetupFormatError
        case kMIDIUnknownEndpoint: self = .UnknownEndpoint
        case kMIDIUnknownProperty: self = .UnknownProperty
        case kMIDIWrongEndpointType: self = .WrongEndpointType
        case kMIDIWrongPropertyType: self = .WrongPropertyType
        case kMIDIWrongThread: self = .WrongThread

        case Int(noErr): self = .NoError
        default: self = .Unknown
        }
    }
}
