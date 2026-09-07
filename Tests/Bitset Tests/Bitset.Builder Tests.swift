import Testing

@testable import Bitset

extension Bitset.Builder {
    @Suite
    struct `Behavior contracts` {
        @Suite struct `Unit behavior` {}
        @Suite struct `Edge Case` {}
        @Suite struct `Integration behavior` {}
        @Suite struct `Static Methods` {}
    }
}

extension Bitset.Builder.`Behavior contracts` {
    fileprivate static func collected(_ bitset: Bitset) -> [Int] {
        var result: [Int] = []
        (0..<bitset.capacity).forEach { i in
            if bitset.contains(i) {
                result.append(i)
            }
        }
        return result
    }
}

extension Bitset.Builder.`Behavior contracts`.`Unit behavior` {

    @Test
    func `builders accept one member`() throws {
        let bitset = try Bitset { 5 }
        #expect(bitset.contains(5))
        #expect(bitset.count == 1)
    }

    @Test
    func `builders retain multiple distinct members`() throws {
        let bitset = try Bitset {
            1
            5
            10
        }
        #expect(Bitset.Builder.`Behavior contracts`.collected(bitset) == [1, 5, 10])
    }

    @Test
    func `builders collapse duplicate members`() throws {
        let bitset = try Bitset {
            1
            5
            1
            5
            5
        }
        #expect(Bitset.Builder.`Behavior contracts`.collected(bitset) == [1, 5])
        #expect(bitset.count == 2)
    }

    @Test
    func `builders include present optional members`() throws {
        let value: Int? = 42
        let bitset = try Bitset { value }
        #expect(bitset.contains(42))
    }

    @Test
    func `builders omit absent optional members`() throws {
        let value: Int? = nil
        let bitset = try Bitset { value }
        #expect(bitset.isEmpty)
    }

    @Test
    func `builders combine members with optional members`() throws {
        let some: Int? = 7
        let none: Int? = nil
        let bitset = try Bitset {
            1
            some
            none
            10
        }
        #expect(Bitset.Builder.`Behavior contracts`.collected(bitset) == [1, 7, 10])
    }

    @Test
    func `empty builders produce empty sets`() throws {
        let bitset = try Bitset {}
        #expect(bitset.isEmpty)
    }

    @Test
    func `builders accept zero as a member`() throws {
        let bitset = try Bitset { 0 }
        #expect(bitset.contains(0))
    }
}

extension Bitset.Builder.`Behavior contracts`.`Unit behavior` {

    @Test
    func `builders include members from true branches`() throws {
        let include = true
        let bitset = try Bitset {
            1
            if include {
                5
            }
            10
        }
        #expect(Bitset.Builder.`Behavior contracts`.collected(bitset) == [1, 5, 10])
    }

    @Test
    func `builders omit members from false branches`() throws {
        let include = false
        let bitset = try Bitset {
            1
            if include {
                5
            }
            10
        }
        #expect(Bitset.Builder.`Behavior contracts`.collected(bitset) == [1, 10])
    }

    @Test
    func `builders accept sequences of members`() throws {
        let bitset = try Bitset {
            (0..<5).map { $0 * 2 }
        }
        #expect(Bitset.Builder.`Behavior contracts`.collected(bitset) == [0, 2, 4, 6, 8])
    }

    @Test
    func `builder loops accept strided members`() throws {
        let bitset = try Bitset {
            for i in stride(from: 0, to: 10, by: 3) {
                i
            }
        }
        #expect(Bitset.Builder.`Behavior contracts`.collected(bitset) == [0, 3, 6, 9])
    }
}

extension Bitset.Builder.`Behavior contracts`.`Edge Case` {

    @Test
    func `builders span multiple storage words`() throws {
        let bitset = try Bitset {
            0
            64
            128
            256
        }
        #expect(Bitset.Builder.`Behavior contracts`.collected(bitset) == [0, 64, 128, 256])
        #expect(bitset.count == 4)
    }

    @Test
    func `builders preserve long sequences of members`() throws {
        let bitset = try Bitset {
            0..<100
        }
        #expect(bitset.count == 100)
    }

    @Test
    func `builders preserve nested conditional membership`() throws {
        let a = true
        let b = false
        let c = true
        let bitset = try Bitset {
            0
            if a {
                1
                if b {
                    2
                } else {
                    3
                    if c {
                        4
                    }
                }
            }
            99
        }
        #expect(Bitset.Builder.`Behavior contracts`.collected(bitset) == [0, 1, 3, 4, 99])
    }
}

extension Bitset.Builder.`Behavior contracts`.`Integration behavior` {

    @Test
    func `built sets accept subsequent insertions`() throws {
        var bitset = try Bitset {
            1
            2
        }
        try bitset.insert(3)
        #expect(Bitset.Builder.`Behavior contracts`.collected(bitset) == [1, 2, 3])
    }

    @Test
    func `built sets report member presence`() throws {
        let primes = try Bitset {
            2
            3
            5
            7
            11
        }
        #expect(primes.contains(7))
        #expect(!primes.contains(8))
    }
}

extension Bitset.Builder.`Behavior contracts`.`Static Methods` {

    @Test
    func `single builder expressions preserve their member`() {
        let result = Bitset.Builder.buildExpression(42)
        #expect(result == [42])
    }

    @Test
    func `array builder expressions preserve their members`() {
        let result = Bitset.Builder.buildExpression([1, 2, 3])
        #expect(result == [1, 2, 3])
    }

    @Test
    func `partial builder blocks preserve accumulated and subsequent members`() {
        let result = Bitset.Builder.buildPartialBlock(
            accumulated: [1, 2],
            next: [3, 4]
        )
        #expect(result == [1, 2, 3, 4])
    }

    @Test
    func `builder loops combine their component members`() {
        let result = Bitset.Builder.buildArray([[1, 2], [3, 4], [5]])
        #expect(result == [1, 2, 3, 4, 5])
    }
}
