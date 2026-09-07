import Testing

@testable import Bitset

@Suite
struct `Bitset capacities remain representable` {
    @Test(arguments: [0, 1, 63, 64, 65, 127, 128, 129, Int.max - 64, Int.max - 63, Int.max - 1, Int.max])
    func `storage rounding gives the smallest whole word extent containing every requested bit`(_ capacity: Int) {
        let words = Bitset.storageWordCount(for: capacity)
        let coveredBits = UInt(words) * UInt(UInt.bitWidth)
        #expect(coveredBits >= UInt(capacity))
        #expect(coveredBits - UInt(capacity) < UInt(UInt.bitWidth))
        #expect(words == 0 || UInt(words - 1) * UInt(UInt.bitWidth) < UInt(capacity))
        #expect(UInt(words) * UInt(MemoryLayout<UInt>.stride) <= UInt(Int.max))
    }

    @Test
    func `static word capacities accept the largest representable product and reject overflow`() {
        let last = Int.max / UInt.bitWidth
        #expect(Bitset.bitCapacity(forWordCount: 0) == 0)
        #expect(Bitset.bitCapacity(forWordCount: last) == Int.max - Int.max % UInt.bitWidth)
        #expect(Bitset.bitCapacity(forWordCount: last + 1) == nil)
        #expect(Bitset.bitCapacity(forWordCount: Int.max) == nil)
        #expect(Bitset.bitCapacity(forWordCount: -1) == nil)
        #expect(Bitset.bitCapacity(forWordCount: Int.min) == nil)
    }

    @Test(arguments: [0, 1, 63, 64, 65, 127, 128, 129])
    func `allocated capacity excludes padding bits across word boundaries`(_ capacity: Int) throws {
        var dynamic = try Bitset(capacity: capacity)
        var fixed = try Bitset.Fixed(capacity: capacity)
        for member in 0..<capacity {
            try dynamic.insert(member)
            try fixed.insert(member)
        }
        #expect(dynamic.capacity == capacity)
        #expect(fixed.capacity == capacity)
        #expect(dynamic.count == capacity)
        #expect(fixed.count == capacity)
        #expect(Array(dynamic) == Array(0..<capacity))
        var fixedMembers: [Int] = []
        fixed.forEach { fixedMembers.append($0) }
        #expect(fixedMembers == Array(0..<capacity))
        #expect(!dynamic.contains(capacity))
        #expect(!fixed.contains(capacity))
        #expect(!dynamic.contains(Int.max))
        #expect(!fixed.contains(Int.min))
    }

    @Test
    func `failed dynamic mutations preserve both membership and capacity`() throws {
        var bitset = try Bitset([0, 63, 64])
        let original = bitset
        let capacity = bitset.capacity
        for member in [Int.min, -1, Int.max] {
            do throws(Bitset.Error) {
                try bitset.insert(member)
                Issue.record("Expected an unrepresentable member to fail")
            } catch {
                #expect(error == .bounds(.init(member: member, capacity: capacity)))
            }
            #expect(bitset == original)
            #expect(bitset.capacity == capacity)
        }
        for member in [Int.min, -1, capacity, Int.max] {
            do throws(Bitset.Error) {
                try bitset.remove(member)
                Issue.record("Expected removal outside capacity to fail")
            } catch {
                #expect(error == .bounds(.init(member: member, capacity: capacity)))
            }
            #expect(bitset == original)
            #expect(bitset.capacity == capacity)
        }
    }

    @Test
    func `fixed failures distinguish overflow from bounds without changing storage`() throws {
        var bitset = try Bitset.Fixed(capacity: 65) { 0; 64 }
        let original = bitset
        for member in [Int.min, -1, 65, Int.max] {
            do throws(Bitset.Fixed.Error) {
                try bitset.insert(member)
                Issue.record("Expected fixed insertion outside capacity to fail")
            } catch {
                if member < 0 {
                    #expect(error == .bounds(.init(member: member, capacity: 65)))
                } else {
                    #expect(error == .overflow(.init()))
                }
            }
            #expect(bitset == original)
            do throws(Bitset.Fixed.Error) {
                try bitset.remove(member)
                Issue.record("Expected fixed removal outside capacity to fail")
            } catch {
                #expect(error == .bounds(.init(member: member, capacity: 65)))
            }
            #expect(bitset == original)
        }
    }

    @Test
    func `static failures retain their specialization and leave membership unchanged`() throws {
        var bitset = try Bitset.Static<2> { 0; 127 }
        let original = bitset
        for member in [Int.min, -1, 128, Int.max] {
            do throws(Bitset.Static<2>.Error) {
                try bitset.insert(member)
                Issue.record("Expected static insertion outside capacity to fail")
            } catch {
                if member < 0 {
                    #expect(error == .bounds(.init(member: member, capacity: 128)))
                } else {
                    #expect(error == .overflow(.init()))
                }
            }
            #expect(bitset == original)
            do throws(Bitset.Static<2>.Error) {
                try bitset.remove(member)
                Issue.record("Expected static removal outside capacity to fail")
            } catch {
                #expect(error == .bounds(.init(member: member, capacity: 128)))
            }
            #expect(bitset == original)
        }
    }

    @Test
    func `constructors and builders throw errors in their owning domains`() {
        #expect(throws: Bitset.Error.invalidCapacity(.init())) {
            _ = try Bitset(capacity: Int.min)
        }
        #expect(throws: Bitset.Fixed.Error.invalidCapacity(.init())) {
            _ = try Bitset.Fixed(capacity: -1)
        }
        #expect(throws: Bitset.Error.bounds(.init(member: Int.max, capacity: 2))) {
            _ = try Bitset { 1; Int.max }
        }
        #expect(throws: Bitset.Error.bounds(.init(member: -1, capacity: 2))) {
            _ = try Bitset([1, -1])
        }
        #expect(throws: Bitset.Fixed.Error.overflow(.init())) {
            _ = try Bitset.Fixed(capacity: 2) { 1; 2 }
        }
        #expect(throws: Bitset.Static<1>.Error.overflow(.init())) {
            _ = try Bitset.Static<1> { 1; 64 }
        }
        let dynamic: any Error = Bitset.Error.bounds(.init(member: 1, capacity: 0))
        let fixed: any Error = Bitset.Fixed.Error.bounds(.init(member: 1, capacity: 0))
        let singleWord: any Error = Bitset.Static<1>.Error.overflow(.init())
        #expect(!(dynamic is Bitset.Fixed.Error))
        #expect(!(fixed is Bitset.Error))
        #expect(!(singleWord is Bitset.Static<2>.Error))
    }

    @Test
    func `zero word static sets are empty and reject insertion with overflow`() {
        var bitset = Bitset.Static<0>()
        #expect(bitset.capacity == 0)
        #expect(bitset.isEmpty)
        #expect(bitset.count == 0)
        #expect(!bitset.contains(0))
        #expect(throws: Bitset.Static<0>.Error.overflow(.init())) {
            try bitset.insert(0)
        }
        #expect(bitset.isEmpty)
    }

    @Test
    func `exhausted iterators keep returning no member`() throws {
        var empty = Bitset().makeIterator()
        for _ in 0..<100 { #expect(empty.next() == nil) }
        var iterator = try Bitset([0, 64]).makeIterator()
        #expect(iterator.next() == 0)
        #expect(iterator.next() == 64)
        #expect(iterator.next() == nil)
        for _ in 0..<100 { #expect(iterator.next() == nil) }
    }
}
