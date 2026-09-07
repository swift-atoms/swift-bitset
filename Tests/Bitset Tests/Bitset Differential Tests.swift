import Testing

@testable import Bitset

@Suite
struct `Bitset operations agree with finite integer sets` {
    private func members(_ value: Bitset.Fixed) -> Set<Int> {
        var result: Set<Int> = []
        value.forEach { result.insert($0) }
        return result
    }

    private func members<let words: Int>(_ value: Bitset.Static<words>) -> Set<Int> {
        var result: Set<Int> = []
        value.forEach { result.insert($0) }
        return result
    }

    @Test(arguments: [UInt64(1), 23, 901])
    func `mixed mutations preserve membership across dynamic fixed and static storage`(_ seed: UInt64) throws {
        var dynamic = try Bitset(capacity: 192)
        var fixed = try Bitset.Fixed(capacity: 192)
        var inline = Bitset.Static<3>()
        var expected: Set<Int> = []
        var state = seed
        for step in 0..<600 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            let member = Int((state >> 16) % 192)
            if state & 4 == 0 {
                let inserted = expected.insert(member).inserted
                let dynamicInserted = try dynamic.insert(member)
                let fixedInserted = try fixed.insert(member)
                let staticInserted = try inline.insert(member)
                #expect(dynamicInserted == inserted)
                #expect(fixedInserted == inserted)
                #expect(staticInserted == inserted)
            } else {
                let removed = expected.remove(member) != nil
                let dynamicRemoved = try dynamic.remove(member)
                let fixedRemoved = try fixed.remove(member)
                let staticRemoved = try inline.remove(member)
                #expect(dynamicRemoved == removed)
                #expect(fixedRemoved == removed)
                #expect(staticRemoved == removed)
            }
            #expect(dynamic.count == expected.count)
            #expect(fixed.count == expected.count)
            #expect(inline.count == expected.count)
            #expect(dynamic.min == expected.min())
            #expect(dynamic.max == expected.max())
            if step.isMultiple(of: 25) {
                #expect(Array(dynamic) == expected.sorted())
                #expect(members(fixed) == expected)
                #expect(members(inline) == expected)
            }
        }
        dynamic.removeAll()
        fixed.removeAll()
        inline.removeAll()
        #expect(dynamic.isEmpty && fixed.isEmpty && inline.isEmpty)
        #expect(dynamic.capacity == 192 && fixed.capacity == 192 && inline.capacity == 192)
    }

    @Test(arguments: [0, 1, 63, 64, 65, 127, 128, 129, 191, 192, 193])
    func `algebra and relations preserve members across unequal partial word capacities`(_ leftCapacity: Int) throws {
        let rightCapacity = 193 - leftCapacity
        let leftMembers = Set((0..<leftCapacity).filter { $0.isMultiple(of: 3) || $0 % 64 == 63 })
        let rightMembers = Set((0..<rightCapacity).filter { $0.isMultiple(of: 5) || $0 % 64 == 0 })
        var left = try Bitset(capacity: leftCapacity)
        var right = try Bitset(capacity: rightCapacity)
        for value in leftMembers { try left.insert(value) }
        for value in rightMembers { try right.insert(value) }
        let union = left.algebra.union(right)
        let intersection = left.algebra.intersection(right)
        let subtraction = left.algebra.subtract(right)
        let symmetric = left.algebra.symmetric.difference(right)
        #expect(Set(union) == leftMembers.union(rightMembers))
        #expect(Set(intersection) == leftMembers.intersection(rightMembers))
        #expect(Set(subtraction) == leftMembers.subtracting(rightMembers))
        #expect(Set(symmetric) == leftMembers.symmetricDifference(rightMembers))
        #expect(union.capacity == max(leftCapacity, rightCapacity))
        #expect(symmetric.capacity == max(leftCapacity, rightCapacity))
        #expect(intersection.capacity == leftCapacity)
        #expect(subtraction.capacity == leftCapacity)
        #expect(left.relation.isSubset(of: right) == leftMembers.isSubset(of: rightMembers))
        #expect(left.relation.isSuperset(of: right) == leftMembers.isSuperset(of: rightMembers))
        #expect(left.relation.isDisjoint(with: right) == leftMembers.isDisjoint(with: rightMembers))
        #expect(left.algebra.union(right) == right.algebra.union(left))
        #expect(left.algebra.symmetric.difference(right) == right.algebra.symmetric.difference(left))
        let before = left
        var updated = left
        updated.form { $0.union(right) }
        #expect(updated == union)
        #expect(left == before && Set(left) == leftMembers)
        let compact = try Bitset(leftMembers)
        #expect(compact == left)
        #expect(Set([compact, left]).count == 1)

        let fixedCapacity = max(leftCapacity, rightCapacity)
        var fixedLeft = try Bitset.Fixed(capacity: fixedCapacity)
        var fixedRight = try Bitset.Fixed(capacity: fixedCapacity)
        var staticLeft = Bitset.Static<4>()
        var staticRight = Bitset.Static<4>()
        for value in leftMembers {
            try fixedLeft.insert(value)
            try staticLeft.insert(value)
        }
        for value in rightMembers {
            try fixedRight.insert(value)
            try staticRight.insert(value)
        }
        #expect(members(fixedLeft.algebra.union(fixedRight)) == leftMembers.union(rightMembers))
        #expect(members(fixedLeft.algebra.intersection(fixedRight)) == leftMembers.intersection(rightMembers))
        #expect(members(fixedLeft.algebra.subtract(fixedRight)) == leftMembers.subtracting(rightMembers))
        #expect(members(fixedLeft.algebra.symmetric.difference(fixedRight)) == leftMembers.symmetricDifference(rightMembers))
        #expect(fixedLeft.relation.isSubset(of: fixedRight) == leftMembers.isSubset(of: rightMembers))
        #expect(fixedLeft.relation.isSuperset(of: fixedRight) == leftMembers.isSuperset(of: rightMembers))
        #expect(fixedLeft.relation.isDisjoint(with: fixedRight) == leftMembers.isDisjoint(with: rightMembers))
        #expect(members(staticLeft.algebra.union(staticRight)) == leftMembers.union(rightMembers))
        #expect(members(staticLeft.algebra.intersection(staticRight)) == leftMembers.intersection(rightMembers))
        #expect(members(staticLeft.algebra.subtract(staticRight)) == leftMembers.subtracting(rightMembers))
        #expect(members(staticLeft.algebra.symmetric.difference(staticRight)) == leftMembers.symmetricDifference(rightMembers))
        #expect(staticLeft.relation.isSubset(of: staticRight) == leftMembers.isSubset(of: rightMembers))
        #expect(staticLeft.relation.isSuperset(of: staticRight) == leftMembers.isSuperset(of: rightMembers))
        #expect(staticLeft.relation.isDisjoint(with: staticRight) == leftMembers.isDisjoint(with: rightMembers))
    }

    @Test
    func `fixed algebra rejects mismatched capacity domains`() async {
        await #expect(processExitsWith: .failure) {
            let left = try Bitset.Fixed(capacity: 63)
            let right = try Bitset.Fixed(capacity: 64)
            _ = left.algebra.union(right)
        }
    }
}
