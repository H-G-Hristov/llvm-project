//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// REQUIRES: std-at-least-c++20

// Check that functions are marked [[nodiscard]]

#include <cstddef>
#include <ranges>
#include <utility>

struct BorrowedRange {
  int* begin() const { return nullptr; }
};

template <>
inline constexpr bool std::ranges::enable_borrowed_range<BorrowedRange> = true;

void test() {
  // [range.access.begin]

  // [range.access.end]

  // [range.access.cbegin]

  // [range.access.cend]

  // [range.access.rbegin]

  // [range.access.rend]

  // [range.access.crbegin]

  // [range.access.crend]

  // [range.prim.size]

  // [range.prim.ssize]

  // [range.prim.size.hint]

  // [range.prim.empty]

  {
    struct EmptyMemberRange {
      int* begin();
      bool empty() const { return true; };
    };

    struct SizeMemberRange {
      int* begin() { return nullptr; };
      std::size_t size() const { return 0; }
    };

    struct BeginEndComparableRange {
      struct Sentinel {
        constexpr bool operator==(int*) const { return true; }
      };

      int* begin() { return nullptr; };
      Sentinel end() { return {}; };
    };

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::empty(EmptyMemberRange{});

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::empty(SizeMemberRange{});

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::empty(BeginEndComparableRange{});
  }

  // [range.prim.data]

  {
    struct DataMemberRange {
      int* begin();
      int* data() { return nullptr; }
    } dataMemberRange;

    struct Range {
      int* begin() { return nullptr; }
    } range;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::data(dataMemberRange);

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::data(range);
  }

  // [range.prim.cdata]

  {
    struct Range {
      int* begin() const { return nullptr; }
    } range;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::cdata(range);

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::cdata(BorrowedRange{});
  }
}
