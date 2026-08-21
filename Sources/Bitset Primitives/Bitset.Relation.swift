extension Bitset {

    @inlinable
    public var relation: Relation {
        Relation(storage: storage, capacity: storedCapacity)
    }
}

extension Bitset {

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

extension Bitset.Relation {

    @inlinable
    public func isSubset(of other: Bitset) -> Bool {
        for i in 0..<storage.count {
            let selfWord = storage[i]
            let otherWord = i < other.storage.count ? other.storage[i] : 0
            if (selfWord & ~otherWord) != 0 {
                return false
            }
        }
        return true
    }

    @inlinable
    public func isSuperset(of other: Bitset) -> Bool {
        other.relation.isSubset(of: Bitset(__storage: storage, capacity: capacity))
    }

    @inlinable
    public func isDisjoint(with other: Bitset) -> Bool {
        let minWords = Swift.min(storage.count, other.storage.count)
        for i in 0..<minWords {
            if (storage[i] & other.storage[i]) != 0 {
                return false
            }
        }
        return true
    }
}
