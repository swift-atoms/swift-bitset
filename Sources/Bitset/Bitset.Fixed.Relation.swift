extension Bitset.Fixed {

    @inlinable
    public var relation: Relation {
        Relation(storage: storage, capacity: capacity)
    }
}

extension Bitset.Fixed {

    public struct Relation: Sendable {
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

extension Bitset.Fixed.Relation {

    @inlinable
    public func isSubset(of other: Bitset.Fixed) -> Bool {
        precondition(capacity == other.capacity, "Capacities must match")
        for i in 0..<storage.count {
            if (storage[i] & ~other.storage[i]) != 0 {
                return false
            }
        }
        return true
    }

    @inlinable
    public func isSuperset(of other: Bitset.Fixed) -> Bool {
        other.relation.isSubset(of: Bitset.Fixed(__storage: storage, capacity: capacity))
    }

    @inlinable
    public func isDisjoint(with other: Bitset.Fixed) -> Bool {
        precondition(capacity == other.capacity, "Capacities must match")
        for i in 0..<storage.count {
            if (storage[i] & other.storage[i]) != 0 {
                return false
            }
        }
        return true
    }
}
