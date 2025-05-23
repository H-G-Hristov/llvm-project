; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc --mtriple=loongarch64 -mattr=+d --verify-machineinstrs < %s \
; RUN:   | FileCheck %s

;; The stack size is 2048 and the SP adjustment will be split.
define i32 @SplitSP() nounwind {
; CHECK-LABEL: SplitSP:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addi.d $sp, $sp, -2032
; CHECK-NEXT:    st.d $ra, $sp, 2024 # 8-byte Folded Spill
; CHECK-NEXT:    addi.d $sp, $sp, -16
; CHECK-NEXT:    addi.d $a0, $sp, 12
; CHECK-NEXT:    pcaddu18i $ra, %call36(foo)
; CHECK-NEXT:    jirl $ra, $ra, 0
; CHECK-NEXT:    move $a0, $zero
; CHECK-NEXT:    addi.d $sp, $sp, 16
; CHECK-NEXT:    ld.d $ra, $sp, 2024 # 8-byte Folded Reload
; CHECK-NEXT:    addi.d $sp, $sp, 2032
; CHECK-NEXT:    ret
entry:
  %xx = alloca [2028 x i8], align 1
  %0 = getelementptr inbounds [2028 x i8], ptr %xx, i32 0, i32 0
  %call = call i32 @foo(ptr nonnull %0)
  ret i32 0
}

;; The stack size is 2032 and the SP adjustment will not be split.
;; 2016 + 8(RA) + 8(emergency spill slot) = 2032
define i32 @NoSplitSP() nounwind {
; CHECK-LABEL: NoSplitSP:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addi.d $sp, $sp, -2032
; CHECK-NEXT:    st.d $ra, $sp, 2024 # 8-byte Folded Spill
; CHECK-NEXT:    addi.d $a0, $sp, 8
; CHECK-NEXT:    pcaddu18i $ra, %call36(foo)
; CHECK-NEXT:    jirl $ra, $ra, 0
; CHECK-NEXT:    move $a0, $zero
; CHECK-NEXT:    ld.d $ra, $sp, 2024 # 8-byte Folded Reload
; CHECK-NEXT:    addi.d $sp, $sp, 2032
; CHECK-NEXT:    ret
entry:
  %xx = alloca [2016 x i8], align 1
  %0 = getelementptr inbounds [2024 x i8], ptr %xx, i32 0, i32 0
  %call = call i32 @foo(ptr nonnull %0)
  ret i32 0
}

declare i32 @foo(ptr)
