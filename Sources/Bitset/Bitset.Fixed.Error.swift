extension Bitset.Fixed {
    public enum Error: Swift.Error, Sendable, Equatable {

        case bounds(Bounds)

        case invalidCapacity(InvalidCapacity)

        case overflow(Overflow)
    }
}

extension Bitset.Fixed.Error {

    public struct Bounds: Sendable, Equatable {

        public let member: Int

        public let capacity: Int

        @inlinable
        public init(member: Int, capacity: Int) {
            self.member = member
            self.capacity = capacity
        }
    }

    public struct InvalidCapacity: Sendable, Equatable {

        @inlinable
        public init() {}
    }

    public struct Overflow: Sendable, Equatable {

        @inlinable
        public init() {}
    }
}
