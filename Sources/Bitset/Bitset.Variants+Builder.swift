extension Bitset.Static {

    public init(
        @Bitset.Builder _ builder: () -> [Int]
    ) throws(Bitset.Static<wordCount>.Error) {
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
    ) throws(Bitset.Fixed.Error) {
        var fixed = try Bitset.Fixed(capacity: capacity)
        let members = builder()
        for m in members {
            _ = try fixed.insert(m)
        }
        self = fixed
    }
}
