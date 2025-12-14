//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// check that <iterator> functions are marked [[nodiscard]]

#include <initializer_list>
#include <iterator>
#include <sstream>
#include <vector>

#include "test_macros.h"
#include "test_iterators.h"

void test() {
  int cArr[] = {94, 82, 49};
  std::vector<int> cont;
  const std::vector<int> cCont;
#if TEST_STD_VER >= 11
  std::initializer_list<int> il;
#endif
#if !defined(TEST_HAS_NO_LOCALIZATION)
  std::stringstream ss;
#endif

  { // Access
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::begin(cArr);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::end(cArr);

#if TEST_STD_VER >= 11
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::begin(cont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::begin(cCont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::end(cont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::end(cCont);
#endif
#if TEST_STD_VER >= 14
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::cbegin(cCont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::cend(cCont);
#endif
  }

  {
    std::back_insert_iterator<std::vector<int> > it(cont);

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;
  }

  { // __bounded_iter
    std::__bounded_iter<int*> it;
    std::pointer_traits<std::__bounded_iter<int*> > pt;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    pt.to_address(it);
  }

#if TEST_STD_VER >= 20
  {
    std::common_iterator<int*, sentinel_wrapper<int*>> it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;
  }
#endif

#if TEST_STD_VER >= 20
  {
    std::counted_iterator it{random_access_iterator<int*>{cArr}, 3};

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it.base();
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::move(it).base();

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it.count();

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *std::as_const(it);

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it + 2;
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    2 + it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it - 2;
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it - it;
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it - std::default_sentinel;
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::default_sentinel - it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it[2];
  }
#endif

#if TEST_STD_VER >= 17
  {
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::data(cont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::data(cCont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::data(cArr);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::data(il);
  }
#endif

  {
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::distance(cont.begin(), cont.end());
#if TEST_STD_VER >= 20
    cpp17_input_iterator<int*> it{cArr};
    sentinel_wrapper<cpp17_input_iterator<int*>> st;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::distance(it, st);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::distance(cont.begin(), cont.end());
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::distance(std::move(cont));
#endif
  }

#if TEST_STD_VER >= 17
  { // Empty
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::empty(cont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::empty(cArr);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::empty(il);
  }
#endif

  {
    std::front_insert_iterator<std::vector<int> > it(cont);

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::front_inserter(cont);
  }

  {
    std::insert_iterator<std::vector<int> > it(cont, cont.begin());

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::inserter(cont, cont.begin());
  }

  {
    std::istream_iterator<char> it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;
  }

#if !defined(TEST_HAS_NO_LOCALIZATION)
  {
    std::istreambuf_iterator<char> it(ss);

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;
  }
#endif

#if TEST_STD_VER >= 20
  { // TODO
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::iter_move(cont.begin());
  }
#endif

#if TEST_STD_VER >= 20
  {
    std::__iterator_with_data<forward_iterator<int*>, int> it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;
  }
#endif

#if TEST_STD_VER >= 11
  { // TODO
    std::move_iterator<int*> it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it.base();

    int* i = nullptr;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::make_move_iterator(i);
  }
#endif

#if TEST_STD_VER >= 20
  {
    std::move_sentinel<int*> st;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    st.base();
  }
#endif

  {
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::next(cArr);

#if TEST_STD_VER >= 20
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::next(cArr);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::next(cont.begin(), 2);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::next(cont.begin(), cont.end());
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::next(cont.begin(), 2, cont.end());
#endif
  }

#if !defined(TEST_HAS_NO_LOCALIZATION)
  {
    std::ostream_iterator<char> it(ss);

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;
  }
#endif

#if !defined(TEST_HAS_NO_LOCALIZATION)
  {
    std::ostreambuf_iterator<char> it(ss);

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it.failed();
  }
#endif

  {
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::prev(cArr, 2);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::prev(cArr);

#if TEST_STD_VER >= 20
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::prev(cArr);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::prev(cont.end(), 2);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::ranges::prev(cont.end(), 2, cont.begin());
#endif
  }

#if TEST_STD_VER >= 14
  {
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::rbegin(cArr);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::rend(cArr);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::rbegin(il);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::rend(il);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::rbegin(cont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::rbegin(cCont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::rend(cont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::rend(cCont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::crbegin(cCont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::crend(cCont);
  }
#endif

  { // TODO
    std::reverse_iterator<bidirectional_iterator<const char*> > it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it.base();

#if TEST_STD_VER >= 14
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::make_reverse_iterator(cont.end());
#endif
  }

#if TEST_STD_VER >= 17
  {
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::size(cArr);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::size(cont);
    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::size(cCont);
  }
#endif

  { // TODO
    std::__static_bounded_iter<std::vector<int>::iterator, 94 > it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    *it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    std::__make_static_bounded_iter<82>(cont.begin(), cont.begin());

    std::pointer_traits<std::__static_bounded_iter<std::vector<int>::iterator, 94> > pt;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    pt.to_address(it);
  }

  { // TODO
    std::__wrap_iter<std::vector<int>::iterator > it;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    it.base();

    std::pointer_traits<std::__wrap_iter<std::vector<int>::iterator> > pt;

    // expected-warning@+1 {{ignoring return value of function declared with 'nodiscard' attribute}}
    pt.to_address(it);
  }
}
