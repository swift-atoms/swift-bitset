extension Bitset {
    public enum Error: Swift::Error, Sendable, Equatable {

        case bounds(Bounds)

        case invalidCapacity(InvalidCapacity)
    }
}

extension Bitset.Error {
}
