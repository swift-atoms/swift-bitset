extension Bitset.Static {

    @inlinable
    public var algebra: Algebra {
        Algebra(storage: storage)
    }
}

extension Bitset.Static {

    public struct Algebra: Sendable {
        @usableFromInline
        let storage: InlineArray<wordCount, UInt>

        @usableFromInline
        init(storage: InlineArray<wordCount, UInt>) {
            self.storage = storage
        }
    }
}

extension Bitset.Static.Algebra {
    @usableFromInline
    static var bitsPerWord: Int { UInt.bitWidth }
}

extension Bitset.Static.Algebra {

    @inlinable
    public func union(_ other: Bitset.Static<wordCount>) -> Bitset.Static<wordCount> {
        var resultStorage = storage
        (0..<wordCount).forEach { i in
            resultStorage[i] |= other.storage[i]
        }
        return Bitset.Static<wordCount>(__storage: resultStorage)
    }

    @inlinable
    public func intersection(_ other: Bitset.Static<wordCount>) -> Bitset.Static<wordCount> {
        var resultStorage = storage
        (0..<wordCount).forEach { i in
            resultStorage[i] &= other.storage[i]
        }
        return Bitset.Static<wordCount>(__storage: resultStorage)
    }

    @inlinable
    public func subtract(_ other: Bitset.Static<wordCount>) -> Bitset.Static<wordCount> {
        var resultStorage = storage
        (0..<wordCount).forEach { i in
            resultStorage[i] &= ~other.storage[i]
        }
        return Bitset.Static<wordCount>(__storage: resultStorage)
    }

    @inlinable
    public var symmetric: Symmetric {
        Symmetric(storage: storage)
    }
}

extension Bitset.Static {

    @inlinable
    public mutating func form(_ operation: (Algebra) -> Bitset.Static<wordCount>) {
        self = operation(algebra)
    }
}
