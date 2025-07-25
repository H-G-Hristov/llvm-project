; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN:  llc -amdgpu-scalarize-global-loads=false  -mtriple=amdgcn < %s | FileCheck -check-prefix=SI %s
; RUN:  llc -amdgpu-scalarize-global-loads=false  -mtriple=amdgcn -mcpu=tonga < %s | FileCheck -check-prefix=VI %s

target triple = "nvptx64-nvidia-cuda"

define i32 @test_simple_rotl(i32 %x) {
; SI-LABEL: test_simple_rotl:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_alignbit_b32 v0, v0, v0, 25
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_simple_rotl:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_alignbit_b32 v0, v0, v0, 25
; VI-NEXT:    s_setpc_b64 s[30:31]
  %shl = shl i32 %x, 7
  %shr = lshr i32 %x, 25
  %add = add i32 %shl, %shr
  ret i32 %add
}

define i32 @test_simple_rotr(i32 %x) {
; SI-LABEL: test_simple_rotr:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_alignbit_b32 v0, v0, v0, 7
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_simple_rotr:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_alignbit_b32 v0, v0, v0, 7
; VI-NEXT:    s_setpc_b64 s[30:31]
  %shr = lshr i32 %x, 7
  %shl = shl i32 %x, 25
  %add = add i32 %shr, %shl
  ret i32 %add
}

define i32 @test_rotl_var(i32 %x, i32 %y) {
; SI-LABEL: test_rotl_var:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_sub_i32_e32 v1, vcc, 32, v1
; SI-NEXT:    v_alignbit_b32 v0, v0, v0, v1
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_rotl_var:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_sub_u32_e32 v1, vcc, 32, v1
; VI-NEXT:    v_alignbit_b32 v0, v0, v0, v1
; VI-NEXT:    s_setpc_b64 s[30:31]
  %shl = shl i32 %x, %y
  %sub = sub i32 32, %y
  %shr = lshr i32 %x, %sub
  %add = add i32 %shl, %shr
  ret i32 %add
}

define i32 @test_rotr_var(i32 %x, i32 %y) {
; SI-LABEL: test_rotr_var:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_alignbit_b32 v0, v0, v0, v1
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_rotr_var:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_alignbit_b32 v0, v0, v0, v1
; VI-NEXT:    s_setpc_b64 s[30:31]
  %shr = lshr i32 %x, %y
  %sub = sub i32 32, %y
  %shl = shl i32 %x, %sub
  %add = add i32 %shr, %shl
  ret i32 %add
}

define i32 @test_invalid_rotl_var_and(i32 %x, i32 %y) {
; SI-LABEL: test_invalid_rotl_var_and:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_lshlrev_b32_e32 v2, v1, v0
; SI-NEXT:    v_sub_i32_e32 v1, vcc, 0, v1
; SI-NEXT:    v_lshrrev_b32_e32 v0, v1, v0
; SI-NEXT:    v_add_i32_e32 v0, vcc, v0, v2
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_invalid_rotl_var_and:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_lshlrev_b32_e32 v2, v1, v0
; VI-NEXT:    v_sub_u32_e32 v1, vcc, 0, v1
; VI-NEXT:    v_lshrrev_b32_e32 v0, v1, v0
; VI-NEXT:    v_add_u32_e32 v0, vcc, v0, v2
; VI-NEXT:    s_setpc_b64 s[30:31]
  %shr = shl i32 %x, %y
  %sub = sub nsw i32 0, %y
  %and = and i32 %sub, 31
  %shl = lshr i32 %x, %and
  %add = add i32 %shl, %shr
  ret i32 %add
}

define i32 @test_invalid_rotr_var_and(i32 %x, i32 %y) {
; SI-LABEL: test_invalid_rotr_var_and:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_lshrrev_b32_e32 v2, v1, v0
; SI-NEXT:    v_sub_i32_e32 v1, vcc, 0, v1
; SI-NEXT:    v_lshlrev_b32_e32 v0, v1, v0
; SI-NEXT:    v_add_i32_e32 v0, vcc, v2, v0
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_invalid_rotr_var_and:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_lshrrev_b32_e32 v2, v1, v0
; VI-NEXT:    v_sub_u32_e32 v1, vcc, 0, v1
; VI-NEXT:    v_lshlrev_b32_e32 v0, v1, v0
; VI-NEXT:    v_add_u32_e32 v0, vcc, v2, v0
; VI-NEXT:    s_setpc_b64 s[30:31]
  %shr = lshr i32 %x, %y
  %sub = sub nsw i32 0, %y
  %and = and i32 %sub, 31
  %shl = shl i32 %x, %and
  %add = add i32 %shr, %shl
  ret i32 %add
}

define i32 @test_fshl_special_case(i32 %x0, i32 %x1, i32 %y) {
; SI-LABEL: test_fshl_special_case:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_lshlrev_b32_e32 v0, v2, v0
; SI-NEXT:    v_lshrrev_b32_e32 v1, 1, v1
; SI-NEXT:    v_xor_b32_e32 v2, 31, v2
; SI-NEXT:    v_lshrrev_b32_e32 v1, v2, v1
; SI-NEXT:    v_add_i32_e32 v0, vcc, v0, v1
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_fshl_special_case:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_lshlrev_b32_e32 v0, v2, v0
; VI-NEXT:    v_lshrrev_b32_e32 v1, 1, v1
; VI-NEXT:    v_xor_b32_e32 v2, 31, v2
; VI-NEXT:    v_lshrrev_b32_e32 v1, v2, v1
; VI-NEXT:    v_add_u32_e32 v0, vcc, v0, v1
; VI-NEXT:    s_setpc_b64 s[30:31]
  %shl = shl i32 %x0, %y
  %srli = lshr i32 %x1, 1
  %x = xor i32 %y, 31
  %srlo = lshr i32 %srli, %x
  %o = add i32 %shl, %srlo
  ret i32 %o
}

define i32 @test_fshr_special_case(i32 %x0, i32 %x1, i32 %y) {
; SI-LABEL: test_fshr_special_case:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_alignbit_b32 v0, v0, v1, v2
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_fshr_special_case:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_alignbit_b32 v0, v0, v1, v2
; VI-NEXT:    s_setpc_b64 s[30:31]
  %shl = lshr i32 %x1, %y
  %srli = shl i32 %x0, 1
  %x = xor i32 %y, 31
  %srlo = shl i32 %srli, %x
  %o = add i32 %shl, %srlo
  ret i32 %o
}

define i64 @test_rotl_udiv_special_case(i64 %i) {
; SI-LABEL: test_rotl_udiv_special_case:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    s_mov_b32 s4, 0xaaaaaaaa
; SI-NEXT:    s_mov_b32 s5, 0xaaaaaaab
; SI-NEXT:    v_mul_hi_u32 v2, v0, s4
; SI-NEXT:    v_mul_lo_u32 v3, v0, s4
; SI-NEXT:    v_mul_hi_u32 v4, v1, s5
; SI-NEXT:    v_mul_lo_u32 v5, v1, s5
; SI-NEXT:    v_mul_hi_u32 v0, v0, s5
; SI-NEXT:    v_mul_hi_u32 v6, v1, s4
; SI-NEXT:    v_mul_lo_u32 v1, v1, s4
; SI-NEXT:    v_add_i32_e32 v0, vcc, v5, v0
; SI-NEXT:    v_addc_u32_e32 v4, vcc, 0, v4, vcc
; SI-NEXT:    v_add_i32_e32 v0, vcc, v3, v0
; SI-NEXT:    v_addc_u32_e32 v0, vcc, 0, v2, vcc
; SI-NEXT:    v_add_i32_e32 v0, vcc, v4, v0
; SI-NEXT:    v_addc_u32_e64 v3, s[4:5], 0, 0, vcc
; SI-NEXT:    v_add_i32_e32 v2, vcc, v1, v0
; SI-NEXT:    v_addc_u32_e32 v3, vcc, v6, v3, vcc
; SI-NEXT:    v_lshr_b64 v[0:1], v[2:3], 5
; SI-NEXT:    v_lshlrev_b32_e32 v0, 27, v2
; SI-NEXT:    v_and_b32_e32 v0, 0xf0000000, v0
; SI-NEXT:    v_or_b32_e32 v1, v0, v1
; SI-NEXT:    v_alignbit_b32 v0, v3, v2, 5
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_rotl_udiv_special_case:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    s_mov_b32 s4, 0xaaaaaaab
; VI-NEXT:    v_mul_hi_u32 v2, v0, s4
; VI-NEXT:    v_mov_b32_e32 v3, 0
; VI-NEXT:    s_mov_b32 s6, 0xaaaaaaaa
; VI-NEXT:    v_mad_u64_u32 v[4:5], s[4:5], v1, s4, v[2:3]
; VI-NEXT:    v_mov_b32_e32 v2, v4
; VI-NEXT:    v_mad_u64_u32 v[2:3], s[4:5], v0, s6, v[2:3]
; VI-NEXT:    v_add_u32_e32 v2, vcc, v5, v3
; VI-NEXT:    v_addc_u32_e64 v3, s[4:5], 0, 0, vcc
; VI-NEXT:    v_mad_u64_u32 v[0:1], s[4:5], v1, s6, v[2:3]
; VI-NEXT:    v_lshrrev_b64 v[2:3], 5, v[0:1]
; VI-NEXT:    v_lshlrev_b32_e32 v2, 27, v0
; VI-NEXT:    v_alignbit_b32 v0, v1, v0, 5
; VI-NEXT:    v_and_b32_e32 v1, 0xf0000000, v2
; VI-NEXT:    v_or_b32_e32 v1, v1, v3
; VI-NEXT:    s_setpc_b64 s[30:31]
  %lhs_div = udiv i64 %i, 3
  %rhs_div = udiv i64 %i, 48
  %lhs_shift = shl i64 %lhs_div, 60
  %out = add i64 %lhs_shift, %rhs_div
  ret i64 %out
}

define i32 @test_rotl_mul_special_case(i32 %i) {
; SI-LABEL: test_rotl_mul_special_case:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_mul_lo_u32 v0, v0, 9
; SI-NEXT:    v_alignbit_b32 v0, v0, v0, 25
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_rotl_mul_special_case:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_mul_lo_u32 v0, v0, 9
; VI-NEXT:    v_alignbit_b32 v0, v0, v0, 25
; VI-NEXT:    s_setpc_b64 s[30:31]
  %lhs_mul = mul i32 %i, 9
  %rhs_mul = mul i32 %i, 1152
  %lhs_shift = lshr i32 %lhs_mul, 25
  %out = add i32 %lhs_shift, %rhs_mul
  ret i32 %out
}

define i64 @test_rotl_mul_with_mask_special_case(i64 %i) {
; SI-LABEL: test_rotl_mul_with_mask_special_case:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_mul_lo_u32 v1, v1, 9
; SI-NEXT:    v_mul_hi_u32 v2, v0, 9
; SI-NEXT:    v_add_i32_e32 v1, vcc, v2, v1
; SI-NEXT:    v_alignbit_b32 v0, v0, v1, 25
; SI-NEXT:    v_and_b32_e32 v0, 0xff, v0
; SI-NEXT:    v_mov_b32_e32 v1, 0
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_rotl_mul_with_mask_special_case:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_mul_lo_u32 v1, v1, 9
; VI-NEXT:    v_mul_hi_u32 v2, v0, 9
; VI-NEXT:    v_add_u32_e32 v1, vcc, v2, v1
; VI-NEXT:    v_alignbit_b32 v0, v0, v1, 25
; VI-NEXT:    v_and_b32_e32 v0, 0xff, v0
; VI-NEXT:    v_mov_b32_e32 v1, 0
; VI-NEXT:    s_setpc_b64 s[30:31]
  %lhs_mul = mul i64 %i, 1152
  %rhs_mul = mul i64 %i, 9
  %lhs_and = and i64 %lhs_mul, 160
  %rhs_shift = lshr i64 %rhs_mul, 57
  %out = add i64 %lhs_and, %rhs_shift
  ret i64 %out
}

define i32 @test_fshl_with_mask_special_case(i32 %x) {
; SI-LABEL: test_fshl_with_mask_special_case:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_or_b32_e32 v1, 1, v0
; SI-NEXT:    v_alignbit_b32 v0, v1, v0, 27
; SI-NEXT:    v_and_b32_e32 v0, 0xffffffe1, v0
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: test_fshl_with_mask_special_case:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_or_b32_e32 v1, 1, v0
; VI-NEXT:    v_alignbit_b32 v0, v1, v0, 27
; VI-NEXT:    v_and_b32_e32 v0, 0xffffffe1, v0
; VI-NEXT:    s_setpc_b64 s[30:31]
  %or1 = or i32 %x, 1
  %sh1 = shl i32 %or1, 5
  %sh2 = lshr i32 %x, 27
  %1 = and i32 %sh2, 1
  %r = add i32 %sh1, %1
  ret i32 %r
}
