extension Bitset {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression(_ expression: Int) -> [Int] {
            [expression]
        }

        @inlinable
        public static func buildExpression(_ expression: [Int]) -> [Int] {
            expression
        }

        @inlinable
        public static func buildExpression<S: Swift.Sequence>(_ expression: S) -> [Int]
        where S.Element == Int {
            Array(expression)
        }

        @inlinable
        public static func buildExpression(_ expression: Int?) -> [Int] {
            expression.map { [$0] } ?? []
        }

        @inlinable
        public static func buildPartialBlock(first: [Int]) -> [Int] {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> [Int] {
            []
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> [Int] {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: consuming [Int],
            next: [Int]
        ) -> [Int] {
            accumulated.append(contentsOf: next)
            return accumulated
        }

        @inlinable
        public static func buildBlock() -> [Int] {
            []
        }

        @inlinable
        public static func buildOptional(_ component: [Int]?) -> [Int] {
            component ?? []
        }

        @inlinable
        public static func buildEither(first: [Int]) -> [Int] {
            first
        }

        @inlinable
        public static func buildEither(second: [Int]) -> [Int] {
            second
        }

        @inlinable
        public static func buildArray(_ components: [[Int]]) -> [Int] {
            components.flatMap { $0 }
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: [Int]) -> [Int] {
            component
        }
    }
}

extension Bitset {

    @inlinable
    public init(@Bitset.Builder _ builder: () -> [Int]) throws(__BitsetError) {
        try self.init(builder())
    }
}
