extension Bitset: Swift.CustomStringConvertible {

    public var description: String {
        let elements = Array(self.prefix(10))
        let suffix = count > 10 ? ", ..." : ""
        return "Bitset({\(elements.map(String.init).joined(separator: ", "))\(suffix)})"
    }
}
