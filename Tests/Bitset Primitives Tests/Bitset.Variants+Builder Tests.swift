import Testing

@testable import Bitset_Primitives

@Suite struct `Bitset.Static Tests` {
    @Suite struct Unit {
        @Test
        func `Static within capacity`() throws {
            let b = try Bitset.Static<2> {
                1
                5
                10
            }
            #expect(b.contains(5))
            #expect(b.count == 3)
        }
    }

    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension Bitset.Fixed {
    @Suite("Bitset.Fixed")
    struct Test {
        @Test
        func `Fixed within capacity`() throws {
            let b = try Bitset.Fixed(capacity: 16) {
                1
                5
                10
            }
            #expect(b.contains(5))
        }

        @Test
        func `Fixed throws on out-of-range`() {
            do throws(__BitsetFixedError) {
                _ = try Bitset.Fixed(capacity: 8) {
                    1
                    100
                }
                Issue.record("expected throw")
            } catch {

            }
        }
    }
}
