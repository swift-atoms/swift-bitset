extension Bitset {

    public struct Fixed: Sendable {
        @usableFromInline
        var storage: ContiguousArray<UInt>

        public let capacity: Int

        @inlinable
        public init(capacity: Int) throws(__BitsetFixedError) {
            guard capacity >= 0 else {
                throw .invalidCapacity(.init())
            }
            let wordCount = (capacity + Self.bitsPerWord - 1) / Self.bitsPerWord
            self.storage = ContiguousArray(repeating: 0, count: wordCount)
            self.capacity = capacity
        }

        @usableFromInline
        init(__storage: ContiguousArray<UInt>, capacity: Int) {
            self.storage = __storage
            self.capacity = capacity
        }
    }
}

extension Bitset.Fixed {
    @usableFromInline
    static var bitsPerWord: Int { UInt.bitWidth }
}

extension Bitset.Fixed {

    @inlinable
    public var count: Int {
        var total = 0
        for word in storage {
            total += word.nonzeroBitCount
        }
        return total
    }

    @inlinable
    public var isEmpty: Bool {
        for word in storage {
            if word != 0 { return false }
        }
        return true
    }
}

extension Bitset.Fixed {

    @inlinable
    public func contains(_ member: Int) -> Bool {
        guard member >= 0 && member < capacity else { return false }
        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (storage[wordIndex] & mask) != 0
    }
}

extension Bitset.Fixed {

    @inlinable
    @discardableResult
    public mutating func insert(_ member: Int) throws(__BitsetFixedError) -> Bool {
        guard member >= 0 && member < capacity else {
            if member >= capacity {
                throw .overflow(.init())
            }
            throw .bounds(.init(member: member, capacity: capacity))
        }
        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        let wasSet = (storage[wordIndex] & mask) != 0
        storage[wordIndex] |= mask
        return !wasSet
    }

    @inlinable
    @discardableResult
    public mutating func remove(_ member: Int) throws(__BitsetFixedError) -> Bool {
        guard member >= 0 && member < capacity else {
            throw .bounds(.init(member: member, capacity: capacity))
        }
        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        let wasSet = (storage[wordIndex] & mask) != 0
        storage[wordIndex] &= ~mask
        return wasSet
    }

    @inlinable
    public mutating func removeAll() {
        (0..<storage.count).forEach { i in
            storage[i] = 0
        }
    }
}

extension Bitset.Fixed {

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

extension Bitset.Fixed: Equatable {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.capacity == rhs.capacity && lhs.storage == rhs.storage
    }
}

extension Bitset.Fixed: Hashable {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(capacity)
        hasher.combine(storage)
    }
}
