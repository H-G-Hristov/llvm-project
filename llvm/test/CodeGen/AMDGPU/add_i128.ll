; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc -mtriple=amdgcn < %s | FileCheck -check-prefix=GCN %s

define amdgpu_kernel void @test_i128_vreg(ptr addrspace(1) noalias %out, ptr addrspace(1) noalias %inA, ptr addrspace(1) noalias %inB) {
; GCN-LABEL: test_i128_vreg:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; GCN-NEXT:    s_load_dwordx2 s[4:5], s[4:5], 0xd
; GCN-NEXT:    s_mov_b32 s11, 0xf000
; GCN-NEXT:    s_mov_b32 s14, 0
; GCN-NEXT:    v_lshlrev_b32_e32 v4, 4, v0
; GCN-NEXT:    v_mov_b32_e32 v5, 0
; GCN-NEXT:    s_mov_b32 s15, s11
; GCN-NEXT:    s_mov_b64 s[6:7], s[14:15]
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_mov_b64 s[12:13], s[2:3]
; GCN-NEXT:    buffer_load_dwordx4 v[0:3], v[4:5], s[12:15], 0 addr64
; GCN-NEXT:    buffer_load_dwordx4 v[4:7], v[4:5], s[4:7], 0 addr64
; GCN-NEXT:    s_mov_b32 s10, -1
; GCN-NEXT:    s_mov_b32 s8, s0
; GCN-NEXT:    s_mov_b32 s9, s1
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    v_add_i32_e32 v0, vcc, v0, v4
; GCN-NEXT:    v_addc_u32_e32 v1, vcc, v1, v5, vcc
; GCN-NEXT:    v_addc_u32_e32 v2, vcc, v2, v6, vcc
; GCN-NEXT:    v_addc_u32_e32 v3, vcc, v3, v7, vcc
; GCN-NEXT:    buffer_store_dwordx4 v[0:3], off, s[8:11], 0
; GCN-NEXT:    s_endpgm
  %tid = call i32 @llvm.amdgcn.workitem.id.x() readnone
  %a_ptr = getelementptr i128, ptr addrspace(1) %inA, i32 %tid
  %b_ptr = getelementptr i128, ptr addrspace(1) %inB, i32 %tid
  %a = load i128, ptr addrspace(1) %a_ptr
  %b = load i128, ptr addrspace(1) %b_ptr
  %result = add i128 %a, %b
  store i128 %result, ptr addrspace(1) %out
  ret void
}

; Check that the SGPR add operand is correctly moved to a VGPR.
define amdgpu_kernel void @sgpr_operand(ptr addrspace(1) noalias %out, ptr addrspace(1) noalias %in, i128 %a) {
; GCN-LABEL: sgpr_operand:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx8 s[0:7], s[4:5], 0x9
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_load_dwordx4 s[8:11], s[2:3], 0x0
; GCN-NEXT:    s_mov_b32 s3, 0xf000
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_add_u32 s4, s8, s4
; GCN-NEXT:    s_addc_u32 s5, s9, s5
; GCN-NEXT:    s_addc_u32 s6, s10, s6
; GCN-NEXT:    s_addc_u32 s7, s11, s7
; GCN-NEXT:    s_mov_b32 s2, -1
; GCN-NEXT:    v_mov_b32_e32 v0, s4
; GCN-NEXT:    v_mov_b32_e32 v1, s5
; GCN-NEXT:    v_mov_b32_e32 v2, s6
; GCN-NEXT:    v_mov_b32_e32 v3, s7
; GCN-NEXT:    buffer_store_dwordx4 v[0:3], off, s[0:3], 0
; GCN-NEXT:    s_endpgm
  %foo = load i128, ptr addrspace(1) %in, align 8
  %result = add i128 %foo, %a
  store i128 %result, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @sgpr_operand_reversed(ptr addrspace(1) noalias %out, ptr addrspace(1) noalias %in, i128 %a) {
; GCN-LABEL: sgpr_operand_reversed:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx8 s[0:7], s[4:5], 0x9
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_load_dwordx4 s[8:11], s[2:3], 0x0
; GCN-NEXT:    s_mov_b32 s3, 0xf000
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_add_u32 s4, s4, s8
; GCN-NEXT:    s_addc_u32 s5, s5, s9
; GCN-NEXT:    s_addc_u32 s6, s6, s10
; GCN-NEXT:    s_addc_u32 s7, s7, s11
; GCN-NEXT:    s_mov_b32 s2, -1
; GCN-NEXT:    v_mov_b32_e32 v0, s4
; GCN-NEXT:    v_mov_b32_e32 v1, s5
; GCN-NEXT:    v_mov_b32_e32 v2, s6
; GCN-NEXT:    v_mov_b32_e32 v3, s7
; GCN-NEXT:    buffer_store_dwordx4 v[0:3], off, s[0:3], 0
; GCN-NEXT:    s_endpgm
  %foo = load i128, ptr addrspace(1) %in, align 8
  %result = add i128 %a, %foo
  store i128 %result, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @test_sreg(ptr addrspace(1) noalias %out, i128 %a, i128 %b) {
; GCN-LABEL: test_sreg:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx8 s[8:15], s[4:5], 0xb
; GCN-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x9
; GCN-NEXT:    s_mov_b32 s3, 0xf000
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_add_u32 s4, s8, s12
; GCN-NEXT:    s_addc_u32 s5, s9, s13
; GCN-NEXT:    s_addc_u32 s6, s10, s14
; GCN-NEXT:    s_addc_u32 s7, s11, s15
; GCN-NEXT:    s_mov_b32 s2, -1
; GCN-NEXT:    v_mov_b32_e32 v0, s4
; GCN-NEXT:    v_mov_b32_e32 v1, s5
; GCN-NEXT:    v_mov_b32_e32 v2, s6
; GCN-NEXT:    v_mov_b32_e32 v3, s7
; GCN-NEXT:    buffer_store_dwordx4 v[0:3], off, s[0:3], 0
; GCN-NEXT:    s_endpgm
  %result = add i128 %a, %b
  store i128 %result, ptr addrspace(1) %out
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x() readnone
