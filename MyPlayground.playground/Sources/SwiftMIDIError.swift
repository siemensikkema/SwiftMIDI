import CoreMIDI

public enum SwiftMIDIError: String, ErrorType {
    case NoError = "No error"
    case InvalidClient = "Invalid client"
    case InvalidPort = "Invalid port"
    case WrongEndpointType = "Wrong endpoint type"
    case NoConnection = "No connection"
    case UnknownEndpoint = "Unknown endpoint"
    case UnknownProperty = "Unknown property"
    case WrongPropertyType = "Wrong property type"
    case NoCurrentSetup = "No current setup"
    case MessageSendError = "Message send error"
    case ServerStartError = "Server start error"
    case SetupFormatError = "Setup format error"
    case WrongThread = "Wrong thread"
    case ObjectNotFound = "Object not found"
    case IDNotUnique = "Not unique"
    case Unknown = "Unknown MIDI Error"

    public init(status: OSStatus) {
        switch Int(status) {
        case Int(noErr): self = .NoError
        case kMIDIInvalidClient: self = .InvalidClient
        case kMIDIInvalidPort: self = .InvalidPort
        case kMIDIWrongEndpointType: self = .WrongEndpointType
        case kMIDINoConnection: self = .NoConnection
        case kMIDIUnknownEndpoint: self = .UnknownEndpoint
        case kMIDIUnknownProperty: self = .UnknownProperty
        case kMIDIWrongPropertyType: self = .WrongPropertyType
        case kMIDINoCurrentSetup: self = .NoCurrentSetup
        case kMIDIMessageSendErr: self = .MessageSendError
        case kMIDIServerStartErr: self = .ServerStartError
        case kMIDISetupFormatErr: self = .SetupFormatError
        case kMIDIWrongThread: self = .WrongThread
        case kMIDIObjectNotFound: self = .ObjectNotFound
        case kMIDIIDNotUnique: self = .IDNotUnique
        default: self = .Unknown
        }
    }
}
