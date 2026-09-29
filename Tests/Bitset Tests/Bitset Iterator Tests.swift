import Bitset
import Iterator
import Testing

@Suite
struct `Bitset iterators conform to Institute iteration` {

    @Test
    func `bitset iterator satisfies Institute iteration`() throws {
        var bitset = Bitset()
        try bitset.insert(7)
        try bitset.insert(2)
        try bitset.insert(11)

        #expect(collect(bitset.makeIterator()) == [2, 7, 11])
    }

    private func collect<I: Iterating>(_ source: consuming I) -> [Int]
    where I.Element == Int, I.Failure == Never {
        var iterator = source
        var result: [Int] = []
        while let element = iterator.next() {
            result.append(element)
        }
        return result
    }
}
