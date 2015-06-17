import CoreMIDI

/// Executes an OSStatus returning closure and throws an SwiftMIDIError in case of an error
func evaluateStatus(@noescape closure: Void -> OSStatus) throws {
    let status = closure()

    if status != noErr {
        throw SwiftMIDIError(status: status)
    }
}

func createMIDIObject<T>(@noescape createClosure: UnsafeMutablePointer<T> -> OSStatus) throws -> T {
    let pointerToMIDIObject = UnsafeMutablePointer<T>.alloc(1)
    defer { pointerToMIDIObject.destroy() }

    try evaluateStatus { createClosure(pointerToMIDIObject) }

    return pointerToMIDIObject.memory
}

func getMIDIObjectProperty<T>(@noescape createClosure: UnsafeMutablePointer<Unmanaged<T>?> -> OSStatus) throws -> T? {
    var t: Unmanaged<T>? = .None
    defer { t?.release() }

    try evaluateStatus {
        withUnsafeMutablePointer(&t) {
            return createClosure($0)
        }
    }

    return t?.takeUnretainedValue()
}
