//===-- include/flang/Support/LangOptions.h ---------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file defines the LangOptions interface, which holds the
//  configuration for LLVM's middle-end and back-end. It controls LLVM's code
//  generation into assembly or machine code.
//
//===----------------------------------------------------------------------===//

#ifndef FORTRAN_SUPPORT_LANGOPTIONS_H_
#define FORTRAN_SUPPORT_LANGOPTIONS_H_

#include <string>
#include <vector>

#include "llvm/TargetParser/Triple.h"

namespace Fortran::common {

/// Bitfields of LangOptions, split out from LangOptions to ensure
/// that this large collection of bitfields is a trivial class type.
class LangOptionsBase {

public:
  enum SignedOverflowBehaviorTy {
    // -fno-wrapv (default behavior in Flang)
    SOB_Undefined,

    // -fwrapv
    SOB_Defined,
  };

  enum FPModeKind {
    // Do not fuse FP ops
    FPM_Off,

    // Aggressively fuse FP ops (E.g. FMA).
    FPM_Fast,
  };

#define LANGOPT(Name, Bits, Default) unsigned Name : Bits;
#define ENUM_LANGOPT(Name, Type, Bits, Default)
#include "LangOptions.def"

protected:
#define LANGOPT(Name, Bits, Default)
#define ENUM_LANGOPT(Name, Type, Bits, Default) unsigned Name : Bits;
#include "LangOptions.def"
};

/// Tracks various options which control the dialect of Fortran that is
/// accepted. Based on clang::LangOptions
class LangOptions : public LangOptionsBase {

public:
  // Define accessors/mutators for code generation options of enumeration type.
#define LANGOPT(Name, Bits, Default)
#define ENUM_LANGOPT(Name, Type, Bits, Default) \
  Type get##Name() const { return static_cast<Type>(Name); } \
  void set##Name(Type Value) { \
    assert(static_cast<unsigned>(Value) < (1u << Bits)); \
    Name = static_cast<unsigned>(Value); \
  }
#include "LangOptions.def"

  /// Name of the IR file that contains the result of the OpenMP target
  /// host code generation.
  std::string OMPHostIRFile;

  /// List of triples passed in using -fopenmp-targets.
  std::vector<llvm::Triple> OMPTargetTriples;

  LangOptions();
};

} // end namespace Fortran::common

#endif // FORTRAN_SUPPORT_LANGOPTIONS_H_
