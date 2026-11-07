extension Bitset.Fixed {
    public enum Error: Swift::Error, Sendable, Equatable {

        case bounds(Bounds)

        case invalidCapacity(InvalidCapacity)

        case overflow(Overflow)
    }
}

extension Bitset.Fixed.Error {
}
