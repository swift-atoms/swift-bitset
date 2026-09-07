import Testing

@testable import Bitset

@Suite struct `Static bitset builders preserve members within their capacity` {
    @Suite struct `Static builders construct sets from bounded member expressions` {
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

    @Suite struct `No static bitset builder boundary cases are defined` {}
    @Suite struct `No static bitset builder integration behavior cases are defined` {}
}

extension Bitset.Fixed {
    @Suite
    struct `Fixed bitset builders enforce their capacity boundary` {
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
