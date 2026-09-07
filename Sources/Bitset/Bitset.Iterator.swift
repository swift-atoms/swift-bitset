public import Iterator

extension Bitset.Iterator {

    @inlinable
    public mutating func next() -> Int? {
        guard wordIndex < storage.count else { return nil }
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
