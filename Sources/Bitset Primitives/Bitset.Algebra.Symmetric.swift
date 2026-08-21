extension Bitset.Algebra {

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

extension Bitset.Algebra.Symmetric {
    @usableFromInline
    static var bitsPerWord: Int { UInt.bitWidth }

    @usableFromInline
    var wordCount: Int { storage.count }
}

extension Bitset.Algebra.Symmetric {

    @inlinable
    public func difference(_ other: Bitset) -> Bitset {
        var resultStorage = storage
        var resultCapacity = capacity

        if other.storedCapacity > capacity {
            let newCapacity = other.storedCapacity
            let newWordCount = (newCapacity + Self.bitsPerWord - 1) / Self.bitsPerWord
            let oldWordCount = resultStorage.count

            if newWordCount > oldWordCount {
                resultStorage.reserveCapacity(newWordCount)
                (oldWordCount..<newWordCount).forEach { _ in
                    resultStorage.append(0)
                }
            }
            resultCapacity = newCapacity
        }

        let minWords = Swift.min(resultStorage.count, other.storage.count)
        (0..<minWords).forEach { i in
            resultStorage[i] ^= other.storage[i]
        }

        return Bitset(__storage: resultStorage, capacity: resultCapacity)
    }
}
