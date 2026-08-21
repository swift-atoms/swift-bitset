public enum __BitsetStaticError: Swift.Error, Sendable, Equatable {

    case bounds(Bounds)

    case overflow(Overflow)
}

extension __BitsetStaticError {

    public struct Bounds: Sendable, Equatable {

        public let member: Int

        public let capacity: Int

        @inlinable
        public init(member: Int, capacity: Int) {
            self.member = member
            self.capacity = capacity
        }
    }

    public struct Overflow: Sendable, Equatable {

        @inlinable
        public init() {}
    }
}

extension Bitset.Static {

    public typealias Error = __BitsetStaticError
}
