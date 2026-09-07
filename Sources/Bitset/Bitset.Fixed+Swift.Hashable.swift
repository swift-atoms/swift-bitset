extension Bitset.Fixed: Swift.Hashable {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(capacity)
        hasher.combine(storage)
    }
}
