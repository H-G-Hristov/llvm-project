; RUN: llc -mtriple=amdgcn -mcpu=verde < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -mtriple=amdgcn -mcpu=tonga < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -mtriple=r600 -mcpu=redwood < %s | FileCheck -check-prefix=EG -check-prefix=FUNC %s
; RUN: llc -mtriple=r600 -mcpu=cayman < %s | FileCheck -check-prefix=CM -check-prefix=FUNC %s

; FUNC-LABEL: {{^}}store_i1:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

; SI: buffer_store_byte
define amdgpu_kernel void @store_i1(ptr addrspace(5) %out) {
entry:
  store i1 true, ptr addrspace(5) %out
  ret void
}

; i8 store
; FUNC-LABEL: {{^}}store_i8:
; EG: LSHR * [[ADDRESS:T[0-9]\.[XYZW]]], KC0[2].Y, literal.x
; EG-NEXT: 2
; EG: MOVA_INT * AR.x (MASKED)
; EG: MOV [[OLD:T[0-9]\.[XYZW]]], {{.*}}AR.x

; IG 0: Get the byte index and truncate the value
; EG: AND_INT * T{{[0-9]}}.[[BI_CHAN:[XYZW]]], KC0[2].Y, literal.x
; EG: LSHL * T{{[0-9]}}.[[SHIFT_CHAN:[XYZW]]], PV.[[BI_CHAN]], literal.x
; EG-NEXT: 3(4.203895e-45)


; EG: LSHL * T{{[0-9]}}.[[TRUNC_CHAN:[XYZW]]], literal.x, PV.W
; EG-NEXT: 255(3.573311e-43)

; EG: NOT_INT
; EG: AND_INT {{[\* ]*}}[[CLR_CHAN:T[0-9]\.[XYZW]]], {{.*}}[[OLD]]
; EG: OR_INT * [[RES:T[0-9]\.[XYZW]]]
; TODO: Is the reload necessary?
; EG: MOVA_INT * AR.x (MASKED), [[ADDRESS]]
; EG: MOV * T(0 + AR.x).X+, [[RES]]

; SI: buffer_store_byte

define amdgpu_kernel void @store_i8(ptr addrspace(5) %out, i8 %in) {
entry:
  store i8 %in, ptr addrspace(5) %out
  ret void
}

; i16 store
; FUNC-LABEL: {{^}}store_i16:
; EG: LSHR * [[ADDRESS:T[0-9]\.[XYZW]]], KC0[2].Y, literal.x
; EG-NEXT: 2
; EG: MOVA_INT * AR.x (MASKED)
; EG: MOV [[OLD:T[0-9]\.[XYZW]]], {{.*}}AR.x

; EG: VTX_READ_16

; IG 0: Get the byte index and truncate the value
; EG: AND_INT * T{{[0-9]}}.[[BI_CHAN:[XYZW]]], KC0[2].Y, literal.x
; EG: LSHL * T{{[0-9]}}.[[SHIFT_CHAN:[XYZW]]], PV.[[BI_CHAN]], literal.x
; EG-NEXT: 3(4.203895e-45)

; EG: NOT_INT
; EG: AND_INT {{[\* ]*}}[[CLR_CHAN:T[0-9]\.[XYZW]]], {{.*}}[[OLD]]
; EG: OR_INT * [[RES:T[0-9]\.[XYZW]]]
; TODO: Is the reload necessary?
; EG: MOVA_INT * AR.x (MASKED), [[ADDRESS]]
; EG: MOV * T(0 + AR.x).X+, [[RES]]

; SI: buffer_store_short
define amdgpu_kernel void @store_i16(ptr addrspace(5) %out, i16 %in) {
entry:
  store i16 %in, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_i24:
; SI: s_lshr_b32 s{{[0-9]+}}, s{{[0-9]+}}, 16
; SI-DAG: buffer_store_byte
; SI-DAG: buffer_store_short

; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store can be eliminated
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store can be eliminated
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
define amdgpu_kernel void @store_i24(ptr addrspace(5) %out, i24 %in) {
entry:
  store i24 %in, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_i25:
; SI: s_and_b32 [[AND:s[0-9]+]], s{{[0-9]+}}, 0x1ffffff{{$}}
; SI: v_mov_b32_e32 [[VAND:v[0-9]+]], [[AND]]
; SI: buffer_store_dword [[VAND]]

; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG-NOT: MOVA_INT

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM-NOT: MOVA_INT
define amdgpu_kernel void @store_i25(ptr addrspace(5) %out, i25 %in) {
entry:
  store i25 %in, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_v2i8:
; v2i8 is naturally 2B aligned, treat as i16
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG-NOT: MOVA_INT

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM-NOT: MOVA_INT

; SI: buffer_store_short
define amdgpu_kernel void @store_v2i8(ptr addrspace(5) %out, <2 x i32> %in) {
entry:
  %0 = trunc <2 x i32> %in to <2 x i8>
  store <2 x i8> %0, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_v2i8_unaligned:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

; SI: buffer_store_byte
define amdgpu_kernel void @store_v2i8_unaligned(ptr addrspace(5) %out, <2 x i32> %in) {
entry:
  %0 = trunc <2 x i32> %in to <2 x i8>
  store <2 x i8> %0, ptr addrspace(5) %out, align 1
  ret void
}


; FUNC-LABEL: {{^}}store_v2i16:
; v2i8 is naturally 2B aligned, treat as i16
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG-NOT: MOVA_INT

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM-NOT: MOVA_INT

; SI: buffer_store_dword
define amdgpu_kernel void @store_v2i16(ptr addrspace(5) %out, <2 x i32> %in) {
entry:
  %0 = trunc <2 x i32> %in to <2 x i16>
  store <2 x i16> %0, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_v2i16_unaligned:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

; SI: buffer_store_short
; SI: buffer_store_short
define amdgpu_kernel void @store_v2i16_unaligned(ptr addrspace(5) %out, <2 x i32> %in) {
entry:
  %0 = trunc <2 x i32> %in to <2 x i16>
  store <2 x i16> %0, ptr addrspace(5) %out, align 2
  ret void
}

; FUNC-LABEL: {{^}}store_v4i8:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG-NOT: MOVA_INT

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM-NOT: MOVA_INT

; SI: buffer_store_dword
define amdgpu_kernel void @store_v4i8(ptr addrspace(5) %out, <4 x i32> %in) {
entry:
  %0 = trunc <4 x i32> %in to <4 x i8>
  store <4 x i8> %0, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_v4i8_unaligned:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

; SI: buffer_store_byte
; SI: buffer_store_byte
; SI: buffer_store_byte
; SI: buffer_store_byte
; SI-NOT: buffer_store_dword
define amdgpu_kernel void @store_v4i8_unaligned(ptr addrspace(5) %out, <4 x i32> %in) {
entry:
  %0 = trunc <4 x i32> %in to <4 x i8>
  store <4 x i8> %0, ptr addrspace(5) %out, align 1
  ret void
}

; FUNC-LABEL: {{^}}store_v8i8_unaligned:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

; SI: buffer_store_byte
; SI: buffer_store_byte
; SI: buffer_store_byte
; SI: buffer_store_byte
; SI: buffer_store_byte
; SI: buffer_store_byte
; SI: buffer_store_byte
; SI: buffer_store_byte
; SI-NOT: buffer_store_dword
define amdgpu_kernel void @store_v8i8_unaligned(ptr addrspace(5) %out, <8 x i32> %in) {
entry:
  %0 = trunc <8 x i32> %in to <8 x i8>
  store <8 x i8> %0, ptr addrspace(5) %out, align 1
  ret void
}

; FUNC-LABEL: {{^}}store_v4i8_halfaligned:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; TODO: This load and store cannot be eliminated,
;       they might be different locations
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

; SI: buffer_store_short
; SI: buffer_store_short
; SI-NOT: buffer_store_dword
define amdgpu_kernel void @store_v4i8_halfaligned(ptr addrspace(5) %out, <4 x i32> %in) {
entry:
  %0 = trunc <4 x i32> %in to <4 x i8>
  store <4 x i8> %0, ptr addrspace(5) %out, align 2
  ret void
}

; floating-point store
; FUNC-LABEL: {{^}}store_f32:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

; SI: buffer_store_dword

define amdgpu_kernel void @store_f32(ptr addrspace(5) %out, float %in) {
  store float %in, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_v4i16:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

;TODO: why not x2?
; XSI: buffer_store_dwordx2
; SI: buffer_store_dword
; SI: buffer_store_dword
define amdgpu_kernel void @store_v4i16(ptr addrspace(5) %out, <4 x i32> %in) {
entry:
  %0 = trunc <4 x i32> %in to <4 x i16>
  store <4 x i16> %0, ptr addrspace(5) %out
  ret void
}

; vec2 floating-point stores
; FUNC-LABEL: {{^}}store_v2f32:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

;TODO: why not x2?
; XSI: buffer_store_dwordx2
; SI: buffer_store_dword
; SI: buffer_store_dword

define amdgpu_kernel void @store_v2f32(ptr addrspace(5) %out, float %a, float %b) {
entry:
  %0 = insertelement <2 x float> <float 0.0, float 0.0>, float %a, i32 0
  %1 = insertelement <2 x float> %0, float %b, i32 1
  store <2 x float> %1, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_v3i32:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

;TODO: why not x2?
; XSI-DAG: buffer_store_dwordx2
; SI: buffer_store_dword
; SI: buffer_store_dword
; SI: buffer_store_dword

define amdgpu_kernel void @store_v3i32(ptr addrspace(5) %out, <3 x i32> %a) nounwind {
  store <3 x i32> %a, ptr addrspace(5) %out, align 16
  ret void
}

; FUNC-LABEL: {{^}}store_v4i32:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

;TODO: why not x4?
; XSI: buffer_store_dwordx4
; SI: buffer_store_dword
; SI: buffer_store_dword
; SI: buffer_store_dword
; SI: buffer_store_dword
define amdgpu_kernel void @store_v4i32(ptr addrspace(5) %out, <4 x i32> %in) {
entry:
  store <4 x i32> %in, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_v4i32_unaligned:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

;TODO: why not x4?
; XSI: buffer_store_dwordx4
; SI: buffer_store_dword
; SI: buffer_store_dword
; SI: buffer_store_dword
; SI: buffer_store_dword
define amdgpu_kernel void @store_v4i32_unaligned(ptr addrspace(5) %out, <4 x i32> %in) {
entry:
  store <4 x i32> %in, ptr addrspace(5) %out, align 4
  ret void
}

; v4f32 store
; FUNC-LABEL: {{^}}store_v4f32:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

;TODO: why not x4?
; XSI: buffer_store_dwordx4
; SI: buffer_store_dword
; SI: buffer_store_dword
; SI: buffer_store_dword
; SI: buffer_store_dword
define amdgpu_kernel void @store_v4f32(ptr addrspace(5) %out, ptr addrspace(5) %in) {
  %1 = load <4 x float>, ptr addrspace(5) %in
  store <4 x float> %1, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_i64_i8:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

; SI: buffer_store_byte
define amdgpu_kernel void @store_i64_i8(ptr addrspace(5) %out, i64 %in) {
entry:
  %0 = trunc i64 %in to i8
  store i8 %0, ptr addrspace(5) %out
  ret void
}

; FUNC-LABEL: {{^}}store_i64_i16:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}{{T[0-9]+\.[XYZW]}}, T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

; SI: buffer_store_short
define amdgpu_kernel void @store_i64_i16(ptr addrspace(5) %out, i64 %in) {
entry:
  %0 = trunc i64 %in to i16
  store i16 %0, ptr addrspace(5) %out
  ret void
}

; The stores in this function are combined by the optimizer to create a
; 64-bit store with 32-bit alignment.  This is legal and the legalizer
; should not try to split the 64-bit store back into 2 32-bit stores.

; FUNC-LABEL: {{^}}vecload2:
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

;TODO: why not x2?
; XSI: buffer_store_dwordx2
; SI: buffer_store_dword
; SI: buffer_store_dword
define amdgpu_kernel void @vecload2(ptr addrspace(5) nocapture %out, ptr addrspace(4) nocapture %mem) #0 {
entry:
  %0 = load i32, ptr addrspace(4) %mem, align 4
  %arrayidx1.i = getelementptr inbounds i32, ptr addrspace(4) %mem, i64 1
  %1 = load i32, ptr addrspace(4) %arrayidx1.i, align 4
  store i32 %0, ptr addrspace(5) %out, align 4
  %arrayidx1 = getelementptr inbounds i32, ptr addrspace(5) %out, i64 1
  store i32 %1, ptr addrspace(5) %arrayidx1, align 4
  ret void
}

; When i128 was a legal type this program generated cannot select errors:

; FUNC-LABEL: {{^}}"i128-const-store":
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,
; EG: MOVA_INT
; EG: MOV {{[\* ]*}}T(0 + AR.x).X+,

; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,
; CM: MOVA_INT
; CM: MOV {{[\* ]*}}T(0 + AR.x).X+,

;TODO: why not x4?
; XSI: buffer_store_dwordx4
; SI: buffer_store_dword
; SI: buffer_store_dword
; SI: buffer_store_dword
; SI: buffer_store_dword
define amdgpu_kernel void @i128-const-store(ptr addrspace(5) %out) {
entry:
  store i32 1, ptr addrspace(5) %out, align 4
  %arrayidx2 = getelementptr inbounds i32, ptr addrspace(5) %out, i64 1
  store i32 1, ptr addrspace(5) %arrayidx2, align 4
  %arrayidx4 = getelementptr inbounds i32, ptr addrspace(5) %out, i64 2
  store i32 2, ptr addrspace(5) %arrayidx4, align 4
  %arrayidx6 = getelementptr inbounds i32, ptr addrspace(5) %out, i64 3
  store i32 2, ptr addrspace(5) %arrayidx6, align 4
  ret void
}


attributes #0 = { nounwind }
