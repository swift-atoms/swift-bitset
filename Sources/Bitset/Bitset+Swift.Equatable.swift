extension Bitset: Swift.Equatable {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        let common = Swift.min(lhs.storage.count, rhs.storage.count)
        return !zip(lhs.storage, rhs.storage).contains(where: { $0.0 != $0.1 })
            && !lhs.storage.dropFirst(common).contains(where: { $0 != 0 })
            && !rhs.storage.dropFirst(common).contains(where: { $0 != 0 })
    }
}
