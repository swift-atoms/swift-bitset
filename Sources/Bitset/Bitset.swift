public struct Bitset: Sendable {
    @usableFromInline
    package var storage: ContiguousArray<UInt>

    @usableFromInline
    var storedCapacity: Int

    @inlinable
    public init() {
        self.storage = []
        self.storedCapacity = 0
    }

    @inlinable
    public init(capacity: Int) throws(__BitsetError) {
        guard capacity >= 0 else {
            throw .invalidCapacity(.init())
        }
        let wordCount = (capacity + Self.bitsPerWord - 1) / Self.bitsPerWord
        self.storage = ContiguousArray(repeating: 0, count: wordCount)
        self.storedCapacity = capacity
    }

    @usableFromInline
    init(__storage: ContiguousArray<UInt>, capacity: Int) {
        self.storage = __storage
        self.storedCapacity = capacity
    }
}

extension Bitset {

    @inlinable
    public static var bitsPerWord: Int { UInt.bitWidth }
}

extension Bitset {

    @inlinable
    public var capacity: Int { storedCapacity }

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

    @usableFromInline
    var wordCount: Int { storage.count }
}

extension Bitset {

    @inlinable
    public func contains(_ member: Int) -> Bool {
        guard member >= 0 && member < capacity else { return false }
        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (storage[wordIndex] & mask) != 0
    }
}

extension Bitset {

    @inlinable
    @discardableResult
    public mutating func insert(_ member: Int) throws(__BitsetError) -> Bool {
        guard member >= 0 else {
            throw .bounds(.init(member: member, capacity: capacity))
        }

        if member >= capacity {
            grow(toInclude: member)
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
    public mutating func remove(_ member: Int) throws(__BitsetError) -> Bool {
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

    @usableFromInline
    mutating func grow(toInclude member: Int) {
        let newCapacity = member + 1
        let newWordCount = (newCapacity + Self.bitsPerWord - 1) / Self.bitsPerWord
        let oldWordCount = storage.count

        if newWordCount > oldWordCount {
            storage.reserveCapacity(newWordCount)
            for _ in oldWordCount..<newWordCount {
                storage.append(0)
            }
        }
        storedCapacity = newCapacity
    }
}

extension Bitset {

    @inlinable
    public var min: Int? {
        for wordIndex in storage.indices {
            let word = storage[wordIndex]
            if word != 0 {
                let lowestBit = word.trailingZeroBitCount
                let element = wordIndex * Self.bitsPerWord + lowestBit
                return element < capacity ? element : nil
            }
        }
        return nil
    }

    @inlinable
    public var max: Int? {
        for wordIndex in storage.indices.reversed() {
            let word = storage[wordIndex]
            if word != 0 {
                let highestBit = UInt.bitWidth - 1 - word.leadingZeroBitCount
                let element = wordIndex * Self.bitsPerWord + highestBit
                return element < capacity ? element : nil
            }
        }
        return nil
    }

    @inlinable
    public mutating func clear() {
        removeAll()
    }
}

extension Bitset {

    @inlinable
    public init<S: Swift.Sequence>(_ members: S) throws(__BitsetError) where S.Element == Int {
        self.init()
        for member in members {
            try insert(member)
        }
    }
}

extension Bitset: Equatable {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        let common = Swift.min(lhs.storage.count, rhs.storage.count)
        return !zip(lhs.storage, rhs.storage).contains(where: { $0.0 != $0.1 })
            && !lhs.storage.dropFirst(common).contains(where: { $0 != 0 })
            && !rhs.storage.dropFirst(common).contains(where: { $0 != 0 })
    }
}

extension Bitset: Hashable {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        var significant = storage.count
        while significant > 0 && storage[significant - 1] == 0 {
            significant -= 1
        }
        storage.prefix(significant).forEach { word in
            hasher.combine(word)
        }
    }
}

extension Bitset: CustomStringConvertible {

    public var description: String {
        var elements: [Int] = []
        outer: for (wordIndex, word) in storage.enumerated() {
            var word = word
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * Self.bitsPerWord + bitIndex
                if globalIndex < capacity {
                    elements.append(globalIndex)
                    if elements.count == 10 { break outer }
                }
                word &= word - 1
            }
        }
        let suffix = count > 10 ? ", ..." : ""
        return "Bitset({\(elements.map(String.init).joined(separator: ", "))\(suffix)})"
    }
}
