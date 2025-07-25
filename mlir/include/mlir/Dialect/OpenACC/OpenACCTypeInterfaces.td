//===-- OpenACCTypeInterfaces.td - OpenACC type interfaces ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef OPENACC_TYPE_INTERFACES
#define OPENACC_TYPE_INTERFACES

include "mlir/IR/OpBase.td"

def OpenACC_PointerLikeTypeInterface : TypeInterface<"PointerLikeType"> {
  let cppNamespace = "::mlir::acc";

  let description = [{
    This is a minimal interface to interact with acc dialect data clause
    operations to represent an OpenACC variable. The reason for its existence
    is to create a minimal contract between a source dialect and the acc
    dialect - and it works on the basis that this is a pointer that can
    be mapped to device memory. This exists for the following reasons:
    - Many dialects choose to represent their variables as pointers.
      Specifically locals are created with some form of `alloca` and globals
      are referred through by their address.
    - Eventually all such pointers end up as LLVM pointers along with LLVM
      types whose size is computable. This is the minimal information needed
      to map a variable.
    - The OpenACC spec describes reference counters in terms of memory
      addressability. In 2.6.7. It says: "A structured reference counter
      is incremented when entering each data or compute region that contain
      an explicit data clause or implicitly-determined data attributes for
      that section of memory". This implies addressability of memory.
    - Attach semantics (2.6.8 attachment counter) are specified using
      "address" terminology: "The attachment counter for a pointer is set to
      one whenever the pointer is attached to new target address, and
      incremented whenever an attach action for that pointer is performed for
      the same target address."
  }];

  // By convention, any of the pointer types associated with this interface
  // will need to provide getElementType.
  let methods = [
    InterfaceMethod<
      /*description=*/[{
        Returns the pointee type or null if the pointer has no pointee type
      }],
      /*retTy=*/"::mlir::Type",
      /*methodName=*/"getElementType"
    >,
    InterfaceMethod<
      /*description=*/[{
        Returns the type category of the pointee. The `var` is provided because
        a dialect's type system may be incomplete. For example, consider a
        dialect which computes interior pointers - so a float array element
        may be represented as `ptr<f32>`. The type system says the pointee
        is `f32` but this is not a scalar from the point-of-view of OpenACC.
        It is an array element and thus the appropriate type category is
        "array" - therefore being able to look up how a variable is computed
        is important for a complete type determination.
        The `varType` is provided in cases where a dialect's type system
        erased the target type.
      }],
      /*retTy=*/"::mlir::acc::VariableTypeCategory",
      /*methodName=*/"getPointeeTypeCategory",
      /*args=*/(ins "::mlir::TypedValue<::mlir::acc::PointerLikeType>":$varPtr,
                    "::mlir::Type":$varType),
      /*methodBody=*/"",
      /*defaultImplementation=*/[{
        return ::mlir::acc::VariableTypeCategory::uncategorized;
      }]
    >,
  ];
}

def OpenACC_MappableTypeInterface : TypeInterface<"MappableType"> {
  let cppNamespace = "::mlir::acc";

  let description = [{
    This interface is a richer contract than being a pointer-like type
    and can be used in conjunction with it.
    It should be attached to types that a source dialect considers to
    be variables. And unlike pointer-like type, it can be attached to variables
    which the source dialect does not represent through the use of memory.
    The richer API allows for post-frontend type-based semantics to be
    applied such as generating recipes or extracting array bounds.
  }];

  let methods = [
    InterfaceMethod<
      /*description=*/[{
        Returns the pointer to the `var` if recoverable (such as in cases
        where the current operation is a load from a memory slot).
      }],
      /*retTy=*/"::mlir::TypedValue<::mlir::acc::PointerLikeType>",
      /*methodName=*/"getVarPtr",
      /*args=*/(ins "::mlir::Value":$var),
      /*methodBody=*/"",
      /*defaultImplementation=*/[{
        if (auto ptr = mlir::dyn_cast<mlir::TypedValue<mlir::acc::PointerLikeType>>(
              var))
          return ptr;
        return {};
      }]
    >,
    InterfaceMethod<
      /*description=*/[{
        Returns the size in bytes when computable. If this is an array-like
        type, avoiding passing `accBounds` ensures a computation of the size
        of whole type.
      }],
      /*retTy=*/"::std::optional<::llvm::TypeSize>",
      /*methodName=*/"getSizeInBytes",
      /*args=*/(ins "::mlir::Value":$var,
                    "::mlir::ValueRange":$accBounds,
                    "const ::mlir::DataLayout &":$dataLayout),
      /*methodBody=*/"",
      /*defaultImplementation=*/[{
        // Bounds operations are typically created for array types. In the
        // generic implementation, it is not straightforward to distinguish
        // between array types and ensure the size and offset take into account
        // just the slice requested. Thus return not-computable for now.
        if (!accBounds.empty())
          return {};
        return {dataLayout.getTypeSize($_type)};
      }]
    >,
    InterfaceMethod<
      /*description=*/[{
        Returns the offset in bytes when computable.
      }],
      /*retTy=*/"::std::optional<::int64_t>",
      /*methodName=*/"getOffsetInBytes",
      /*args=*/(ins "::mlir::Value":$var,
                    "::mlir::ValueRange":$accBounds,
                    "const ::mlir::DataLayout &":$dataLayout),
      /*methodBody=*/"",
      /*defaultImplementation=*/[{
        // Bounds operations are typically created for array types. In the
        // generic implementation, it is not straightforward to distinguish
        // between array types and ensure the size and offset take into account
        // just the slice requested. Thus return not-computable for now.
        if (!accBounds.empty())
          return {};

        // If the type size is computable, it means it is trivial. Assume
        // offset of 0.
        if (::mlir::cast<::mlir::acc::MappableType>($_type).getSizeInBytes(
              var, accBounds, dataLayout).has_value()) {
          return {0};
        }

        return {};
      }]
    >,
    InterfaceMethod<
      /*description=*/[{
        Returns explicit `acc.bounds` operations that envelop the whole
        data structure. These operations are inserted using the provided builder
        at the location set before calling this API.
      }],
      /*retTy=*/"::llvm::SmallVector<::mlir::Value>",
      /*methodName=*/"generateAccBounds",
      /*args=*/(ins "::mlir::Value":$var,
                    "::mlir::OpBuilder &":$builder),
      /*methodBody=*/"",
      /*defaultImplementation=*/[{
        return {};
      }]
    >,
    InterfaceMethod<
      /*description=*/[{
        Returns the OpenACC type category.
      }],
      /*retTy=*/"::mlir::acc::VariableTypeCategory",
      /*methodName=*/"getTypeCategory",
      /*args=*/(ins "::mlir::Value":$var),
      /*methodBody=*/"",
      /*defaultImplementation=*/[{
        return ::mlir::acc::VariableTypeCategory::uncategorized;
      }]
    >,
      InterfaceMethod<
      /*description=*/[{
        Generates the operations that would be normally placed in a recipe's
        init region. It inserts at the builder's current location.
        It can be used either to directly "inline" the init region
        or if the caller sets the insertion point to inside a recipe body,
        it fills it in. This does not generate the `acc.yield` that normally
        would terminate a recipe.

        The `extents` are optional and can be empty - it is only when a
        slice of the private variable needs allocation.
        The `initVal` can be empty - it is primarily needed for reductions
        to ensure the variable is also initialized with appropriate value.

        If the return value is empty, it means that recipe body was not
        successfully generated.
      }],
      /*retTy=*/"::mlir::Value",
      /*methodName=*/"generatePrivateInit",
      /*args=*/(ins "::mlir::OpBuilder &":$builder,
                    "::mlir::Location":$loc,
                    "::mlir::TypedValue<::mlir::acc::MappableType>":$var,
                    "::llvm::StringRef":$varName,
                    "::mlir::ValueRange":$extents,
                    "::mlir::Value":$initVal),
      /*methodBody=*/"",
      /*defaultImplementation=*/[{
        return {};
      }]
    >,
  ];
}

#endif // OPENACC_TYPE_INTERFACES
