extension Bitset.Static {

    @inlinable
    public var relation: Relation {
        Relation(storage: storage)
    }
}

extension Bitset.Static {

    public struct Relation: Sendable {
        @usableFromInline
        let storage: InlineArray<wordCount, UInt>

        @usableFromInline
        init(storage: InlineArray<wordCount, UInt>) {
            self.storage = storage
        }
    }
}

extension Bitset.Static.Relation {

    @inlinable
    public func isSubset(of other: Bitset.Static<wordCount>) -> Bool {
        for i in 0..<wordCount {
            if (storage[i] & ~other.storage[i]) != 0 {
                return false
            }
        }
        return true
    }

    @inlinable
    public func isSuperset(of other: Bitset.Static<wordCount>) -> Bool {
        other.relation.isSubset(of: Bitset.Static<wordCount>(__storage: storage))
    }

    @inlinable
    public func isDisjoint(with other: Bitset.Static<wordCount>) -> Bool {
        for i in 0..<wordCount {
            if (storage[i] & other.storage[i]) != 0 {
                return false
            }
        }
        return true
    }
}
