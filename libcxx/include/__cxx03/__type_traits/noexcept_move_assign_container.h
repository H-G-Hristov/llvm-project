//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___CXX03___TYPE_TRAITS_NOEXCEPT_MOVE_ASSIGN_CONTAINER_H
#define _LIBCPP___CXX03___TYPE_TRAITS_NOEXCEPT_MOVE_ASSIGN_CONTAINER_H

#include <__cxx03/__config>
#include <__cxx03/__memory/allocator_traits.h>
#include <__cxx03/__type_traits/integral_constant.h>
#include <__cxx03/__type_traits/is_nothrow_assignable.h>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

_LIBCPP_BEGIN_NAMESPACE_STD

template <typename _Alloc, typename _Traits = allocator_traits<_Alloc> >
struct __noexcept_move_assign_container
    : public integral_constant<bool,
                               _Traits::propagate_on_container_move_assignment::value &&
                                   is_nothrow_move_assignable<_Alloc>::value> {};

_LIBCPP_END_NAMESPACE_STD

#endif // _LIBCPP___CXX03___TYPE_TRAITS_NOEXCEPT_MOVE_ASSIGN_CONTAINER_H
