import Testing

@testable import Bitset

@Suite struct `Bitset.Static Tests` {
    @Suite struct `Unit behavior` {
        @Test
        func `static builders retain members within their capacity`() throws {
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
    @Suite struct `Integration behavior` {}
}

extension Bitset.Fixed {
    @Suite
    struct `Behavior contracts` {
        @Test
        func `fixed builders retain members within their capacity`() throws {
            let b = try Bitset.Fixed(capacity: 16) {
                1
                5
                10
            }
            #expect(b.contains(5))
        }

        @Test
        func `fixed builders reject members beyond their capacity`() {
            do throws(Bitset.Fixed.Error) {
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
