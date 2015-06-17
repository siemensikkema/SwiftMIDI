import CoreMIDI

public typealias MIDIPacketInput = [MIDIPacket] -> Void

/// Executes an OSStatus returning closure and throws a SwiftMIDIError in case of an error.
func evaluateStatus(@noescape closure: Void -> OSStatus) throws {
    let status = closure()

    if status != noErr {
        throw SwiftMIDIError(status: status)
    }
}

/// Helper function for wrapping functions that return MIDI objects referenced by UnsafeMutablePointer values and return OSStatus. Throws a SwiftMIDIError in case of an error.
func getMIDIObject<T>(@noescape createClosure: UnsafeMutablePointer<T> -> OSStatus) throws -> T {
    let pointerToMIDIObject = UnsafeMutablePointer<T>.alloc(1)
    defer { pointerToMIDIObject.destroy() }

    try evaluateStatus { createClosure(pointerToMIDIObject) }

    return pointerToMIDIObject.memory
}

/// Helper function for wrapping functions that return optional Unmanaged MIDI objects referenced by UnsafeMutablePointer values and return OSStatus. Throws a SwiftMIDIError in case of an error.
func getMIDIObject<T>(@noescape createClosure: UnsafeMutablePointer<Unmanaged<T>?> -> OSStatus) throws -> T? {
    var t: Unmanaged<T>? = .None
    defer { t?.release() }

    try evaluateStatus {
        withUnsafeMutablePointer(&t) {
            return createClosure($0)
        }
    }

    return t?.takeUnretainedValue()
}
