extension Bitset: Swift.Hashable {

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
