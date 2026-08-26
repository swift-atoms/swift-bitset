extension Bitset.Fixed.Algebra {

    public struct Symmetric: Sendable {
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

extension Bitset.Fixed.Algebra.Symmetric {

    @inlinable
    public func difference(_ other: Bitset.Fixed) -> Bitset.Fixed {
        precondition(capacity == other.capacity, "Capacities must match")
        var resultStorage = storage
        (0..<resultStorage.count).forEach { i in
            resultStorage[i] ^= other.storage[i]
        }
        return Bitset.Fixed(__storage: resultStorage, capacity: capacity)
    }
}
