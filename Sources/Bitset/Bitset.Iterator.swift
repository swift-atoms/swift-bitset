public import Iterator_Protocol

extension Bitset: Swift.Sequence {

    public struct Iterator: Iterator.Iterator.`Protocol`, IteratorProtocol, Sendable {
        @usableFromInline
        let storage: ContiguousArray<UInt>

        @usableFromInline
        let capacity: Int

        @usableFromInline
        var wordIndex: Int

        @usableFromInline
        var currentWord: UInt

        @usableFromInline
        init(storage: ContiguousArray<UInt>, capacity: Int) {
            self.storage = storage
            self.capacity = capacity
            self.wordIndex = 0
            self.currentWord = storage.isEmpty ? 0 : storage[0]
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: storage, capacity: capacity)
    }
}

extension Bitset.Iterator {

    @inlinable
    public mutating func next() -> Int? {
        while currentWord == 0 {
            wordIndex += 1
            guard wordIndex < storage.count else { return nil }
            currentWord = storage[wordIndex]
        }

        let bit = currentWord.trailingZeroBitCount
        currentWord &= currentWord &- 1
        let member = wordIndex * UInt.bitWidth + bit
        return member < capacity ? member : nil
    }
}

extension Bitset {

    @inlinable
    public func forEach(_ body: (Int) -> Void) {
        for (wordIndex, var word) in storage.enumerated() {
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * Self.bitsPerWord + bitIndex
                if globalIndex < capacity {
                    body(globalIndex)
                }
                word &= word - 1
            }
        }
    }
}
