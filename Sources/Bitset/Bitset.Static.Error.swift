extension Bitset.Static {
    public enum Error: Swift::Error, Sendable, Equatable {

        case bounds(Bounds)

        case overflow(Overflow)
    }
}

extension Bitset.Static.Error {
}
