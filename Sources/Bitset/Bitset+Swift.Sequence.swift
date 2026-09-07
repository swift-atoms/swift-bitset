public import Iterator

extension Bitset: Swift.Sequence {

    public struct Iterator: Iterator::Iterator.`Protocol`, IteratorProtocol, Sendable {
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
