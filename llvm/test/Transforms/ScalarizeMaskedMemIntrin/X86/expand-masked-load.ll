; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S %s -passes=scalarize-masked-mem-intrin -mtriple=x86_64-linux-gnu | FileCheck %s

define <2 x i64> @scalarize_v2i64(ptr %p, <2 x i1> %mask, <2 x i64> %passthru) {
; CHECK-LABEL: @scalarize_v2i64(
; CHECK-NEXT:    [[SCALAR_MASK:%.*]] = bitcast <2 x i1> [[MASK:%.*]] to i2
; CHECK-NEXT:    [[TMP1:%.*]] = and i2 [[SCALAR_MASK]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i2 [[TMP1]], 0
; CHECK-NEXT:    br i1 [[TMP2]], label [[COND_LOAD:%.*]], label [[ELSE:%.*]]
; CHECK:       cond.load:
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i64, ptr [[P:%.*]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = load i64, ptr [[TMP3]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x i64> [[PASSTHRU:%.*]], i64 [[TMP4]], i64 0
; CHECK-NEXT:    br label [[ELSE]]
; CHECK:       else:
; CHECK-NEXT:    [[RES_PHI_ELSE:%.*]] = phi <2 x i64> [ [[TMP5]], [[COND_LOAD]] ], [ [[PASSTHRU]], [[TMP0:%.*]] ]
; CHECK-NEXT:    [[TMP6:%.*]] = and i2 [[SCALAR_MASK]], -2
; CHECK-NEXT:    [[TMP7:%.*]] = icmp ne i2 [[TMP6]], 0
; CHECK-NEXT:    br i1 [[TMP7]], label [[COND_LOAD1:%.*]], label [[ELSE2:%.*]]
; CHECK:       cond.load1:
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i64, ptr [[P]], i32 1
; CHECK-NEXT:    [[TMP9:%.*]] = load i64, ptr [[TMP8]], align 8
; CHECK-NEXT:    [[TMP10:%.*]] = insertelement <2 x i64> [[RES_PHI_ELSE]], i64 [[TMP9]], i64 1
; CHECK-NEXT:    br label [[ELSE2]]
; CHECK:       else2:
; CHECK-NEXT:    [[RES_PHI_ELSE3:%.*]] = phi <2 x i64> [ [[TMP10]], [[COND_LOAD1]] ], [ [[RES_PHI_ELSE]], [[ELSE]] ]
; CHECK-NEXT:    ret <2 x i64> [[RES_PHI_ELSE3]]
;
  %ret = call <2 x i64> @llvm.masked.load.v2i64.p0(ptr %p, i32 128, <2 x i1> %mask, <2 x i64> %passthru)
  ret <2 x i64> %ret
}

define <2 x i64> @scalarize_v2i64_ones_mask(ptr %p, <2 x i64> %passthru) {
; CHECK-LABEL: @scalarize_v2i64_ones_mask(
; CHECK-NEXT:    [[RET:%.*]] = load <2 x i64>, ptr [[P:%.*]], align 8
; CHECK-NEXT:    ret <2 x i64> [[RET]]
;
  %ret = call <2 x i64> @llvm.masked.load.v2i64.p0(ptr %p, i32 8, <2 x i1> <i1 true, i1 true>, <2 x i64> %passthru)
  ret <2 x i64> %ret
}

define <2 x i64> @scalarize_v2i64_zero_mask(ptr %p, <2 x i64> %passthru) {
; CHECK-LABEL: @scalarize_v2i64_zero_mask(
; CHECK-NEXT:    ret <2 x i64> [[PASSTHRU:%.*]]
;
  %ret = call <2 x i64> @llvm.masked.load.v2i64.p0(ptr %p, i32 8, <2 x i1> <i1 false, i1 false>, <2 x i64> %passthru)
  ret <2 x i64> %ret
}

define <2 x i64> @scalarize_v2i64_const_mask(ptr %p, <2 x i64> %passthru) {
; CHECK-LABEL: @scalarize_v2i64_const_mask(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i64, ptr [[P:%.*]], i32 1
; CHECK-NEXT:    [[TMP2:%.*]] = load i64, ptr [[TMP1]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x i64> [[PASSTHRU:%.*]], i64 [[TMP2]], i64 1
; CHECK-NEXT:    ret <2 x i64> [[TMP3]]
;
  %ret = call <2 x i64> @llvm.masked.load.v2i64.p0(ptr %p, i32 8, <2 x i1> <i1 false, i1 true>, <2 x i64> %passthru)
  ret <2 x i64> %ret
}

define <2 x i64> @scalarize_v2i64_splat_mask(ptr %p, i1 %mask, <2 x i64> %passthrough) {
; CHECK-LABEL: @scalarize_v2i64_splat_mask(
; CHECK-NEXT:    [[MASK_VEC:%.*]] = insertelement <2 x i1> poison, i1 [[MASK:%.*]], i32 0
; CHECK-NEXT:    [[MASK_SPLAT:%.*]] = shufflevector <2 x i1> [[MASK_VEC]], <2 x i1> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[MASK_SPLAT_FIRST:%.*]] = extractelement <2 x i1> [[MASK_SPLAT]], i64 0
; CHECK-NEXT:    br i1 [[MASK_SPLAT_FIRST]], label [[COND_LOAD:%.*]], label [[TMP1:%.*]]
; CHECK:       cond.load:
; CHECK-NEXT:    [[RET_COND_LOAD:%.*]] = load <2 x i64>, ptr [[P:%.*]], align 8
; CHECK-NEXT:    br label [[TMP1]]
; CHECK:       1:
; CHECK-NEXT:    [[RET:%.*]] = phi <2 x i64> [ [[RET_COND_LOAD]], [[COND_LOAD]] ], [ [[PASSTHROUGH:%.*]], [[TMP0:%.*]] ]
; CHECK-NEXT:    ret <2 x i64> [[RET]]
;
  %mask.vec = insertelement <2 x i1> poison, i1 %mask, i32 0
  %mask.splat = shufflevector <2 x i1> %mask.vec, <2 x i1> poison, <2 x i32> zeroinitializer
  %ret = call <2 x i64> @llvm.masked.load.v2i64.p0(ptr %p, i32 8, <2 x i1> %mask.splat, <2 x i64> %passthrough)
  ret <2 x i64> %ret
}

; This use a byte sized but non power of 2 element size. This used to crash due to bad alignment calculation.
define <2 x i24> @scalarize_v2i24(ptr %p, <2 x i1> %mask, <2 x i24> %passthru) {
; CHECK-LABEL: @scalarize_v2i24(
; CHECK-NEXT:    [[SCALAR_MASK:%.*]] = bitcast <2 x i1> [[MASK:%.*]] to i2
; CHECK-NEXT:    [[TMP1:%.*]] = and i2 [[SCALAR_MASK]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i2 [[TMP1]], 0
; CHECK-NEXT:    br i1 [[TMP2]], label [[COND_LOAD:%.*]], label [[ELSE:%.*]]
; CHECK:       cond.load:
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i24, ptr [[P:%.*]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = load i24, ptr [[TMP3]], align 1
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x i24> [[PASSTHRU:%.*]], i24 [[TMP4]], i64 0
; CHECK-NEXT:    br label [[ELSE]]
; CHECK:       else:
; CHECK-NEXT:    [[RES_PHI_ELSE:%.*]] = phi <2 x i24> [ [[TMP5]], [[COND_LOAD]] ], [ [[PASSTHRU]], [[TMP0:%.*]] ]
; CHECK-NEXT:    [[TMP6:%.*]] = and i2 [[SCALAR_MASK]], -2
; CHECK-NEXT:    [[TMP7:%.*]] = icmp ne i2 [[TMP6]], 0
; CHECK-NEXT:    br i1 [[TMP7]], label [[COND_LOAD1:%.*]], label [[ELSE2:%.*]]
; CHECK:       cond.load1:
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i24, ptr [[P]], i32 1
; CHECK-NEXT:    [[TMP9:%.*]] = load i24, ptr [[TMP8]], align 1
; CHECK-NEXT:    [[TMP10:%.*]] = insertelement <2 x i24> [[RES_PHI_ELSE]], i24 [[TMP9]], i64 1
; CHECK-NEXT:    br label [[ELSE2]]
; CHECK:       else2:
; CHECK-NEXT:    [[RES_PHI_ELSE3:%.*]] = phi <2 x i24> [ [[TMP10]], [[COND_LOAD1]] ], [ [[RES_PHI_ELSE]], [[ELSE]] ]
; CHECK-NEXT:    ret <2 x i24> [[RES_PHI_ELSE3]]
;
  %ret = call <2 x i24> @llvm.masked.load.v2i24.p0(ptr %p, i32 8, <2 x i1> %mask, <2 x i24> %passthru)
  ret <2 x i24> %ret
}

; This use a byte sized but non power of 2 element size. This used to crash due to bad alignment calculation.
define <2 x i48> @scalarize_v2i48(ptr %p, <2 x i1> %mask, <2 x i48> %passthru) {
; CHECK-LABEL: @scalarize_v2i48(
; CHECK-NEXT:    [[SCALAR_MASK:%.*]] = bitcast <2 x i1> [[MASK:%.*]] to i2
; CHECK-NEXT:    [[TMP1:%.*]] = and i2 [[SCALAR_MASK]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i2 [[TMP1]], 0
; CHECK-NEXT:    br i1 [[TMP2]], label [[COND_LOAD:%.*]], label [[ELSE:%.*]]
; CHECK:       cond.load:
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i48, ptr [[P:%.*]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = load i48, ptr [[TMP3]], align 2
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x i48> [[PASSTHRU:%.*]], i48 [[TMP4]], i64 0
; CHECK-NEXT:    br label [[ELSE]]
; CHECK:       else:
; CHECK-NEXT:    [[RES_PHI_ELSE:%.*]] = phi <2 x i48> [ [[TMP5]], [[COND_LOAD]] ], [ [[PASSTHRU]], [[TMP0:%.*]] ]
; CHECK-NEXT:    [[TMP6:%.*]] = and i2 [[SCALAR_MASK]], -2
; CHECK-NEXT:    [[TMP7:%.*]] = icmp ne i2 [[TMP6]], 0
; CHECK-NEXT:    br i1 [[TMP7]], label [[COND_LOAD1:%.*]], label [[ELSE2:%.*]]
; CHECK:       cond.load1:
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i48, ptr [[P]], i32 1
; CHECK-NEXT:    [[TMP9:%.*]] = load i48, ptr [[TMP8]], align 2
; CHECK-NEXT:    [[TMP10:%.*]] = insertelement <2 x i48> [[RES_PHI_ELSE]], i48 [[TMP9]], i64 1
; CHECK-NEXT:    br label [[ELSE2]]
; CHECK:       else2:
; CHECK-NEXT:    [[RES_PHI_ELSE3:%.*]] = phi <2 x i48> [ [[TMP10]], [[COND_LOAD1]] ], [ [[RES_PHI_ELSE]], [[ELSE]] ]
; CHECK-NEXT:    ret <2 x i48> [[RES_PHI_ELSE3]]
;
  %ret = call <2 x i48> @llvm.masked.load.v2i48.p0(ptr %p, i32 16, <2 x i1> %mask, <2 x i48> %passthru)
  ret <2 x i48> %ret
}

declare <2 x i24> @llvm.masked.load.v2i24.p0(ptr, i32, <2 x i1>, <2 x i24>)
declare <2 x i48> @llvm.masked.load.v2i48.p0(ptr, i32, <2 x i1>, <2 x i48>)
declare <2 x i64> @llvm.masked.load.v2i64.p0(ptr, i32, <2 x i1>, <2 x i64>)
