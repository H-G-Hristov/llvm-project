// RUN: mlir-opt -split-input-file -verify-diagnostics %s | mlir-opt | FileCheck %s
// RUN: mlir-opt -split-input-file -verify-diagnostics -mlir-print-op-generic %s | FileCheck %s --check-prefix=GENERIC
// RUN: mlir-opt -split-input-file -verify-diagnostics -mlir-print-debuginfo %s | mlir-opt -split-input-file -mlir-print-debuginfo | FileCheck %s --check-prefix=LOCINFO
// RUN: mlir-translate -mlir-to-llvmir -split-input-file -verify-diagnostics %s | FileCheck %s --check-prefix=CHECK-LLVM

module {
  // GENERIC: "llvm.func"
  // GENERIC-SAME: function_type = !llvm.func<void ()>
  // GENERIC-SAME: sym_name = "foo"
  // GENERIC: () -> ()
  // CHECK: llvm.func @foo()
  "llvm.func" () ({
  }) {sym_name = "foo", function_type = !llvm.func<void ()>} : () -> ()

  // GENERIC: "llvm.func"
  // GENERIC-SAME: function_type = !llvm.func<i64 (i64, i64)>
  // GENERIC-SAME: sym_name = "bar"
  // GENERIC: () -> ()
  // CHECK: llvm.func @bar(i64, i64) -> i64
  "llvm.func"() ({
  }) {sym_name = "bar", function_type = !llvm.func<i64 (i64, i64)>} : () -> ()

  // GENERIC: "llvm.func"
  // GENERIC-SAME: function_type = !llvm.func<i64 (i64)>
  // GENERIC-SAME: sym_name = "baz"
  // CHECK: llvm.func @baz(%{{.*}}: i64) -> i64
  "llvm.func"() <{sym_name = "baz", function_type = !llvm.func<i64 (i64)>}> ({
  // GENERIC: ^bb0
  ^bb0(%arg0: i64):
    // GENERIC: llvm.return
    llvm.return %arg0 : i64

  // GENERIC: () -> ()
  }) : () -> ()

  // CHECK: llvm.func @qux(!llvm.ptr {llvm.noalias}, i64)
  // CHECK: attributes {xxx = {yyy = 42 : i64}}
  "llvm.func"() ({
  }) {sym_name = "qux", function_type = !llvm.func<void (ptr, i64)>,
      arg_attrs = [{llvm.noalias}, {}], xxx = {yyy = 42}} : () -> ()

  // CHECK: llvm.func @roundtrip1()
  llvm.func @roundtrip1()

  // CHECK: llvm.func @roundtrip2(i64, f32) -> f64
  llvm.func @roundtrip2(i64, f32) -> f64

  // CHECK: llvm.func @roundtrip3(i32, i1)
  llvm.func @roundtrip3(%a: i32, %b: i1)

  // CHECK: llvm.func @roundtrip4(%{{.*}}: i32, %{{.*}}: i1) {
  llvm.func @roundtrip4(%a: i32, %b: i1) {
    llvm.return
  }

  // CHECK: llvm.func @roundtrip5()
  // CHECK: attributes {baz = 42 : i64, foo = "bar"}
  llvm.func @roundtrip5() attributes {foo = "bar", baz = 42}

  // CHECK: llvm.func @roundtrip6()
  // CHECK: attributes {baz = 42 : i64, foo = "bar"}
  llvm.func @roundtrip6() attributes {foo = "bar", baz = 42} {
    llvm.return
  }

  // CHECK: llvm.func @roundtrip7() {
  llvm.func @roundtrip7() attributes {} {
    llvm.return
  }

  // CHECK: llvm.func @roundtrip8() -> i32
  llvm.func @roundtrip8() -> i32 attributes {}

  // CHECK: llvm.func @roundtrip9(!llvm.ptr {llvm.noalias})
  llvm.func @roundtrip9(!llvm.ptr {llvm.noalias})

  // CHECK: llvm.func @roundtrip10(!llvm.ptr {llvm.noalias})
  llvm.func @roundtrip10(%arg0: !llvm.ptr {llvm.noalias})

  // CHECK: llvm.func @roundtrip11(%{{.*}}: !llvm.ptr {llvm.noalias}) {
  llvm.func @roundtrip11(%arg0: !llvm.ptr {llvm.noalias}) {
    llvm.return
  }

  // CHECK: llvm.func @roundtrip12(%{{.*}}: !llvm.ptr {llvm.noalias})
  // CHECK: attributes {foo = 42 : i32}
  llvm.func @roundtrip12(%arg0: !llvm.ptr {llvm.noalias})
  attributes {foo = 42 : i32} {
    llvm.return
  }

  // CHECK: llvm.func @byvalattr(%{{.*}}: !llvm.ptr {llvm.byval = i32})
  llvm.func @byvalattr(%arg0: !llvm.ptr {llvm.byval = i32}) {
    llvm.return
  }

  // CHECK: llvm.func @sretattr(%{{.*}}: !llvm.ptr {llvm.sret = i32})
  // LOCINFO: llvm.func @sretattr(%{{.*}}: !llvm.ptr {llvm.sret = i32} loc("some_source_loc"))
  llvm.func @sretattr(%arg0: !llvm.ptr {llvm.sret = i32} loc("some_source_loc")) {
    llvm.return
  }

  // CHECK: llvm.func @nestattr(%{{.*}}: !llvm.ptr {llvm.nest})
  llvm.func @nestattr(%arg0: !llvm.ptr {llvm.nest}) {
    llvm.return
  }

  // CHECK: llvm.func @llvm_noalias_decl(!llvm.ptr {llvm.noalias})
  llvm.func @llvm_noalias_decl(!llvm.ptr {llvm.noalias})
  // CHECK: llvm.func @byrefattr_decl(!llvm.ptr {llvm.byref = i32})
  llvm.func @byrefattr_decl(!llvm.ptr {llvm.byref = i32})
  // CHECK: llvm.func @byvalattr_decl(!llvm.ptr {llvm.byval = i32})
  llvm.func @byvalattr_decl(!llvm.ptr {llvm.byval = i32})
  // CHECK: llvm.func @sretattr_decl(!llvm.ptr {llvm.sret = i32})
  llvm.func @sretattr_decl(!llvm.ptr {llvm.sret = i32})
  // CHECK: llvm.func @nestattr_decl(!llvm.ptr {llvm.nest})
  llvm.func @nestattr_decl(!llvm.ptr {llvm.nest})
  // CHECK: llvm.func @noundefattr_decl(i32 {llvm.noundef})
  llvm.func @noundefattr_decl(i32 {llvm.noundef})
  // CHECK: llvm.func @llvm_align_decl(!llvm.ptr {llvm.align = 4 : i64})
  llvm.func @llvm_align_decl(!llvm.ptr {llvm.align = 4})
  // CHECK: llvm.func @inallocaattr_decl(!llvm.ptr {llvm.inalloca = i32})
  llvm.func @inallocaattr_decl(!llvm.ptr {llvm.inalloca = i32})


  // CHECK: llvm.func @variadic(...)
  llvm.func @variadic(...)

  // CHECK: llvm.func @variadic_args(i32, i32, ...)
  llvm.func @variadic_args(i32, i32, ...)

  //
  // Check that functions can have linkage attributes.
  //

  // CHECK: llvm.func internal
  llvm.func internal @internal_func() {
    llvm.return
  }

  // CHECK: llvm.func weak
  llvm.func weak @weak_linkage() {
    llvm.return
  }

  // CHECK-LLVM: define ptx_kernel void @calling_conv
  llvm.func ptx_kernelcc @calling_conv() {
    llvm.return
  }

  // Omit the `external` linkage, which is the default, in the custom format.
  // Check that it is present in the generic format using its numeric value.
  //
  // CHECK: llvm.func @external_func
  // GENERIC: linkage = #llvm.linkage<external>
  llvm.func external @external_func()

  // CHECK-LABEL: llvm.func @arg_struct_attr(
  // CHECK-SAME: %{{.*}}: !llvm.struct<(i32)> {llvm.struct_attrs = [{llvm.noalias}]}) {
  llvm.func @arg_struct_attr(
      %arg0 : !llvm.struct<(i32)> {llvm.struct_attrs = [{llvm.noalias}]}) {
    llvm.return
  }

   // CHECK-LABEL: llvm.func @res_struct_attr(%{{.*}}: !llvm.struct<(i32)>)
   // CHECK-SAME:-> (!llvm.struct<(i32)> {llvm.struct_attrs = [{llvm.noalias}]}) {
  llvm.func @res_struct_attr(%arg0 : !llvm.struct<(i32)>)
      -> (!llvm.struct<(i32)> {llvm.struct_attrs = [{llvm.noalias}]}) {
    llvm.return %arg0 : !llvm.struct<(i32)>
  }

  // CHECK: llvm.func @cconv1
  llvm.func ccc @cconv1() {
    llvm.return
  }

  // CHECK: llvm.func weak @cconv2
  llvm.func weak ccc @cconv2() {
    llvm.return
  }

  // CHECK: llvm.func weak fastcc @cconv3
  llvm.func weak fastcc @cconv3() {
    llvm.return
  }

  // CHECK: llvm.func cc_10 @cconv4
  llvm.func cc_10 @cconv4() {
    llvm.return
  }

  // CHECK: llvm.func @test_ccs
  llvm.func @test_ccs() {
    // CHECK-NEXT: %[[PTR:.*]] = llvm.mlir.addressof @cconv4 : !llvm.ptr
    %ptr = llvm.mlir.addressof @cconv4 : !llvm.ptr
    // CHECK-NEXT: llvm.call        @cconv1() : () -> ()
    // CHECK-NEXT: llvm.call        @cconv2() : () -> ()
    // CHECK-NEXT: llvm.call fastcc @cconv3() : () -> ()
    // CHECK-NEXT: llvm.call cc_10  %[[PTR]]() : !llvm.ptr, () -> ()
    llvm.call        @cconv1() : () -> ()
    llvm.call ccc    @cconv2() : () -> ()
    llvm.call fastcc @cconv3() : () -> ()
    llvm.call cc_10  %ptr() : !llvm.ptr, () -> ()
    llvm.return
  }

  // CHECK-LABEL: llvm.func @variadic_def
  llvm.func @variadic_def(...) {
    llvm.return
  }

  // CHECK-LABEL: llvm.func @memory_attr
  // CHECK-SAME: attributes {memory = #llvm.memory_effects<other = none, argMem = read, inaccessibleMem = readwrite>} {
  llvm.func @memory_attr() attributes {memory = #llvm.memory_effects<other = none, argMem = read, inaccessibleMem = readwrite>} {
    llvm.return
  }

  // CHECK-LABEL: llvm.func hidden @hidden
  llvm.func hidden @hidden() {
    llvm.return
  }

  // CHECK-LABEL: llvm.func protected @protected
  llvm.func protected @protected() {
    llvm.return
  }

  // CHECK-LABEL: local_unnamed_addr @local_unnamed_addr_func
  llvm.func local_unnamed_addr @local_unnamed_addr_func() {
    llvm.return
  }

  // CHECK-LABEL: @align_func
  // CHECK-SAME: attributes {alignment = 2 : i64}
  llvm.func @align_func() attributes {alignment = 2 : i64} {
    llvm.return
  }

  // CHECK: llvm.comdat @__llvm_comdat
  llvm.comdat @__llvm_comdat {
    // CHECK: llvm.comdat_selector @any any
    llvm.comdat_selector @any any
  }
  // CHECK: @any() comdat(@__llvm_comdat::@any) attributes
  llvm.func @any() comdat(@__llvm_comdat::@any) attributes { dso_local } {
    llvm.return
  }

  llvm.func @vscale_roundtrip() vscale_range(1, 2) {
    // CHECK: @vscale_roundtrip
    // CHECK-SAME: vscale_range(1, 2)
    llvm.return
  }

  // CHECK-LABEL: @frame_pointer_roundtrip()
  // CHECK-SAME: attributes {frame_pointer = #llvm.framePointerKind<"non-leaf">}
  llvm.func @frame_pointer_roundtrip() attributes {frame_pointer = #llvm.framePointerKind<"non-leaf">} {
    llvm.return
  }

  llvm.func @unsafe_fp_math_roundtrip() attributes {unsafe_fp_math = true} {
    // CHECK: @unsafe_fp_math_roundtrip
    // CHECK-SAME: attributes {unsafe_fp_math = true}
    llvm.return
  }

  llvm.func @no_infs_fp_math_roundtrip() attributes {no_infs_fp_math = true} {
    // CHECK: @no_infs_fp_math_roundtrip
    // CHECK-SAME: attributes {no_infs_fp_math = true}
    llvm.return
  }

  llvm.func @no_nans_fp_math_roundtrip() attributes {no_nans_fp_math = true} {
    // CHECK: @no_nans_fp_math_roundtrip
    // CHECK-SAME: attributes {no_nans_fp_math = true}
    llvm.return
  }

  llvm.func @approx_func_fp_math_roundtrip() attributes {approx_func_fp_math = true} {
    // CHECK: @approx_func_fp_math_roundtrip
    // CHECK-SAME: attributes {approx_func_fp_math = true}
    llvm.return
  }

  llvm.func @no_signed_zeros_fp_math_roundtrip() attributes {no_signed_zeros_fp_math = true} {
    // CHECK: @no_signed_zeros_fp_math_roundtrip
    // CHECK-SAME: attributes {no_signed_zeros_fp_math = true}
    llvm.return
  }

  llvm.func @convergent_function() attributes {convergent} {
    // CHECK: @convergent_function
    // CHECK-SAME: attributes {convergent}
    llvm.return
  }

  llvm.func @denormal_fp_math_roundtrip() attributes {denormal_fp_math = "preserve-sign"} {
    // CHECK: @denormal_fp_math_roundtrip
    // CHECK-SAME: attributes {denormal_fp_math = "preserve-sign"}
    llvm.return
  }

  llvm.func @denormal_fp_math_f32_roundtrip() attributes {denormal_fp_math_f32 = "preserve-sign"} {
    // CHECK: @denormal_fp_math_f32_roundtrip
    // CHECK-SAME: attributes {denormal_fp_math_f32 = "preserve-sign"}
    llvm.return
  }

  llvm.func @fp_contract_roundtrip() attributes {fp_contract = "fast"} {
    // CHECK: @fp_contract_roundtrip
    // CHECK-SAME: attributes {fp_contract = "fast"}
    llvm.return
  }

  llvm.func @instrument_function_entry_function() attributes {instrument_function_entry = "__cyg_profile_func_enter"} {
    // CHECK: @instrument_function_entry_function
    // CHECK-SAME: attributes {instrument_function_entry = "__cyg_profile_func_enter"}
    llvm.return
  }

  llvm.func @instrument_function_exit_function() attributes {instrument_function_exit = "__cyg_profile_func_exit"} {
    // CHECK: @instrument_function_exit_function
    // CHECK-SAME: attributes {instrument_function_exit = "__cyg_profile_func_exit"}
    llvm.return
  }

  llvm.func @nounwind_function() attributes {no_unwind} {
    // CHECK: @nounwind_function
    // CHECK-SAME: attributes {no_unwind}
    llvm.return
  }

  llvm.func @willreturn_function() attributes {will_return} {
    // CHECK: @willreturn_function
    // CHECK-SAME: attributes {will_return}
    llvm.return
  }


}

// -----

module {
  // expected-error@+1 {{requires one region}}
  "llvm.func"() {function_type = !llvm.func<void ()>, sym_name = "no_region"} : () -> ()
}

// -----

module {
  // expected-error@+1 {{requires attribute 'function_type'}}
  "llvm.func"() ({}) {sym_name = "missing_type"} : () -> ()
}

// -----

module {
  // expected-error@+1 {{attribute 'function_type' failed to satisfy constraint: type attribute of LLVM function type}}
  "llvm.func"() ({}) {sym_name = "non_llvm_type", function_type = i64} : () -> ()
}

// -----

module {
  // expected-error@+1 {{attribute 'function_type' failed to satisfy constraint: type attribute of LLVM function type}}
  "llvm.func"() ({}) {sym_name = "non_function_type", function_type = i64} : () -> ()
}

// -----

module {
  // expected-error@+1 {{entry block must have 0 arguments}}
  "llvm.func"() ({
  ^bb0(%arg0: i64):
    llvm.return
  }) {function_type = !llvm.func<void ()>, sym_name = "wrong_arg_number"} : () -> ()
}

// -----

module {
  // expected-error@+1 {{entry block argument #0('tensor<*xf32>') must match the type of the corresponding argument in function signature('i64')}}
  "llvm.func"() ({
  ^bb0(%arg0: tensor<*xf32>):
    llvm.return
  }) {function_type = !llvm.func<void (i64)>, sym_name = "wrong_arg_number"} : () -> ()
}

// -----

module {
  // expected-error@+1 {{failed to construct function type: expected LLVM type for function arguments}}
  llvm.func @foo(tensor<*xf32>)
}

// -----

module {
  // expected-error@+1 {{failed to construct function type: expected LLVM type for function results}}
  llvm.func @foo() -> tensor<*xf32>
}

// -----

module {
  // expected-error@+1 {{failed to construct function type: expected zero or one function result}}
  llvm.func @foo() -> (i64, i64)
}

// -----

module {
  // expected-error@+1 {{variadic arguments must be in the end of the argument list}}
  llvm.func @variadic_inside(%arg0: i32, ..., %arg1: i32)
}

// -----

module {
  // expected-error@+1 {{external functions must have 'external' or 'extern_weak' linkage}}
  llvm.func internal @internal_external_func()
}

// -----

module {
  // expected-error@+1 {{functions cannot have 'common' linkage}}
  llvm.func common @common_linkage_func()
}

// -----

module {
  // expected-error@+1 {{custom op 'llvm.func' expected valid '@'-identifier for symbol name}}
  llvm.func cc_12 @unknown_calling_convention()
}

// -----

module {
  "llvm.func"() ({
  // expected-error @below {{expected one of [ccc, fastcc, coldcc, cc_10, cc_11, anyregcc, preserve_mostcc, preserve_allcc, swiftcc, cxx_fast_tlscc, tailcc, cfguard_checkcc, swifttailcc, x86_stdcallcc, x86_fastcallcc, arm_apcscc, arm_aapcscc, arm_aapcs_vfpcc, msp430_intrcc, x86_thiscallcc, ptx_kernelcc, ptx_devicecc, spir_funccc, spir_kernelcc, intel_ocl_bicc, x86_64_sysvcc, win64cc, x86_vectorcallcc, hhvmcc, hhvm_ccc, x86_intrcc, avr_intrcc, avr_builtincc, amdgpu_vscc, amdgpu_gscc, amdgpu_cscc, amdgpu_kernelcc, x86_regcallcc, amdgpu_hscc, msp430_builtincc, amdgpu_lscc, amdgpu_escc, aarch64_vectorcallcc, aarch64_sve_vectorcallcc, wasm_emscripten_invokecc, amdgpu_gfxcc, m68k_intrcc] for Calling Conventions, got: cc_12}}
  // expected-error @below {{failed to parse CConvAttr parameter 'CallingConv' which is to be a `CConv`}}
  }) {sym_name = "generic_unknown_calling_convention", CConv = #llvm.cconv<cc_12>, function_type = !llvm.func<i64 (i64, i64)>} : () -> ()
}

// -----

// CHECK: @vec_type_hint()
// CHECK-SAME: vec_type_hint = #llvm.vec_type_hint<hint = i32>
llvm.func @vec_type_hint() attributes {vec_type_hint = #llvm.vec_type_hint<hint = i32>}

// CHECK: @vec_type_hint_signed()
// CHECK-SAME: vec_type_hint = #llvm.vec_type_hint<hint = i32, is_signed = true>
llvm.func @vec_type_hint_signed() attributes {vec_type_hint = #llvm.vec_type_hint<hint = i32, is_signed = true>}

// CHECK: @vec_type_hint_signed_vec()
// CHECK-SAME: vec_type_hint = #llvm.vec_type_hint<hint = vector<2xi32>, is_signed = true>
llvm.func @vec_type_hint_signed_vec() attributes {vec_type_hint = #llvm.vec_type_hint<hint = vector<2xi32>, is_signed = true>}

// CHECK: @vec_type_hint_float_vec()
// CHECK-SAME: vec_type_hint = #llvm.vec_type_hint<hint = vector<3xf32>>
llvm.func @vec_type_hint_float_vec() attributes {vec_type_hint = #llvm.vec_type_hint<hint = vector<3xf32>>}

// CHECK: @vec_type_hint_bfloat_vec()
// CHECK-SAME: vec_type_hint = #llvm.vec_type_hint<hint = vector<8xbf16>>
llvm.func @vec_type_hint_bfloat_vec() attributes {vec_type_hint = #llvm.vec_type_hint<hint = vector<8xbf16>>}

// -----

// CHECK: @work_group_size_hint()
// CHECK-SAME: work_group_size_hint = array<i32: 128, 128, 128>
llvm.func @work_group_size_hint() attributes {work_group_size_hint = array<i32: 128, 128, 128>}

// -----

// CHECK: @reqd_work_group_size_hint()
// CHECK-SAME: reqd_work_group_size = array<i32: 128, 256, 128>
llvm.func @reqd_work_group_size_hint() attributes {reqd_work_group_size = array<i32: 128, 256, 128>}

// -----

// CHECK: @intel_reqd_sub_group_size_hint()
// CHECK-SAME: intel_reqd_sub_group_size = 32 : i32
llvm.func @intel_reqd_sub_group_size_hint() attributes {llvm.intel_reqd_sub_group_size = 32 : i32}

// -----

// CHECK: @workgroup_attribution
// CHECK-SAME: llvm.workgroup_attribution = #llvm.mlir.workgroup_attribution<512 : i64, i32>
// CHECK-SAME: llvm.workgroup_attribution = #llvm.mlir.workgroup_attribution<128 : i64, !llvm.struct<(i32, i64, f32)>
llvm.func @workgroup_attribution(%arg0: !llvm.ptr {llvm.workgroup_attribution = #llvm.mlir.workgroup_attribution<512 : i64, i32>}, %arg1: !llvm.ptr {llvm.workgroup_attribution = #llvm.mlir.workgroup_attribution<128 : i64, !llvm.struct<(i32, i64, f32)>>})

// -----

// CHECK: @constant_range_negative
// CHECK-SAME: llvm.range = #llvm.constant_range<i32, 0, -2147483648>
llvm.func @constant_range_negative() -> (i32 {llvm.range = #llvm.constant_range<i32, 0, -2147483648>})
