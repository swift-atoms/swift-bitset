extension Bitset.Fixed {

    @inlinable
    public var algebra: Algebra {
        Algebra(storage: storage, capacity: capacity)
    }
}

extension Bitset.Fixed {

    public struct Algebra: Sendable {
        @usableFromInline
        let storage: ContiguousArray<UInt>

        @usableFromInline
        let capacity: Int

        @usableFromInline
        init(storage: ContiguousArray<UInt>, capacity: Int) {
            self.storage = storage
            self.capacity = capacity
        }
    }
}

extension Bitset.Fixed.Algebra {
    @usableFromInline
    static var bitsPerWord: Int { UInt.bitWidth }
}

extension Bitset.Fixed.Algebra {

    @inlinable
    public func union(_ other: Bitset.Fixed) -> Bitset.Fixed {
        precondition(capacity == other.capacity, "Capacities must match")
        var resultStorage = storage
        (0..<resultStorage.count).forEach { i in
            resultStorage[i] |= other.storage[i]
        }
        return Bitset.Fixed(__storage: resultStorage, capacity: capacity)
    }

    @inlinable
    public func intersection(_ other: Bitset.Fixed) -> Bitset.Fixed {
        precondition(capacity == other.capacity, "Capacities must match")
        var resultStorage = storage
        (0..<resultStorage.count).forEach { i in
            resultStorage[i] &= other.storage[i]
        }
        return Bitset.Fixed(__storage: resultStorage, capacity: capacity)
    }

    @inlinable
    public func subtract(_ other: Bitset.Fixed) -> Bitset.Fixed {
        precondition(capacity == other.capacity, "Capacities must match")
        var resultStorage = storage
        (0..<resultStorage.count).forEach { i in
            resultStorage[i] &= ~other.storage[i]
        }
        return Bitset.Fixed(__storage: resultStorage, capacity: capacity)
    }

    @inlinable
    public var symmetric: Symmetric {
        Symmetric(storage: storage, capacity: capacity)
    }
}

extension Bitset.Fixed {

    @inlinable
    public mutating func form(_ operation: (Algebra) -> Bitset.Fixed) {
        self = operation(algebra)
    }
}
