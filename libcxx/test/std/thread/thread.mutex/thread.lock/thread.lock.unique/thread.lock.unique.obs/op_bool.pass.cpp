//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <mutex>

// template <class Mutex> class unique_lock;

// explicit operator bool() const noexcept;

#include <cassert>
#include <mutex>
#include <type_traits>

#include "test_macros.h"
#include "../types.h"

MyMutex m;

int main(int, char**) {
  static_assert(std::is_constructible<bool, std::unique_lock<MyMutex> >::value, "");
  static_assert(!std::is_convertible<std::unique_lock<MyMutex>, bool>::value, "");

  std::unique_lock<MyMutex> lk0;
  assert(static_cast<bool>(lk0) == false);
  std::unique_lock<MyMutex> lk1(m);
  assert(static_cast<bool>(lk1) == true);
  lk1.unlock();
  assert(static_cast<bool>(lk1) == false);
  ASSERT_NOEXCEPT(static_cast<bool>(lk0));

  return 0;
}
