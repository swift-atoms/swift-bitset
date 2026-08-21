extension Bitset.Static.Algebra {

    public struct Symmetric: Sendable {
        @usableFromInline
        let storage: InlineArray<wordCount, UInt>

        @usableFromInline
        init(storage: InlineArray<wordCount, UInt>) {
            self.storage = storage
        }
    }
}

extension Bitset.Static.Algebra.Symmetric {

    @inlinable
    public func difference(_ other: Bitset.Static<wordCount>) -> Bitset.Static<wordCount> {
        var resultStorage = storage
        (0..<wordCount).forEach { i in
            resultStorage[i] ^= other.storage[i]
        }
        return Bitset.Static<wordCount>(__storage: resultStorage)
    }
}
