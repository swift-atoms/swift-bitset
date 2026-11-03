# swift-bitset

Use this package when you need a set of small nonnegative integers (indices, ids, positions) stored densely as one bit per possible member, so memory grows with the largest member, not with how many members there are. Start from `Bitset`, which grows as you insert. Use `Bitset.Fixed` when the capacity is known only at run time and must never be exceeded, and `Bitset.Static<wordCount>` when it is known at compile time and the bits should be stored inline. For members that are not small integers, use swift-set. For a mask of bits inside one fixed-width integer, use swift-bit-pattern.

## Laws

- Members range over `0..<capacity`. `contains` answers `false` outside that range and never fails.
- `insert` returns whether the member was absent before, and `remove` returns whether it was present. A failed `insert` or `remove` leaves both the members and the capacity unchanged.
- `Bitset` grows on `insert`: inserting a member at or above `capacity` raises `capacity` to that member plus one. Negative members and `Int.max` fail with `Bitset.Error.bounds`. `remove` outside `0..<capacity` also fails with `Bitset.Error.bounds`, even though the member is absent.
- `Bitset.Fixed` and `Bitset.Static<wordCount>` never grow. `insert` at or above `capacity` fails with `overflow`, a negative member fails with `bounds`, and `remove` anywhere outside `0..<capacity` fails with `bounds`.
- `Bitset.Static<wordCount>` has a capacity of `wordCount` × `UInt.bitWidth`. `Bitset.Static<0>` has capacity 0 and rejects every insertion.
- `capacity` never shrinks. `remove`, `removeAll` and `clear` keep it.
- `Bitset` equality and hashing depend on membership only. Two values with the same members are equal and hash equally, whatever their capacities or growth histories.
- `Bitset` and `Bitset.Fixed` visit members in ascending order. An exhausted `Bitset.Iterator` keeps returning `nil`.
- Union, intersection, subtraction and symmetric difference return a new value and leave both operands unchanged. `form` replaces the receiver with the result. Union and symmetric difference are commutative.
- For `Bitset`, union and symmetric difference have the larger of the two capacities, while intersection and subtraction keep the receiver's capacity. Subset, superset and disjointness ignore capacity.
- `Bitset.Fixed` algebra and relations require both operands to have the same capacity, and stop the process when they don't.
- A builder ignores duplicate members and `nil` members. It inserts members in order, so it fails exactly where the first failing `insert` would.
