public enum __BitsetFixedError: Swift.Error, Sendable, Equatable {

    case bounds(Bounds)

    case invalidCapacity(InvalidCapacity)

    case overflow(Overflow)
}

extension __BitsetFixedError {

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

extension Bitset.Fixed {

    public typealias Error = __BitsetFixedError
}
