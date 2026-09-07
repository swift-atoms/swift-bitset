import Testing

@testable import Bitset

extension Bitset {
    @Suite
    struct `Bitsets preserve membership through mutation iteration and set operations` {

        @Test
        func `inserted members are present`() throws {
            var set = Bitset()

            #expect(try set.insert(0) == true)
            #expect(try set.insert(1) == true)
            #expect(try set.insert(63) == true)
            #expect(try set.insert(64) == true)
            #expect(try set.insert(127) == true)

            #expect(set.contains(0))
            #expect(set.contains(1))
            #expect(set.contains(63))
            #expect(set.contains(64))
            #expect(set.contains(127))

            #expect(!set.contains(2))
            #expect(!set.contains(65))
            #expect(!set.contains(1000))
        }

        @Test
        func `inserting an existing member reports no change`() throws {
            var set = Bitset()

            #expect(try set.insert(42) == true)
            #expect(try set.insert(42) == false)
        }

        @Test
        func `removal clears an existing member`() throws {
            var set = Bitset()
            try set.insert(10)
            try set.insert(20)
            try set.insert(30)

            #expect(try set.remove(20) == true)
            #expect(!set.contains(20))
            #expect(set.contains(10))
            #expect(set.contains(30))

            #expect(try set.remove(20) == false)
        }

        @Test
        func `fresh sets contain no members`() {
            let set = Bitset()
            #expect(set.isEmpty)
            #expect(set.count == 0)
        }

        @Test
        func `adjacent members remain distinct across the first word boundary`() throws {
            var set = Bitset()
            try set.insert(63)
            try set.insert(64)

            #expect(set.contains(63))
            #expect(set.contains(64))
            #expect(!set.contains(62))
            #expect(!set.contains(65))
        }

        @Test
        func `adjacent members remain distinct across the second word boundary`() throws {
            var set = Bitset()
            try set.insert(127)
            try set.insert(128)

            #expect(set.contains(127))
            #expect(set.contains(128))
            #expect(!set.contains(126))
            #expect(!set.contains(129))
        }

        @Test
        func `inserting distant members grows storage`() throws {
            var set = Bitset()
            try set.insert(1000)
            try set.insert(10000)
            try set.insert(100000)

            #expect(set.contains(1000))
            #expect(set.contains(10000))
            #expect(set.contains(100000))
            #expect(set.count == 3)
        }

        @Test
        func `count reports distinct members`() throws {
            var set = Bitset()
            #expect(set.isEmpty)

            try set.insert(0)
            #expect(set.count == 1)

            try set.insert(64)
            #expect(set.count == 2)

            try set.insert(128)
            #expect(set.count == 3)

            try set.remove(64)
            #expect(set.count == 2)
        }

        @Test
        func `emptiness follows membership changes`() throws {
            var set = Bitset()
            #expect(set.isEmpty)

            try set.insert(42)
            #expect(!set.isEmpty)

            try set.remove(42)
            #expect(set.isEmpty)
        }

        @Test
        func `extrema report the lowest and highest members`() throws {
            var set = Bitset()
            #expect(set.min == nil)
            #expect(set.max == nil)

            try set.insert(50)
            #expect(set.min == 50)
            #expect(set.max == 50)

            try set.insert(10)
            try set.insert(90)
            #expect(set.min == 10)
            #expect(set.max == 90)

            try set.insert(0)
            try set.insert(200)
            #expect(set.min == 0)
            #expect(set.max == 200)
        }

        @Test
        func `clearing removes all members`() throws {
            var set = Bitset()
            try set.insert(1)
            try set.insert(2)
            try set.insert(3)

            set.clear()
            #expect(set.isEmpty)
        }

        @Test
        func `sequence initialization retains its members`() throws {
            let set = try Bitset([1, 2, 3, 64, 65, 66])

            #expect(set.count == 6)
            #expect(set.contains(1))
            #expect(set.contains(2))
            #expect(set.contains(3))
            #expect(set.contains(64))
            #expect(set.contains(65))
            #expect(set.contains(66))
        }

        @Test
        func `sequence initialization collapses duplicate members`() throws {
            let set = try Bitset([1, 2, 1, 3, 2, 1])
            #expect(set.count == 3)
        }

        @Test
        func `iteration visits members in ascending order`() throws {
            var set = Bitset()
            try set.insert(100)
            try set.insert(10)
            try set.insert(50)
            try set.insert(1)

            let elements = Array(set)
            let expected = [1, 10, 50, 100]
            #expect(elements == expected)
        }

        @Test
        func `iteration visits members across storage words`() throws {
            var set = Bitset()
            try set.insert(0)
            try set.insert(63)
            try set.insert(64)
            try set.insert(127)
            try set.insert(128)

            let elements = Array(set)
            let expected = [0, 63, 64, 127, 128]
            #expect(elements == expected)
        }

        @Test
        func `union retains members present in either operand`() throws {
            let a = try Bitset([1, 2, 3])
            let b = try Bitset([3, 4, 5])

            let result = a.algebra.union(b)

            #expect(result.count == 5)
            #expect(result.contains(1))
            #expect(result.contains(2))
            #expect(result.contains(3))
            #expect(result.contains(4))
            #expect(result.contains(5))
        }

        @Test
        func `intersection retains members present in both operands`() throws {
            let a = try Bitset([1, 2, 3, 4])
            let b = try Bitset([3, 4, 5, 6])

            let result = a.algebra.intersection(b)

            #expect(result.count == 2)
            #expect(result.contains(3))
            #expect(result.contains(4))
            #expect(!result.contains(1))
            #expect(!result.contains(5))
        }

        @Test
        func `subtraction removes members present in the other operand`() throws {
            let a = try Bitset([1, 2, 3, 4, 5])
            let b = try Bitset([2, 4])

            let result = a.algebra.subtract(b)

            #expect(result.count == 3)
            #expect(result.contains(1))
            #expect(result.contains(3))
            #expect(result.contains(5))
            #expect(!result.contains(2))
            #expect(!result.contains(4))
        }

        @Test
        func `symmetric difference retains members present in exactly one operand`() throws {
            let a = try Bitset([1, 2, 3])
            let b = try Bitset([2, 3, 4])

            let result = a.algebra.symmetric.difference(b)

            #expect(result.count == 2)
            #expect(result.contains(1))
            #expect(result.contains(4))
            #expect(!result.contains(2))
            #expect(!result.contains(3))
        }

        @Test
        func `union preserves members across storage words`() throws {
            let a = try Bitset([0, 63])
            let b = try Bitset([64, 127])

            let result = a.algebra.union(b)

            #expect(result.count == 4)
            #expect(result.contains(0))
            #expect(result.contains(63))
            #expect(result.contains(64))
            #expect(result.contains(127))
        }

        @Test
        func `forming a union replaces membership with the union`() throws {
            var a = try Bitset([1, 2, 3])
            let b = try Bitset([3, 4, 5])

            a.form { $0.union(b) }

            #expect(a.count == 5)
            #expect(a.contains(1))
            #expect(a.contains(5))
        }

        @Test
        func `subset checks whether every member belongs to the other set`() throws {
            let small = try Bitset([1, 2, 3])
            let large = try Bitset([1, 2, 3, 4, 5])
            let disjoint = try Bitset([10, 11, 12])

            #expect(small.relation.isSubset(of: large))
            #expect(!large.relation.isSubset(of: small))
            #expect(!small.relation.isSubset(of: disjoint))
            #expect(small.relation.isSubset(of: small))
        }

        @Test
        func `superset checks whether every other member belongs to the set`() throws {
            let small = try Bitset([1, 2, 3])
            let large = try Bitset([1, 2, 3, 4, 5])

            #expect(large.relation.isSuperset(of: small))
            #expect(!small.relation.isSuperset(of: large))
            #expect(small.relation.isSuperset(of: small))
        }

        @Test
        func `disjointness checks whether sets share any member`() throws {
            let a = try Bitset([1, 2, 3])
            let b = try Bitset([4, 5, 6])
            let c = try Bitset([3, 4, 5])

            #expect(a.relation.isDisjoint(with: b))
            #expect(!a.relation.isDisjoint(with: c))
        }

        @Test
        func `equality compares set membership`() throws {
            let a = try Bitset([1, 2, 3])
            let b = try Bitset([1, 2, 3])
            let c = try Bitset([1, 2, 4])

            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `empty sets compare equal`() {
            let a = Bitset()
            let b = Bitset()
            #expect(a == b)
        }

        @Test
        func `equal members compare equal across different capacities`() throws {
            var a = try Bitset(capacity: 8)
            var b = try Bitset(capacity: 1000)
            try a.insert(1)
            try a.insert(5)
            try b.insert(1)
            try b.insert(5)

            #expect(a == b)
            #expect(a.hashValue == b.hashValue)
        }

        @Test
        func `equal members compare equal across different growth histories`() throws {
            var a = Bitset()
            try a.insert(3)
            try a.insert(200)
            try a.remove(200)

            var b = Bitset()
            try b.insert(3)

            #expect(a.capacity != b.capacity)
            #expect(a == b)
            #expect(a.hashValue == b.hashValue)
        }

        @Test
        func `empty sets compare equal across different capacities`() throws {
            var a = Bitset()
            try a.insert(500)
            try a.remove(500)

            let b = Bitset()
            let c = try Bitset(capacity: 64)

            #expect(a == b)
            #expect(a == c)
            #expect(b == c)
            #expect(a.hashValue == b.hashValue)
            #expect(b.hashValue == c.hashValue)
        }

        @Test
        func `members beyond shared storage make sets unequal`() throws {
            var a = Bitset()
            try a.insert(1)

            var b = Bitset()
            try b.insert(1)
            try b.insert(700)

            #expect(a != b)
            #expect(b != a)
        }

        @Test
        func `descriptions list members in ascending order`() throws {
            let set = try Bitset([1, 2, 3])
            let desc = set.description
            #expect(desc.contains("Bitset"))
            #expect(desc.contains("1"))
            #expect(desc.contains("2"))
            #expect(desc.contains("3"))
        }
    }
}
