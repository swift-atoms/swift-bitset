extension Bitset.Static {

    public init(
        @Bitset.Builder _ builder: () -> [Int]
    ) throws(__BitsetStaticError) {
        let members = builder()
        self.init()
        for m in members {
            _ = try self.insert(m)
        }
    }
}

extension Bitset.Fixed {

    public init(
        capacity: Int,
        @Bitset.Builder _ builder: () -> [Int]
    ) throws(__BitsetFixedError) {
        var fixed = try Bitset.Fixed(capacity: capacity)
        let members = builder()
        for m in members {
            _ = try fixed.insert(m)
        }
        self = fixed
    }
}
