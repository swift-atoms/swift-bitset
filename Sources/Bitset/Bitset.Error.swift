public enum __BitsetError: Swift.Error, Sendable, Equatable {

    case bounds(Bounds)

    case invalidCapacity(InvalidCapacity)
}

extension __BitsetError {

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
}

extension Bitset {

    public typealias Error = __BitsetError
}
