extension Bitset.Static {
    public enum Error: Swift.Error, Sendable, Equatable {

        case bounds(Bounds)

        case overflow(Overflow)
    }
}

extension Bitset.Static.Error {

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
