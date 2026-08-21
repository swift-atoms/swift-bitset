extension Bitset {

    public struct Static<let wordCount: Int>: Sendable {
        @usableFromInline
        static var bitsPerWord: Int { UInt.bitWidth }

        @inlinable
        public static var capacity: Int { wordCount * bitsPerWord }

        @usableFromInline
        var storage: InlineArray<wordCount, UInt>

        @inlinable
        public init() {
            self.storage = InlineArray(repeating: 0)
        }

        @usableFromInline
        init(__storage: InlineArray<wordCount, UInt>) {
            self.storage = __storage
        }
    }
}

extension Bitset.Static {

    @inlinable
    public var capacity: Int { Self.capacity }

    @inlinable
    public var count: Int {
        var total = 0
        (0..<wordCount).forEach { i in
            total += storage[i].nonzeroBitCount
        }
        return total
    }

    @inlinable
    public var isEmpty: Bool {
        for i in 0..<wordCount {
            if storage[i] != 0 { return false }
        }
        return true
    }
}

extension Bitset.Static {

    @inlinable
    public func contains(_ member: Int) -> Bool {
        guard member >= 0 && member < Self.capacity else { return false }
        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (storage[wordIndex] & mask) != 0
    }
}

extension Bitset.Static {

    @inlinable
    @discardableResult
    public mutating func insert(_ member: Int) throws(__BitsetStaticError) -> Bool {
        guard member >= 0 && member < Self.capacity else {
            if member >= Self.capacity {
                throw .overflow(.init())
            }
            throw .bounds(.init(member: member, capacity: Self.capacity))
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
    public mutating func remove(_ member: Int) throws(__BitsetStaticError) -> Bool {
        guard member >= 0 && member < Self.capacity else {
            throw .bounds(.init(member: member, capacity: Self.capacity))
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
        (0..<wordCount).forEach { i in
            storage[i] = 0
        }
    }
}

extension Bitset.Static {

    @inlinable
    public func forEach(_ body: (Int) -> Void) {
        (0..<wordCount).forEach { wordIndex in
            var word = storage[wordIndex]
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * Self.bitsPerWord + bitIndex
                body(globalIndex)
                word &= word - 1
            }
        }
    }
}

extension Bitset.Static: Equatable {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in 0..<wordCount {
            if lhs.storage[i] != rhs.storage[i] { return false }
        }
        return true
    }
}

extension Bitset.Static: Hashable {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        (0..<wordCount).forEach { i in
            hasher.combine(storage[i])
        }
    }
}
