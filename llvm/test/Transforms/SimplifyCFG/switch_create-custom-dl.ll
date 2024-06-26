; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -switch-range-to-icmp < %s | FileCheck %s
target datalayout="p:40:64:64:32"

declare void @foo1()

declare void @foo2()

define void @test1(i32 %V) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    switch i32 [[V:%.*]], label [[F:%.*]] [
; CHECK-NEXT:      i32 17, label [[T:%.*]]
; CHECK-NEXT:      i32 4, label [[T]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       T:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       F:
; CHECK-NEXT:    call void @foo2()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %C1 = icmp eq i32 %V, 4         ; <i1> [#uses=1]
  %C2 = icmp eq i32 %V, 17                ; <i1> [#uses=1]
  %CN = or i1 %C1, %C2            ; <i1> [#uses=1]
  br i1 %CN, label %T, label %F
T:              ; preds = %0
  call void @foo1( )
  ret void
F:              ; preds = %0
  call void @foo2( )
  ret void
}

define void @test1_ptr(ptr %V) {
; CHECK-LABEL: @test1_ptr(
; CHECK-NEXT:    [[MAGICPTR:%.*]] = ptrtoint ptr [[V:%.*]] to i40
; CHECK-NEXT:    switch i40 [[MAGICPTR]], label [[F:%.*]] [
; CHECK-NEXT:      i40 17, label [[T:%.*]]
; CHECK-NEXT:      i40 4, label [[T]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       T:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       F:
; CHECK-NEXT:    call void @foo2()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %C1 = icmp eq ptr %V, inttoptr (i32 4 to ptr)
  %C2 = icmp eq ptr %V, inttoptr (i32 17 to ptr)
  %CN = or i1 %C1, %C2            ; <i1> [#uses=1]
  br i1 %CN, label %T, label %F
T:              ; preds = %0
  call void @foo1( )
  ret void
F:              ; preds = %0
  call void @foo2( )
  ret void
}

define void @test1_ptr_as1(ptr addrspace(1) %V) {
; CHECK-LABEL: @test1_ptr_as1(
; CHECK-NEXT:    [[MAGICPTR:%.*]] = ptrtoint ptr addrspace(1) [[V:%.*]] to i40
; CHECK-NEXT:    switch i40 [[MAGICPTR]], label [[F:%.*]] [
; CHECK-NEXT:      i40 17, label [[T:%.*]]
; CHECK-NEXT:      i40 4, label [[T]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       T:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       F:
; CHECK-NEXT:    call void @foo2()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %C1 = icmp eq ptr addrspace(1) %V, inttoptr (i32 4 to ptr addrspace(1))
  %C2 = icmp eq ptr addrspace(1) %V, inttoptr (i32 17 to ptr addrspace(1))
  %CN = or i1 %C1, %C2            ; <i1> [#uses=1]
  br i1 %CN, label %T, label %F
T:              ; preds = %0
  call void @foo1( )
  ret void
F:              ; preds = %0
  call void @foo2( )
  ret void
}

define void @test2(i32 %V) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    switch i32 [[V:%.*]], label [[T:%.*]] [
; CHECK-NEXT:      i32 17, label [[F:%.*]]
; CHECK-NEXT:      i32 4, label [[F]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       T:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       F:
; CHECK-NEXT:    call void @foo2()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %C1 = icmp ne i32 %V, 4         ; <i1> [#uses=1]
  %C2 = icmp ne i32 %V, 17                ; <i1> [#uses=1]
  %CN = and i1 %C1, %C2           ; <i1> [#uses=1]
  br i1 %CN, label %T, label %F
T:              ; preds = %0
  call void @foo1( )
  ret void
F:              ; preds = %0
  call void @foo2( )
  ret void
}

define void @test3(i32 %V) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    switch i32 [[V:%.*]], label [[F:%.*]] [
; CHECK-NEXT:      i32 4, label [[T:%.*]]
; CHECK-NEXT:      i32 17, label [[T]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       T:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       F:
; CHECK-NEXT:    call void @foo2()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %C1 = icmp eq i32 %V, 4         ; <i1> [#uses=1]
  br i1 %C1, label %T, label %N
N:              ; preds = %0
  %C2 = icmp eq i32 %V, 17                ; <i1> [#uses=1]
  br i1 %C2, label %T, label %F
T:              ; preds = %N, %0
  call void @foo1( )
  ret void
F:              ; preds = %N
  call void @foo2( )
  ret void

}



define i32 @test4(i8 zeroext %c) nounwind ssp noredzone {
; CHECK-LABEL: @test4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    switch i8 [[C:%.*]], label [[LOR_RHS:%.*]] [
; CHECK-NEXT:      i8 62, label [[LOR_END:%.*]]
; CHECK-NEXT:      i8 34, label [[LOR_END]]
; CHECK-NEXT:      i8 92, label [[LOR_END]]
; CHECK-NEXT:    ]
; CHECK:       lor.rhs:
; CHECK-NEXT:    br label [[LOR_END]]
; CHECK:       lor.end:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i1 [ true, [[ENTRY:%.*]] ], [ false, [[LOR_RHS]] ], [ true, [[ENTRY]] ], [ true, [[ENTRY]] ]
; CHECK-NEXT:    [[LOR_EXT:%.*]] = zext i1 [[TMP0]] to i32
; CHECK-NEXT:    ret i32 [[LOR_EXT]]
;
entry:
  %cmp = icmp eq i8 %c, 62
  br i1 %cmp, label %lor.end, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %entry
  %cmp4 = icmp eq i8 %c, 34
  br i1 %cmp4, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %lor.lhs.false
  %cmp8 = icmp eq i8 %c, 92
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.lhs.false, %entry
  %0 = phi i1 [ true, %lor.lhs.false ], [ true, %entry ], [ %cmp8, %lor.rhs ]
  %lor.ext = zext i1 %0 to i32
  ret i32 %lor.ext

}

define i32 @test5(i8 zeroext %c) nounwind ssp noredzone {
; CHECK-LABEL: @test5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    switch i8 [[C:%.*]], label [[LOR_RHS:%.*]] [
; CHECK-NEXT:      i8 62, label [[LOR_END:%.*]]
; CHECK-NEXT:      i8 34, label [[LOR_END]]
; CHECK-NEXT:      i8 92, label [[LOR_END]]
; CHECK-NEXT:    ]
; CHECK:       lor.rhs:
; CHECK-NEXT:    br label [[LOR_END]]
; CHECK:       lor.end:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i1 [ true, [[ENTRY:%.*]] ], [ false, [[LOR_RHS]] ], [ true, [[ENTRY]] ], [ true, [[ENTRY]] ]
; CHECK-NEXT:    [[LOR_EXT:%.*]] = zext i1 [[TMP0]] to i32
; CHECK-NEXT:    ret i32 [[LOR_EXT]]
;
entry:
  switch i8 %c, label %lor.rhs [
  i8 62, label %lor.end
  i8 34, label %lor.end
  i8 92, label %lor.end
  ]

lor.rhs:                                          ; preds = %entry
  %V = icmp eq i8 %c, 92
  br label %lor.end

lor.end:                                          ; preds = %entry, %entry, %entry, %lor.rhs
  %0 = phi i1 [ true, %entry ], [ %V, %lor.rhs ], [ true, %entry ], [ true, %entry ]
  %lor.ext = zext i1 %0 to i32
  ret i32 %lor.ext
}


define i1 @test6(ptr %I) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP_1_I:%.*]] = getelementptr { i32, i32 }, ptr [[I:%.*]], i64 0, i32 1
; CHECK-NEXT:    [[TMP_2_I:%.*]] = load i32, ptr [[TMP_1_I]], align 4
; CHECK-NEXT:    [[TMP_2_I_OFF:%.*]] = add i32 [[TMP_2_I]], -14
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i32 [[TMP_2_I_OFF]], 6
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[SWITCH]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[SPEC_SELECT]]
;
entry:
  %tmp.1.i = getelementptr { i32, i32 }, ptr %I, i64 0, i32 1         ; <ptr> [#uses=1]
  %tmp.2.i = load i32, ptr %tmp.1.i           ; <i32> [#uses=6]
  %tmp.2 = icmp eq i32 %tmp.2.i, 14               ; <i1> [#uses=1]
  br i1 %tmp.2, label %shortcirc_done.4, label %shortcirc_next.0
shortcirc_next.0:               ; preds = %entry
  %tmp.6 = icmp eq i32 %tmp.2.i, 15               ; <i1> [#uses=1]
  br i1 %tmp.6, label %shortcirc_done.4, label %shortcirc_next.1
shortcirc_next.1:               ; preds = %shortcirc_next.0
  %tmp.11 = icmp eq i32 %tmp.2.i, 16              ; <i1> [#uses=1]
  br i1 %tmp.11, label %shortcirc_done.4, label %shortcirc_next.2
shortcirc_next.2:               ; preds = %shortcirc_next.1
  %tmp.16 = icmp eq i32 %tmp.2.i, 17              ; <i1> [#uses=1]
  br i1 %tmp.16, label %shortcirc_done.4, label %shortcirc_next.3
shortcirc_next.3:               ; preds = %shortcirc_next.2
  %tmp.21 = icmp eq i32 %tmp.2.i, 18              ; <i1> [#uses=1]
  br i1 %tmp.21, label %shortcirc_done.4, label %shortcirc_next.4
shortcirc_next.4:               ; preds = %shortcirc_next.3
  %tmp.26 = icmp eq i32 %tmp.2.i, 19              ; <i1> [#uses=1]
  br label %UnifiedReturnBlock
shortcirc_done.4:               ; preds = %shortcirc_next.3, %shortcirc_next.2, %shortcirc_next.1, %shortcirc_next.0, %entry
  br label %UnifiedReturnBlock
UnifiedReturnBlock:             ; preds = %shortcirc_done.4, %shortcirc_next.4
  %UnifiedRetVal = phi i1 [ %tmp.26, %shortcirc_next.4 ], [ true, %shortcirc_done.4 ]             ; <i1> [#uses=1]
  ret i1 %UnifiedRetVal

}

define void @test7(i8 zeroext %c, i32 %x) nounwind ssp noredzone {
; CHECK-LABEL: @test7(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 [[X:%.*]], 32
; CHECK-NEXT:    [[TMP0:%.*]] = freeze i1 [[CMP]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[IF_THEN:%.*]], label [[SWITCH_EARLY_TEST:%.*]]
; CHECK:       switch.early.test:
; CHECK-NEXT:    switch i8 [[C:%.*]], label [[COMMON_RET:%.*]] [
; CHECK-NEXT:      i8 99, label [[IF_THEN]]
; CHECK-NEXT:      i8 97, label [[IF_THEN]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       if.then:
; CHECK-NEXT:    tail call void @foo1() #[[ATTR2:[0-9]+]]
; CHECK-NEXT:    br label [[COMMON_RET]]
;
entry:
  %cmp = icmp ult i32 %x, 32
  %cmp4 = icmp eq i8 %c, 97
  %or.cond = or i1 %cmp, %cmp4
  %cmp9 = icmp eq i8 %c, 99
  %or.cond11 = or i1 %or.cond, %cmp9
  br i1 %or.cond11, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  tail call void @foo1() nounwind noredzone
  ret void

if.end:                                           ; preds = %entry
  ret void

}

define i32 @test8(i8 zeroext %c, i32 %x, i1 %C) nounwind ssp noredzone {
; CHECK-LABEL: @test8(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[N:%.*]], label [[IF_THEN:%.*]]
; CHECK:       N:
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 [[X:%.*]], 32
; CHECK-NEXT:    [[TMP0:%.*]] = freeze i1 [[CMP]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[IF_THEN]], label [[SWITCH_EARLY_TEST:%.*]]
; CHECK:       switch.early.test:
; CHECK-NEXT:    switch i8 [[C:%.*]], label [[COMMON_RET:%.*]] [
; CHECK-NEXT:      i8 99, label [[IF_THEN]]
; CHECK-NEXT:      i8 97, label [[IF_THEN]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    [[COMMON_RET_OP:%.*]] = phi i32 [ [[A:%.*]], [[IF_THEN]] ], [ 0, [[SWITCH_EARLY_TEST]] ]
; CHECK-NEXT:    ret i32 [[COMMON_RET_OP]]
; CHECK:       if.then:
; CHECK-NEXT:    [[A]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ 42, [[SWITCH_EARLY_TEST]] ], [ 42, [[N]] ], [ 42, [[SWITCH_EARLY_TEST]] ]
; CHECK-NEXT:    tail call void @foo1() #[[ATTR2]]
; CHECK-NEXT:    br label [[COMMON_RET]]
;
entry:
  br i1 %C, label %N, label %if.then
N:
  %cmp = icmp ult i32 %x, 32
  %cmp4 = icmp eq i8 %c, 97
  %or.cond = or i1 %cmp, %cmp4
  %cmp9 = icmp eq i8 %c, 99
  %or.cond11 = or i1 %or.cond, %cmp9
  br i1 %or.cond11, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %A = phi i32 [0, %entry], [42, %N]
  tail call void @foo1() nounwind noredzone
  ret i32 %A

if.end:                                           ; preds = %entry
  ret i32 0

}

;; This is "Example 7" from http://blog.regehr.org/archives/320
define i32 @test9(i8 zeroext %c) nounwind ssp noredzone {
; CHECK-LABEL: @test9(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i8 [[C:%.*]], 33
; CHECK-NEXT:    [[TMP0:%.*]] = freeze i1 [[CMP]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[LOR_END:%.*]], label [[SWITCH_EARLY_TEST:%.*]]
; CHECK:       switch.early.test:
; CHECK-NEXT:    switch i8 [[C]], label [[LOR_RHS:%.*]] [
; CHECK-NEXT:      i8 92, label [[LOR_END]]
; CHECK-NEXT:      i8 62, label [[LOR_END]]
; CHECK-NEXT:      i8 60, label [[LOR_END]]
; CHECK-NEXT:      i8 59, label [[LOR_END]]
; CHECK-NEXT:      i8 58, label [[LOR_END]]
; CHECK-NEXT:      i8 46, label [[LOR_END]]
; CHECK-NEXT:      i8 44, label [[LOR_END]]
; CHECK-NEXT:      i8 34, label [[LOR_END]]
; CHECK-NEXT:      i8 39, label [[LOR_END]]
; CHECK-NEXT:    ]
; CHECK:       lor.rhs:
; CHECK-NEXT:    br label [[LOR_END]]
; CHECK:       lor.end:
; CHECK-NEXT:    [[TMP1:%.*]] = phi i1 [ true, [[SWITCH_EARLY_TEST]] ], [ false, [[LOR_RHS]] ], [ true, [[ENTRY:%.*]] ], [ true, [[SWITCH_EARLY_TEST]] ], [ true, [[SWITCH_EARLY_TEST]] ], [ true, [[SWITCH_EARLY_TEST]] ], [ true, [[SWITCH_EARLY_TEST]] ], [ true, [[SWITCH_EARLY_TEST]] ], [ true, [[SWITCH_EARLY_TEST]] ], [ true, [[SWITCH_EARLY_TEST]] ], [ true, [[SWITCH_EARLY_TEST]] ]
; CHECK-NEXT:    [[CONV46:%.*]] = zext i1 [[TMP1]] to i32
; CHECK-NEXT:    ret i32 [[CONV46]]
;
entry:
  %cmp = icmp ult i8 %c, 33
  br i1 %cmp, label %lor.end, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %entry
  %cmp4 = icmp eq i8 %c, 46
  br i1 %cmp4, label %lor.end, label %lor.lhs.false6

lor.lhs.false6:                                   ; preds = %lor.lhs.false
  %cmp9 = icmp eq i8 %c, 44
  br i1 %cmp9, label %lor.end, label %lor.lhs.false11

lor.lhs.false11:                                  ; preds = %lor.lhs.false6
  %cmp14 = icmp eq i8 %c, 58
  br i1 %cmp14, label %lor.end, label %lor.lhs.false16

lor.lhs.false16:                                  ; preds = %lor.lhs.false11
  %cmp19 = icmp eq i8 %c, 59
  br i1 %cmp19, label %lor.end, label %lor.lhs.false21

lor.lhs.false21:                                  ; preds = %lor.lhs.false16
  %cmp24 = icmp eq i8 %c, 60
  br i1 %cmp24, label %lor.end, label %lor.lhs.false26

lor.lhs.false26:                                  ; preds = %lor.lhs.false21
  %cmp29 = icmp eq i8 %c, 62
  br i1 %cmp29, label %lor.end, label %lor.lhs.false31

lor.lhs.false31:                                  ; preds = %lor.lhs.false26
  %cmp34 = icmp eq i8 %c, 34
  br i1 %cmp34, label %lor.end, label %lor.lhs.false36

lor.lhs.false36:                                  ; preds = %lor.lhs.false31
  %cmp39 = icmp eq i8 %c, 92
  br i1 %cmp39, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %lor.lhs.false36
  %cmp43 = icmp eq i8 %c, 39
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.lhs.false36, %lor.lhs.false31, %lor.lhs.false26, %lor.lhs.false21, %lor.lhs.false16, %lor.lhs.false11, %lor.lhs.false6, %lor.lhs.false, %entry
  %0 = phi i1 [ true, %lor.lhs.false36 ], [ true, %lor.lhs.false31 ], [ true, %lor.lhs.false26 ], [ true, %lor.lhs.false21 ], [ true, %lor.lhs.false16 ], [ true, %lor.lhs.false11 ], [ true, %lor.lhs.false6 ], [ true, %lor.lhs.false ], [ true, %entry ], [ %cmp43, %lor.rhs ]
  %conv46 = zext i1 %0 to i32
  ret i32 %conv46


}

define i32 @test10(i32 %mode, i1 %Cond) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[TMP1:%.*]] = freeze i1 [[COND:%.*]]
; CHECK-NEXT:    br i1 [[TMP1]], label [[SWITCH_EARLY_TEST:%.*]], label [[F:%.*]]
; CHECK:       switch.early.test:
; CHECK-NEXT:    switch i32 [[MODE:%.*]], label [[T:%.*]] [
; CHECK-NEXT:      i32 51, label [[F]]
; CHECK-NEXT:      i32 0, label [[F]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    [[COMMON_RET_OP:%.*]] = phi i32 [ 123, [[T]] ], [ 324, [[F]] ]
; CHECK-NEXT:    ret i32 [[COMMON_RET_OP]]
; CHECK:       T:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       F:
; CHECK-NEXT:    call void @foo2()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %A = icmp ne i32 %mode, 0
  %B = icmp ne i32 %mode, 51
  %C = and i1 %A, %B
  %D = and i1 %C, %Cond
  br i1 %D, label %T, label %F
T:
  call void @foo1()
  ret i32 123
F:
  call void @foo2()
  ret i32 324

}

; PR8780
define i32 @test11(i32 %bar) nounwind {
; CHECK-LABEL: @test11(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    switch i32 [[BAR:%.*]], label [[IF_END:%.*]] [
; CHECK-NEXT:      i32 55, label [[RETURN:%.*]]
; CHECK-NEXT:      i32 53, label [[RETURN]]
; CHECK-NEXT:      i32 35, label [[RETURN]]
; CHECK-NEXT:      i32 24, label [[RETURN]]
; CHECK-NEXT:      i32 23, label [[RETURN]]
; CHECK-NEXT:      i32 12, label [[RETURN]]
; CHECK-NEXT:      i32 4, label [[RETURN]]
; CHECK-NEXT:    ]
; CHECK:       if.end:
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       return:
; CHECK-NEXT:    [[RETVAL_0:%.*]] = phi i32 [ 0, [[IF_END]] ], [ 1, [[ENTRY:%.*]] ], [ 1, [[ENTRY]] ], [ 1, [[ENTRY]] ], [ 1, [[ENTRY]] ], [ 1, [[ENTRY]] ], [ 1, [[ENTRY]] ], [ 1, [[ENTRY]] ]
; CHECK-NEXT:    ret i32 [[RETVAL_0]]
;
entry:
  %cmp = icmp eq i32 %bar, 4
  %cmp2 = icmp eq i32 %bar, 35
  %or.cond = or i1 %cmp, %cmp2
  %cmp5 = icmp eq i32 %bar, 53
  %or.cond1 = or i1 %or.cond, %cmp5
  %cmp8 = icmp eq i32 %bar, 24
  %or.cond2 = or i1 %or.cond1, %cmp8
  %cmp11 = icmp eq i32 %bar, 23
  %or.cond3 = or i1 %or.cond2, %cmp11
  %cmp14 = icmp eq i32 %bar, 55
  %or.cond4 = or i1 %or.cond3, %cmp14
  %cmp17 = icmp eq i32 %bar, 12
  %or.cond5 = or i1 %or.cond4, %cmp17
  %cmp20 = icmp eq i32 %bar, 35
  %or.cond6 = or i1 %or.cond5, %cmp20
  br i1 %or.cond6, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %return

if.end:                                           ; preds = %entry
  br label %return

return:                                           ; preds = %if.end, %if.then
  %retval.0 = phi i32 [ 1, %if.then ], [ 0, %if.end ]
  ret i32 %retval.0

}

define void @test12() nounwind {
; CHECK-LABEL: @test12(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_OLD:%.*]] = icmp eq i32 undef, undef
; CHECK-NEXT:    br i1 [[A_OLD]], label [[BB55_US_US:%.*]], label [[MALFORMED:%.*]]
; CHECK:       bb55.us.us:
; CHECK-NEXT:    [[B:%.*]] = icmp ugt i32 undef, undef
; CHECK-NEXT:    [[A:%.*]] = icmp eq i32 undef, undef
; CHECK-NEXT:    [[OR_COND:%.*]] = or i1 [[B]], [[A]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[BB55_US_US]], label [[MALFORMED]]
; CHECK:       malformed:
; CHECK-NEXT:    ret void
;
entry:
  br label %bb49.us.us

bb49.us.us:
  %A = icmp eq i32 undef, undef
  br i1 %A, label %bb55.us.us, label %malformed

bb48.us.us:
  %B = icmp ugt i32 undef, undef
  br i1 %B, label %bb55.us.us, label %bb49.us.us

bb55.us.us:
  br label %bb48.us.us

malformed:
  ret void

}

; test13 - handle switch formation with ult.
define void @test13(i32 %x) nounwind ssp noredzone {
; CHECK-LABEL: @test13(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    switch i32 [[X:%.*]], label [[IF_END:%.*]] [
; CHECK-NEXT:      i32 6, label [[IF_THEN:%.*]]
; CHECK-NEXT:      i32 4, label [[IF_THEN]]
; CHECK-NEXT:      i32 3, label [[IF_THEN]]
; CHECK-NEXT:      i32 1, label [[IF_THEN]]
; CHECK-NEXT:      i32 0, label [[IF_THEN]]
; CHECK-NEXT:    ]
; CHECK:       if.then:
; CHECK-NEXT:    call void @foo1() #[[ATTR3:[0-9]+]]
; CHECK-NEXT:    br label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp = icmp ult i32 %x, 2
  br i1 %cmp, label %if.then, label %lor.lhs.false3

lor.lhs.false3:                                   ; preds = %lor.lhs.false
  %cmp5 = icmp eq i32 %x, 3
  br i1 %cmp5, label %if.then, label %lor.lhs.false6

lor.lhs.false6:                                   ; preds = %lor.lhs.false3
  %cmp8 = icmp eq i32 %x, 4
  br i1 %cmp8, label %if.then, label %lor.lhs.false9

lor.lhs.false9:                                   ; preds = %lor.lhs.false6
  %cmp11 = icmp eq i32 %x, 6
  br i1 %cmp11, label %if.then, label %if.end

if.then:                                          ; preds = %lor.lhs.false9, %lor.lhs.false6, %lor.lhs.false3, %lor.lhs.false, %entry
  call void @foo1() noredzone
  br label %if.end

if.end:                                           ; preds = %if.then, %lor.lhs.false9
  ret void
}

; test14 - handle switch formation with ult.
define void @test14(i32 %x) nounwind ssp noredzone {
; CHECK-LABEL: @test14(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    switch i32 [[X:%.*]], label [[IF_END:%.*]] [
; CHECK-NEXT:      i32 6, label [[IF_THEN:%.*]]
; CHECK-NEXT:      i32 4, label [[IF_THEN]]
; CHECK-NEXT:      i32 3, label [[IF_THEN]]
; CHECK-NEXT:      i32 2, label [[IF_THEN]]
; CHECK-NEXT:      i32 1, label [[IF_THEN]]
; CHECK-NEXT:      i32 0, label [[IF_THEN]]
; CHECK-NEXT:    ]
; CHECK:       if.then:
; CHECK-NEXT:    call void @foo1() #[[ATTR3]]
; CHECK-NEXT:    br label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp = icmp ugt i32 %x, 2
  br i1 %cmp, label %lor.lhs.false3, label %if.then

lor.lhs.false3:                                   ; preds = %lor.lhs.false
  %cmp5 = icmp ne i32 %x, 3
  br i1 %cmp5, label %lor.lhs.false6, label %if.then

lor.lhs.false6:                                   ; preds = %lor.lhs.false3
  %cmp8 = icmp ne i32 %x, 4
  br i1 %cmp8, label %lor.lhs.false9, label %if.then

lor.lhs.false9:                                   ; preds = %lor.lhs.false6
  %cmp11 = icmp ne i32 %x, 6
  br i1 %cmp11, label %if.end, label %if.then

if.then:                                          ; preds = %lor.lhs.false9, %lor.lhs.false6, %lor.lhs.false3, %lor.lhs.false, %entry
  call void @foo1() noredzone
  br label %if.end

if.end:                                           ; preds = %if.then, %lor.lhs.false9
  ret void
}

; Don't crash on ginormous ranges.
define void @test15(i128 %x) nounwind {
; CHECK-LABEL: @test15(
; CHECK-NEXT:  if.end:
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i128 [[X:%.*]], 2
; CHECK-NEXT:    ret void
;
  %cmp = icmp ugt i128 %x, 2
  br i1 %cmp, label %if.end, label %lor.false

lor.false:
  %cmp2 = icmp ne i128 %x, 100000000000000000000
  br i1 %cmp2, label %if.end, label %if.then

if.then:
  call void @foo1() noredzone
  br label %if.end

if.end:
  ret void

}

; PR8675
; rdar://5134905
define zeroext i1 @test16(i32 %x) nounwind {
; CHECK-LABEL: @test16(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], -1
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i32 [[X_OFF]], 3
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[SWITCH]], i1 true, i1 false
; CHECK-NEXT:    ret i1 [[SPEC_SELECT]]
;
entry:
  %cmp.i = icmp eq i32 %x, 1
  br i1 %cmp.i, label %lor.end, label %lor.lhs.false

lor.lhs.false:
  %cmp.i2 = icmp eq i32 %x, 2
  br i1 %cmp.i2, label %lor.end, label %lor.rhs

lor.rhs:
  %cmp.i1 = icmp eq i32 %x, 3
  br label %lor.end

lor.end:
  %0 = phi i1 [ true, %lor.lhs.false ], [ true, %entry ], [ %cmp.i1, %lor.rhs ]
  ret i1 %0
}

; Check that we don't turn an icmp into a switch where it's not useful.
define void @test17(i32 %x, i32 %y) {
; CHECK-LABEL: @test17(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 [[X:%.*]], 3
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i32 [[Y:%.*]], 2
; CHECK-NEXT:    [[OR_COND775:%.*]] = or i1 [[CMP]], [[SWITCH]]
; CHECK-NEXT:    br i1 [[OR_COND775]], label [[LOR_LHS_FALSE8:%.*]], label [[COMMON_RET:%.*]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       lor.lhs.false8:
; CHECK-NEXT:    tail call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %cmp = icmp ult i32 %x, 3
  %switch = icmp ult i32 %y, 2
  %or.cond775 = or i1 %cmp, %switch
  br i1 %or.cond775, label %lor.lhs.false8, label %return

lor.lhs.false8:
  tail call void @foo1()
  ret void

return:
  ret void

}

define void @test18(i32 %arg) {
; CHECK-LABEL: @test18(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[ARG_OFF:%.*]] = add i32 [[ARG:%.*]], -8
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i32 [[ARG_OFF]], 11
; CHECK-NEXT:    br i1 [[SWITCH]], label [[BB19:%.*]], label [[BB20:%.*]]
; CHECK:       bb19:
; CHECK-NEXT:    tail call void @foo1()
; CHECK-NEXT:    br label [[BB20]]
; CHECK:       bb20:
; CHECK-NEXT:    ret void
;
bb:
  %tmp = and i32 %arg, -2
  %tmp1 = icmp eq i32 %tmp, 8
  %tmp2 = icmp eq i32 %arg, 10
  %tmp3 = or i1 %tmp1, %tmp2
  %tmp4 = icmp eq i32 %arg, 11
  %tmp5 = or i1 %tmp3, %tmp4
  %tmp6 = icmp eq i32 %arg, 12
  %tmp7 = or i1 %tmp5, %tmp6
  br i1 %tmp7, label %bb19, label %bb8

bb8:                                              ; preds = %bb
  %tmp9 = add i32 %arg, -13
  %tmp10 = icmp ult i32 %tmp9, 2
  %tmp11 = icmp eq i32 %arg, 16
  %tmp12 = or i1 %tmp10, %tmp11
  %tmp13 = icmp eq i32 %arg, 17
  %tmp14 = or i1 %tmp12, %tmp13
  %tmp15 = icmp eq i32 %arg, 18
  %tmp16 = or i1 %tmp14, %tmp15
  %tmp17 = icmp eq i32 %arg, 15
  %tmp18 = or i1 %tmp16, %tmp17
  br i1 %tmp18, label %bb19, label %bb20

bb19:                                             ; preds = %bb8, %bb
  tail call void @foo1()
  br label %bb20

bb20:                                             ; preds = %bb19, %bb8
  ret void

}

define void @PR26323(i1 %tobool23, i32 %tmp3) {
; CHECK-LABEL: @PR26323(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TOBOOL5:%.*]] = icmp ne i32 [[TMP3:%.*]], 0
; CHECK-NEXT:    [[NEG14:%.*]] = and i32 [[TMP3]], -2
; CHECK-NEXT:    [[CMP17:%.*]] = icmp ne i32 [[NEG14]], -1
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[TOBOOL5]], [[TOBOOL23:%.*]]
; CHECK-NEXT:    [[OR_COND1:%.*]] = and i1 [[CMP17]], [[OR_COND]]
; CHECK-NEXT:    br i1 [[OR_COND1]], label [[IF_END29:%.*]], label [[IF_THEN27:%.*]]
; CHECK:       if.then27:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    unreachable
; CHECK:       if.end29:
; CHECK-NEXT:    ret void
;
entry:
  %tobool5 = icmp ne i32 %tmp3, 0
  %neg14 = and i32 %tmp3, -2
  %cmp17 = icmp ne i32 %neg14, -1
  %or.cond = and i1 %tobool5, %tobool23
  %or.cond1 = and i1 %cmp17, %or.cond
  br i1 %or.cond1, label %if.end29, label %if.then27

if.then27:                                        ; preds = %entry
  call void @foo1()
  unreachable

if.end29:                                         ; preds = %entry
  ret void
}

define void @test19(i32 %arg) {
; CHECK-LABEL: @test19(
; CHECK-NEXT:    switch i32 [[ARG:%.*]], label [[COMMON_RET:%.*]] [
; CHECK-NEXT:      i32 32, label [[IF:%.*]]
; CHECK-NEXT:      i32 13, label [[IF]]
; CHECK-NEXT:      i32 12, label [[IF]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       if:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %and = and i32 %arg, -2
  %cmp1 = icmp eq i32 %and, 12
  %cmp2 = icmp eq i32 %arg, 32
  %pred = or i1 %cmp1, %cmp2
  br i1 %pred, label %if, label %else

if:
  call void @foo1()
  ret void

else:
  ret void
}

; Since %cmp1 is always false, a switch is never formed
define void @test20(i32 %arg) {
; CHECK-LABEL: @test20(
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[ARG:%.*]], -2
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[AND]], 13
; CHECK-NEXT:    [[CMP2:%.*]] = icmp eq i32 [[ARG]], 32
; CHECK-NEXT:    [[PRED:%.*]] = or i1 [[CMP1]], [[CMP2]]
; CHECK-NEXT:    br i1 [[PRED]], label [[IF:%.*]], label [[COMMON_RET:%.*]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       if:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %and = and i32 %arg, -2
  %cmp1 = icmp eq i32 %and, 13
  %cmp2 = icmp eq i32 %arg, 32
  %pred = or i1 %cmp1, %cmp2
  br i1 %pred, label %if, label %else

if:
  call void @foo1()
  ret void

else:
  ret void
}

; Form a switch when or'ing a power of two
define void @test21(i32 %arg) {
; CHECK-LABEL: @test21(
; CHECK-NEXT:    switch i32 [[ARG:%.*]], label [[IF:%.*]] [
; CHECK-NEXT:      i32 32, label [[COMMON_RET:%.*]]
; CHECK-NEXT:      i32 13, label [[COMMON_RET]]
; CHECK-NEXT:      i32 12, label [[COMMON_RET]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       if:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %and = or i32 %arg, 1
  %cmp1 = icmp ne i32 %and, 13
  %cmp2 = icmp ne i32 %arg, 32
  %pred = and i1 %cmp1, %cmp2
  br i1 %pred, label %if, label %else

if:
  call void @foo1()
  ret void

else:
  ret void
}

; Since %cmp1 is always false, a switch is never formed
define void @test22(i32 %arg) {
; CHECK-LABEL: @test22(
; CHECK-NEXT:    [[AND:%.*]] = or i32 [[ARG:%.*]], 1
; CHECK-NEXT:    [[CMP1:%.*]] = icmp ne i32 [[AND]], 12
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ne i32 [[ARG]], 32
; CHECK-NEXT:    [[PRED:%.*]] = and i1 [[CMP1]], [[CMP2]]
; CHECK-NEXT:    br i1 [[PRED]], label [[IF:%.*]], label [[COMMON_RET:%.*]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       if:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %and = or i32 %arg, 1
  %cmp1 = icmp ne i32 %and, 12
  %cmp2 = icmp ne i32 %arg, 32
  %pred = and i1 %cmp1, %cmp2
  br i1 %pred, label %if, label %else

if:
  call void @foo1()
  ret void

else:
  ret void
}
