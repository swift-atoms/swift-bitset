extension Bitset.Static: Swift.Hashable {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        (0..<wordCount).forEach { i in
            hasher.combine(storage[i])
        }
    }
}
