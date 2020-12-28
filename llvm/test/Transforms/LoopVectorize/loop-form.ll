; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -loop-vectorize -force-vector-width=2 < %s | FileCheck %s
; RUN: opt -S -loop-vectorize -force-vector-width=2  -prefer-predicate-over-epilogue=predicate-dont-vectorize < %s | FileCheck --check-prefix TAILFOLD %s

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"

define void @bottom_tested(i16* %p, i32 %n) {
; CHECK-LABEL: @bottom_tested(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp sgt i32 [[N:%.*]], 0
; CHECK-NEXT:    [[SMAX:%.*]] = select i1 [[TMP0]], i32 [[N]], i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = add nuw i32 [[SMAX]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i32 [[TMP1]], 2
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i32 [[TMP1]], 2
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i32 [[TMP1]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP2:%.*]] = add i32 [[INDEX]], 0
; CHECK-NEXT:    [[TMP3:%.*]] = sext i32 [[TMP2]] to i64
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i16, i16* [[TMP4]], i32 0
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i16* [[TMP5]] to <2 x i16>*
; CHECK-NEXT:    store <2 x i16> zeroinitializer, <2 x i16>* [[TMP6]], align 4
; CHECK-NEXT:    [[INDEX_NEXT]] = add i32 [[INDEX]], 2
; CHECK-NEXT:    [[TMP7:%.*]] = icmp eq i32 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP7]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], [[LOOP0:!llvm.loop !.*]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i32 [[TMP1]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[IF_END:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i32 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INC:%.*]], [[FOR_COND]] ]
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_COND]], label [[IF_END]], [[LOOP2:!llvm.loop !.*]]
; CHECK:       if.end:
; CHECK-NEXT:    ret void
;
; TAILFOLD-LABEL: @bottom_tested(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    [[TMP0:%.*]] = icmp sgt i32 [[N:%.*]], 0
; TAILFOLD-NEXT:    [[SMAX:%.*]] = select i1 [[TMP0]], i32 [[N]], i32 0
; TAILFOLD-NEXT:    [[TMP1:%.*]] = add nuw i32 [[SMAX]], 1
; TAILFOLD-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; TAILFOLD:       vector.ph:
; TAILFOLD-NEXT:    [[N_RND_UP:%.*]] = add i32 [[TMP1]], 1
; TAILFOLD-NEXT:    [[N_MOD_VF:%.*]] = urem i32 [[N_RND_UP]], 2
; TAILFOLD-NEXT:    [[N_VEC:%.*]] = sub i32 [[N_RND_UP]], [[N_MOD_VF]]
; TAILFOLD-NEXT:    [[TRIP_COUNT_MINUS_1:%.*]] = sub i32 [[TMP1]], 1
; TAILFOLD-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <2 x i32> undef, i32 [[TRIP_COUNT_MINUS_1]], i32 0
; TAILFOLD-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <2 x i32> [[BROADCAST_SPLATINSERT]], <2 x i32> undef, <2 x i32> zeroinitializer
; TAILFOLD-NEXT:    br label [[VECTOR_BODY:%.*]]
; TAILFOLD:       vector.body:
; TAILFOLD-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[PRED_STORE_CONTINUE2:%.*]] ]
; TAILFOLD-NEXT:    [[VEC_IND:%.*]] = phi <2 x i32> [ <i32 0, i32 1>, [[VECTOR_PH]] ], [ [[VEC_IND_NEXT:%.*]], [[PRED_STORE_CONTINUE2]] ]
; TAILFOLD-NEXT:    [[TMP2:%.*]] = add i32 [[INDEX]], 0
; TAILFOLD-NEXT:    [[TMP3:%.*]] = add i32 [[INDEX]], 1
; TAILFOLD-NEXT:    [[TMP4:%.*]] = icmp ule <2 x i32> [[VEC_IND]], [[BROADCAST_SPLAT]]
; TAILFOLD-NEXT:    [[TMP5:%.*]] = sext <2 x i32> [[VEC_IND]] to <2 x i64>
; TAILFOLD-NEXT:    [[TMP6:%.*]] = extractelement <2 x i1> [[TMP4]], i32 0
; TAILFOLD-NEXT:    br i1 [[TMP6]], label [[PRED_STORE_IF:%.*]], label [[PRED_STORE_CONTINUE:%.*]]
; TAILFOLD:       pred.store.if:
; TAILFOLD-NEXT:    [[TMP7:%.*]] = extractelement <2 x i64> [[TMP5]], i32 0
; TAILFOLD-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[TMP7]]
; TAILFOLD-NEXT:    store i16 0, i16* [[TMP8]], align 4
; TAILFOLD-NEXT:    br label [[PRED_STORE_CONTINUE]]
; TAILFOLD:       pred.store.continue:
; TAILFOLD-NEXT:    [[TMP9:%.*]] = extractelement <2 x i1> [[TMP4]], i32 1
; TAILFOLD-NEXT:    br i1 [[TMP9]], label [[PRED_STORE_IF1:%.*]], label [[PRED_STORE_CONTINUE2]]
; TAILFOLD:       pred.store.if1:
; TAILFOLD-NEXT:    [[TMP10:%.*]] = extractelement <2 x i64> [[TMP5]], i32 1
; TAILFOLD-NEXT:    [[TMP11:%.*]] = getelementptr inbounds i16, i16* [[P]], i64 [[TMP10]]
; TAILFOLD-NEXT:    store i16 0, i16* [[TMP11]], align 4
; TAILFOLD-NEXT:    br label [[PRED_STORE_CONTINUE2]]
; TAILFOLD:       pred.store.continue2:
; TAILFOLD-NEXT:    [[INDEX_NEXT]] = add i32 [[INDEX]], 2
; TAILFOLD-NEXT:    [[VEC_IND_NEXT]] = add <2 x i32> [[VEC_IND]], <i32 2, i32 2>
; TAILFOLD-NEXT:    [[TMP12:%.*]] = icmp eq i32 [[INDEX_NEXT]], [[N_VEC]]
; TAILFOLD-NEXT:    br i1 [[TMP12]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], [[LOOP0:!llvm.loop !.*]]
; TAILFOLD:       middle.block:
; TAILFOLD-NEXT:    br i1 true, label [[IF_END:%.*]], label [[SCALAR_PH]]
; TAILFOLD:       scalar.ph:
; TAILFOLD-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i32 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; TAILFOLD-NEXT:    br label [[FOR_COND:%.*]]
; TAILFOLD:       for.cond:
; TAILFOLD-NEXT:    [[I:%.*]] = phi i32 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INC:%.*]], [[FOR_COND]] ]
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; TAILFOLD-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N]]
; TAILFOLD-NEXT:    br i1 [[CMP]], label [[FOR_COND]], label [[IF_END]], [[LOOP2:!llvm.loop !.*]]
; TAILFOLD:       if.end:
; TAILFOLD-NEXT:    ret void
;
entry:
  br label %for.cond

for.cond:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.cond ]
  %iprom = sext i32 %i to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %inc = add nsw i32 %i, 1
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %for.cond, label %if.end

if.end:
  ret void
}

define void @early_exit(i16* %p, i32 %n) {
; CHECK-LABEL: @early_exit(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp sgt i32 [[N:%.*]], 0
; CHECK-NEXT:    [[SMAX:%.*]] = select i1 [[TMP0]], i32 [[N]], i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = add nuw i32 [[SMAX]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ule i32 [[TMP1]], 2
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i32 [[TMP1]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[N_MOD_VF]], 0
; CHECK-NEXT:    [[TMP3:%.*]] = select i1 [[TMP2]], i32 2, i32 [[N_MOD_VF]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i32 [[TMP1]], [[TMP3]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_IND:%.*]] = phi <2 x i32> [ <i32 0, i32 1>, [[VECTOR_PH]] ], [ [[VEC_IND_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP4:%.*]] = add i32 [[INDEX]], 0
; CHECK-NEXT:    [[TMP5:%.*]] = add i32 [[INDEX]], 1
; CHECK-NEXT:    [[TMP6:%.*]] = sext i32 [[TMP4]] to i64
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[TMP6]]
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i16, i16* [[TMP7]], i32 0
; CHECK-NEXT:    [[TMP9:%.*]] = bitcast i16* [[TMP8]] to <2 x i16>*
; CHECK-NEXT:    store <2 x i16> zeroinitializer, <2 x i16>* [[TMP9]], align 4
; CHECK-NEXT:    [[INDEX_NEXT]] = add i32 [[INDEX]], 2
; CHECK-NEXT:    [[VEC_IND_NEXT]] = add <2 x i32> [[VEC_IND]], <i32 2, i32 2>
; CHECK-NEXT:    [[TMP10:%.*]] = icmp eq i32 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP10]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], [[LOOP4:!llvm.loop !.*]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i32 [[TMP1]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[IF_END:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i32 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    br label [[FOR_COND]], [[LOOP5:!llvm.loop !.*]]
; CHECK:       if.end:
; CHECK-NEXT:    ret void
;
; TAILFOLD-LABEL: @early_exit(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[FOR_COND:%.*]]
; TAILFOLD:       for.cond:
; TAILFOLD-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; TAILFOLD-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; TAILFOLD-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END:%.*]]
; TAILFOLD:       for.body:
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; TAILFOLD-NEXT:    br label [[FOR_COND]]
; TAILFOLD:       if.end:
; TAILFOLD-NEXT:    ret void
;
entry:
  br label %for.cond

for.cond:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %for.body, label %if.end

for.body:
  %iprom = sext i32 %i to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %inc = add nsw i32 %i, 1
  br label %for.cond

if.end:
  ret void
}

; Same as early_exit, but with optsize to prevent the use of
; a scalar epilogue.  -- Can't vectorize this in either case.
define void @optsize(i16* %p, i32 %n) optsize {
; CHECK-LABEL: @optsize(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    br label [[FOR_COND]]
; CHECK:       if.end:
; CHECK-NEXT:    ret void
;
; TAILFOLD-LABEL: @optsize(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[FOR_COND:%.*]]
; TAILFOLD:       for.cond:
; TAILFOLD-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; TAILFOLD-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; TAILFOLD-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END:%.*]]
; TAILFOLD:       for.body:
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; TAILFOLD-NEXT:    br label [[FOR_COND]]
; TAILFOLD:       if.end:
; TAILFOLD-NEXT:    ret void
;
entry:
  br label %for.cond

for.cond:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %for.body, label %if.end

for.body:
  %iprom = sext i32 %i to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %inc = add nsw i32 %i, 1
  br label %for.cond

if.end:
  ret void
}


; multiple exit - no values inside the loop used outside
define void @multiple_unique_exit(i16* %p, i32 %n) {
; CHECK-LABEL: @multiple_unique_exit(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp sgt i32 [[N:%.*]], 0
; CHECK-NEXT:    [[SMAX:%.*]] = select i1 [[TMP0]], i32 [[N]], i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[SMAX]], 2096
; CHECK-NEXT:    [[UMIN:%.*]] = select i1 [[TMP1]], i32 [[SMAX]], i32 2096
; CHECK-NEXT:    [[TMP2:%.*]] = add nuw nsw i32 [[UMIN]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ule i32 [[TMP2]], 2
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i32 [[TMP2]], 2
; CHECK-NEXT:    [[TMP3:%.*]] = icmp eq i32 [[N_MOD_VF]], 0
; CHECK-NEXT:    [[TMP4:%.*]] = select i1 [[TMP3]], i32 2, i32 [[N_MOD_VF]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i32 [[TMP2]], [[TMP4]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_IND:%.*]] = phi <2 x i32> [ <i32 0, i32 1>, [[VECTOR_PH]] ], [ [[VEC_IND_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP5:%.*]] = add i32 [[INDEX]], 0
; CHECK-NEXT:    [[TMP6:%.*]] = add i32 [[INDEX]], 1
; CHECK-NEXT:    [[TMP7:%.*]] = sext i32 [[TMP5]] to i64
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[TMP7]]
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds i16, i16* [[TMP8]], i32 0
; CHECK-NEXT:    [[TMP10:%.*]] = bitcast i16* [[TMP9]] to <2 x i16>*
; CHECK-NEXT:    store <2 x i16> zeroinitializer, <2 x i16>* [[TMP10]], align 4
; CHECK-NEXT:    [[INDEX_NEXT]] = add i32 [[INDEX]], 2
; CHECK-NEXT:    [[VEC_IND_NEXT]] = add <2 x i32> [[VEC_IND]], <i32 2, i32 2>
; CHECK-NEXT:    [[TMP11:%.*]] = icmp eq i32 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP11]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], [[LOOP6:!llvm.loop !.*]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i32 [[TMP2]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[IF_END:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i32 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[I]], 2096
; CHECK-NEXT:    br i1 [[CMP2]], label [[FOR_COND]], label [[IF_END]], [[LOOP7:!llvm.loop !.*]]
; CHECK:       if.end:
; CHECK-NEXT:    ret void
;
; TAILFOLD-LABEL: @multiple_unique_exit(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[FOR_COND:%.*]]
; TAILFOLD:       for.cond:
; TAILFOLD-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; TAILFOLD-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; TAILFOLD-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END:%.*]]
; TAILFOLD:       for.body:
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; TAILFOLD-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[I]], 2096
; TAILFOLD-NEXT:    br i1 [[CMP2]], label [[FOR_COND]], label [[IF_END]]
; TAILFOLD:       if.end:
; TAILFOLD-NEXT:    ret void
;
entry:
  br label %for.cond

for.cond:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %for.body, label %if.end

for.body:
  %iprom = sext i32 %i to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %inc = add nsw i32 %i, 1
  %cmp2 = icmp slt i32 %i, 2096
  br i1 %cmp2, label %for.cond, label %if.end

if.end:
  ret void
}

; multiple exit - with an lcssa phi
define i32 @multiple_unique_exit2(i16* %p, i32 %n) {
; CHECK-LABEL: @multiple_unique_exit2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[I]], 2096
; CHECK-NEXT:    br i1 [[CMP2]], label [[FOR_COND]], label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    [[I_LCSSA:%.*]] = phi i32 [ [[I]], [[FOR_BODY]] ], [ [[I]], [[FOR_COND]] ]
; CHECK-NEXT:    ret i32 [[I_LCSSA]]
;
; TAILFOLD-LABEL: @multiple_unique_exit2(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[FOR_COND:%.*]]
; TAILFOLD:       for.cond:
; TAILFOLD-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; TAILFOLD-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; TAILFOLD-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END:%.*]]
; TAILFOLD:       for.body:
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; TAILFOLD-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[I]], 2096
; TAILFOLD-NEXT:    br i1 [[CMP2]], label [[FOR_COND]], label [[IF_END]]
; TAILFOLD:       if.end:
; TAILFOLD-NEXT:    [[I_LCSSA:%.*]] = phi i32 [ [[I]], [[FOR_BODY]] ], [ [[I]], [[FOR_COND]] ]
; TAILFOLD-NEXT:    ret i32 [[I_LCSSA]]
;
entry:
  br label %for.cond

for.cond:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %for.body, label %if.end

for.body:
  %iprom = sext i32 %i to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %inc = add nsw i32 %i, 1
  %cmp2 = icmp slt i32 %i, 2096
  br i1 %cmp2, label %for.cond, label %if.end

if.end:
  ret i32 %i
}

; multiple exit w/a non lcssa phi
define i32 @multiple_unique_exit3(i16* %p, i32 %n) {
; CHECK-LABEL: @multiple_unique_exit3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[I]], 2096
; CHECK-NEXT:    br i1 [[CMP2]], label [[FOR_COND]], label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    [[EXIT:%.*]] = phi i32 [ 0, [[FOR_COND]] ], [ 1, [[FOR_BODY]] ]
; CHECK-NEXT:    ret i32 [[EXIT]]
;
; TAILFOLD-LABEL: @multiple_unique_exit3(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[FOR_COND:%.*]]
; TAILFOLD:       for.cond:
; TAILFOLD-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; TAILFOLD-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; TAILFOLD-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END:%.*]]
; TAILFOLD:       for.body:
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; TAILFOLD-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[I]], 2096
; TAILFOLD-NEXT:    br i1 [[CMP2]], label [[FOR_COND]], label [[IF_END]]
; TAILFOLD:       if.end:
; TAILFOLD-NEXT:    [[EXIT:%.*]] = phi i32 [ 0, [[FOR_COND]] ], [ 1, [[FOR_BODY]] ]
; TAILFOLD-NEXT:    ret i32 [[EXIT]]
;
entry:
  br label %for.cond

for.cond:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %for.body, label %if.end

for.body:
  %iprom = sext i32 %i to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %inc = add nsw i32 %i, 1
  %cmp2 = icmp slt i32 %i, 2096
  br i1 %cmp2, label %for.cond, label %if.end

if.end:
  %exit = phi i32 [0, %for.cond], [1, %for.body]
  ret i32 %exit
}

; multiple exits w/distinct target blocks
define i32 @multiple_exit_blocks(i16* %p, i32 %n) {
; CHECK-LABEL: @multiple_exit_blocks(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[I]], 2096
; CHECK-NEXT:    br i1 [[CMP2]], label [[FOR_COND]], label [[IF_END2:%.*]]
; CHECK:       if.end:
; CHECK-NEXT:    ret i32 0
; CHECK:       if.end2:
; CHECK-NEXT:    ret i32 1
;
; TAILFOLD-LABEL: @multiple_exit_blocks(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[FOR_COND:%.*]]
; TAILFOLD:       for.cond:
; TAILFOLD-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY:%.*]] ]
; TAILFOLD-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I]], [[N:%.*]]
; TAILFOLD-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[IF_END:%.*]]
; TAILFOLD:       for.body:
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; TAILFOLD-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[I]], 2096
; TAILFOLD-NEXT:    br i1 [[CMP2]], label [[FOR_COND]], label [[IF_END2:%.*]]
; TAILFOLD:       if.end:
; TAILFOLD-NEXT:    ret i32 0
; TAILFOLD:       if.end2:
; TAILFOLD-NEXT:    ret i32 1
;
entry:
  br label %for.cond

for.cond:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %cmp = icmp slt i32 %i, %n
  br i1 %cmp, label %for.body, label %if.end

for.body:
  %iprom = sext i32 %i to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %inc = add nsw i32 %i, 1
  %cmp2 = icmp slt i32 %i, 2096
  br i1 %cmp2, label %for.cond, label %if.end2

if.end:
  ret i32 0

if.end2:
  ret i32 1
}

; unique exit case but with a switch as two edges between the same pair of
; blocks is an often missed edge case
define i32 @multiple_exit_switch(i16* %p, i32 %n) {
; CHECK-LABEL: @multiple_exit_switch(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_COND]] ]
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    switch i32 [[I]], label [[FOR_COND]] [
; CHECK-NEXT:    i32 2096, label [[IF_END:%.*]]
; CHECK-NEXT:    i32 2097, label [[IF_END]]
; CHECK-NEXT:    ]
; CHECK:       if.end:
; CHECK-NEXT:    [[I_LCSSA:%.*]] = phi i32 [ [[I]], [[FOR_COND]] ], [ [[I]], [[FOR_COND]] ]
; CHECK-NEXT:    ret i32 [[I_LCSSA]]
;
; TAILFOLD-LABEL: @multiple_exit_switch(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[FOR_COND:%.*]]
; TAILFOLD:       for.cond:
; TAILFOLD-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_COND]] ]
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; TAILFOLD-NEXT:    switch i32 [[I]], label [[FOR_COND]] [
; TAILFOLD-NEXT:    i32 2096, label [[IF_END:%.*]]
; TAILFOLD-NEXT:    i32 2097, label [[IF_END]]
; TAILFOLD-NEXT:    ]
; TAILFOLD:       if.end:
; TAILFOLD-NEXT:    [[I_LCSSA:%.*]] = phi i32 [ [[I]], [[FOR_COND]] ], [ [[I]], [[FOR_COND]] ]
; TAILFOLD-NEXT:    ret i32 [[I_LCSSA]]
;
entry:
  br label %for.cond

for.cond:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.cond ]
  %iprom = sext i32 %i to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %inc = add nsw i32 %i, 1
  switch i32 %i, label %for.cond [
  i32 2096, label %if.end
  i32 2097, label %if.end
  ]

if.end:
  ret i32 %i
}

; multiple exit case but with a switch as multiple exiting edges from
; a single block is a commonly missed edge case
define i32 @multiple_exit_switch2(i16* %p, i32 %n) {
; CHECK-LABEL: @multiple_exit_switch2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_COND]] ]
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    switch i32 [[I]], label [[FOR_COND]] [
; CHECK-NEXT:    i32 2096, label [[IF_END:%.*]]
; CHECK-NEXT:    i32 2097, label [[IF_END2:%.*]]
; CHECK-NEXT:    ]
; CHECK:       if.end:
; CHECK-NEXT:    ret i32 0
; CHECK:       if.end2:
; CHECK-NEXT:    ret i32 1
;
; TAILFOLD-LABEL: @multiple_exit_switch2(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[FOR_COND:%.*]]
; TAILFOLD:       for.cond:
; TAILFOLD-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_COND]] ]
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I]], 1
; TAILFOLD-NEXT:    switch i32 [[I]], label [[FOR_COND]] [
; TAILFOLD-NEXT:    i32 2096, label [[IF_END:%.*]]
; TAILFOLD-NEXT:    i32 2097, label [[IF_END2:%.*]]
; TAILFOLD-NEXT:    ]
; TAILFOLD:       if.end:
; TAILFOLD-NEXT:    ret i32 0
; TAILFOLD:       if.end2:
; TAILFOLD-NEXT:    ret i32 1
;
entry:
  br label %for.cond

for.cond:
  %i = phi i32 [ 0, %entry ], [ %inc, %for.cond ]
  %iprom = sext i32 %i to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %inc = add nsw i32 %i, 1
  switch i32 %i, label %for.cond [
  i32 2096, label %if.end
  i32 2097, label %if.end2
  ]

if.end:
  ret i32 0

if.end2:
  ret i32 1
}

define i32 @multiple_latch1(i16* %p) {
; CHECK-LABEL: @multiple_latch1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[I_02:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY_BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I_02]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[INC]], 16
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY_BACKEDGE]], label [[FOR_SECOND:%.*]]
; CHECK:       for.second:
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I_02]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[CMPS:%.*]] = icmp sgt i32 [[INC]], 16
; CHECK-NEXT:    br i1 [[CMPS]], label [[FOR_BODY_BACKEDGE]], label [[FOR_END:%.*]]
; CHECK:       for.body.backedge:
; CHECK-NEXT:    br label [[FOR_BODY]]
; CHECK:       for.end:
; CHECK-NEXT:    ret i32 0
;
; TAILFOLD-LABEL: @multiple_latch1(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[FOR_BODY:%.*]]
; TAILFOLD:       for.body:
; TAILFOLD-NEXT:    [[I_02:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY_BACKEDGE:%.*]] ]
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I_02]], 1
; TAILFOLD-NEXT:    [[CMP:%.*]] = icmp slt i32 [[INC]], 16
; TAILFOLD-NEXT:    br i1 [[CMP]], label [[FOR_BODY_BACKEDGE]], label [[FOR_SECOND:%.*]]
; TAILFOLD:       for.second:
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I_02]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[CMPS:%.*]] = icmp sgt i32 [[INC]], 16
; TAILFOLD-NEXT:    br i1 [[CMPS]], label [[FOR_BODY_BACKEDGE]], label [[FOR_END:%.*]]
; TAILFOLD:       for.body.backedge:
; TAILFOLD-NEXT:    br label [[FOR_BODY]]
; TAILFOLD:       for.end:
; TAILFOLD-NEXT:    ret i32 0
;
entry:
  br label %for.body

for.body:
  %i.02 = phi i32 [ 0, %entry ], [ %inc, %for.body.backedge]
  %inc = add nsw i32 %i.02, 1
  %cmp = icmp slt i32 %inc, 16
  br i1 %cmp, label %for.body.backedge, label %for.second

for.second:
  %iprom = sext i32 %i.02 to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %cmps = icmp sgt i32 %inc, 16
  br i1 %cmps, label %for.body.backedge, label %for.end

for.body.backedge:
  br label %for.body

for.end:
  ret i32 0
}


; two back branches - loop simplify with convert this to the same form
; as previous before vectorizer sees it, but show that.
define i32 @multiple_latch2(i16* %p) {
; CHECK-LABEL: @multiple_latch2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[I_02:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY_BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[INC]] = add nsw i32 [[I_02]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[INC]], 16
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY_BACKEDGE]], label [[FOR_SECOND:%.*]]
; CHECK:       for.body.backedge:
; CHECK-NEXT:    br label [[FOR_BODY]]
; CHECK:       for.second:
; CHECK-NEXT:    [[IPROM:%.*]] = sext i32 [[I_02]] to i64
; CHECK-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; CHECK-NEXT:    store i16 0, i16* [[B]], align 4
; CHECK-NEXT:    [[CMPS:%.*]] = icmp sgt i32 [[INC]], 16
; CHECK-NEXT:    br i1 [[CMPS]], label [[FOR_BODY_BACKEDGE]], label [[FOR_END:%.*]]
; CHECK:       for.end:
; CHECK-NEXT:    ret i32 0
;
; TAILFOLD-LABEL: @multiple_latch2(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[FOR_BODY:%.*]]
; TAILFOLD:       for.body:
; TAILFOLD-NEXT:    [[I_02:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_BODY_BACKEDGE:%.*]] ]
; TAILFOLD-NEXT:    [[INC]] = add nsw i32 [[I_02]], 1
; TAILFOLD-NEXT:    [[CMP:%.*]] = icmp slt i32 [[INC]], 16
; TAILFOLD-NEXT:    br i1 [[CMP]], label [[FOR_BODY_BACKEDGE]], label [[FOR_SECOND:%.*]]
; TAILFOLD:       for.body.backedge:
; TAILFOLD-NEXT:    br label [[FOR_BODY]]
; TAILFOLD:       for.second:
; TAILFOLD-NEXT:    [[IPROM:%.*]] = sext i32 [[I_02]] to i64
; TAILFOLD-NEXT:    [[B:%.*]] = getelementptr inbounds i16, i16* [[P:%.*]], i64 [[IPROM]]
; TAILFOLD-NEXT:    store i16 0, i16* [[B]], align 4
; TAILFOLD-NEXT:    [[CMPS:%.*]] = icmp sgt i32 [[INC]], 16
; TAILFOLD-NEXT:    br i1 [[CMPS]], label [[FOR_BODY_BACKEDGE]], label [[FOR_END:%.*]]
; TAILFOLD:       for.end:
; TAILFOLD-NEXT:    ret i32 0
;
entry:
  br label %for.body

for.body:
  %i.02 = phi i32 [ 0, %entry ], [ %inc, %for.body ], [%inc, %for.second]
  %inc = add nsw i32 %i.02, 1
  %cmp = icmp slt i32 %inc, 16
  br i1 %cmp, label %for.body, label %for.second

for.second:
  %iprom = sext i32 %i.02 to i64
  %b = getelementptr inbounds i16, i16* %p, i64 %iprom
  store i16 0, i16* %b, align 4
  %cmps = icmp sgt i32 %inc, 16
  br i1 %cmps, label %for.body, label %for.end

for.end:
  ret i32 0
}


; Check interaction between block predication and early exits.  We need the
; condition on the early exit to remain dead (i.e. not be used when forming
; the predicate mask).
define void @scalar_predication(float* %addr) {
; CHECK-LABEL: @scalar_predication(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[PRED_STORE_CONTINUE2:%.*]] ]
; CHECK-NEXT:    [[VEC_IND:%.*]] = phi <2 x i64> [ <i64 0, i64 1>, [[VECTOR_PH]] ], [ [[VEC_IND_NEXT:%.*]], [[PRED_STORE_CONTINUE2]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr float, float* [[ADDR:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr float, float* [[TMP1]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast float* [[TMP2]] to <2 x float>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <2 x float>, <2 x float>* [[TMP3]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = fcmp oeq <2 x float> [[WIDE_LOAD]], zeroinitializer
; CHECK-NEXT:    [[TMP5:%.*]] = xor <2 x i1> [[TMP4]], <i1 true, i1 true>
; CHECK-NEXT:    [[TMP6:%.*]] = extractelement <2 x i1> [[TMP5]], i32 0
; CHECK-NEXT:    br i1 [[TMP6]], label [[PRED_STORE_IF:%.*]], label [[PRED_STORE_CONTINUE:%.*]]
; CHECK:       pred.store.if:
; CHECK-NEXT:    store float 1.000000e+01, float* [[TMP1]], align 4
; CHECK-NEXT:    br label [[PRED_STORE_CONTINUE]]
; CHECK:       pred.store.continue:
; CHECK-NEXT:    [[TMP7:%.*]] = extractelement <2 x i1> [[TMP5]], i32 1
; CHECK-NEXT:    br i1 [[TMP7]], label [[PRED_STORE_IF1:%.*]], label [[PRED_STORE_CONTINUE2]]
; CHECK:       pred.store.if1:
; CHECK-NEXT:    [[TMP8:%.*]] = add i64 [[INDEX]], 1
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr float, float* [[ADDR]], i64 [[TMP8]]
; CHECK-NEXT:    store float 1.000000e+01, float* [[TMP9]], align 4
; CHECK-NEXT:    br label [[PRED_STORE_CONTINUE2]]
; CHECK:       pred.store.continue2:
; CHECK-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 2
; CHECK-NEXT:    [[VEC_IND_NEXT]] = add <2 x i64> [[VEC_IND]], <i64 2, i64 2>
; CHECK-NEXT:    [[TMP10:%.*]] = icmp eq i64 [[INDEX_NEXT]], 200
; CHECK-NEXT:    br i1 [[TMP10]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], [[LOOP8:!llvm.loop !.*]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 201, 200
; CHECK-NEXT:    br i1 [[CMP_N]], label [[EXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ 200, [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[LOOP_HEADER:%.*]]
; CHECK:       loop.header:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[IV_NEXT:%.*]], [[LOOP_LATCH:%.*]] ]
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr float, float* [[ADDR]], i64 [[IV]]
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[IV]], 200
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[EXIT]], label [[LOOP_BODY:%.*]]
; CHECK:       loop.body:
; CHECK-NEXT:    [[TMP11:%.*]] = load float, float* [[GEP]], align 4
; CHECK-NEXT:    [[PRED:%.*]] = fcmp oeq float [[TMP11]], 0.000000e+00
; CHECK-NEXT:    br i1 [[PRED]], label [[LOOP_LATCH]], label [[THEN:%.*]]
; CHECK:       then:
; CHECK-NEXT:    store float 1.000000e+01, float* [[GEP]], align 4
; CHECK-NEXT:    br label [[LOOP_LATCH]]
; CHECK:       loop.latch:
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    br label [[LOOP_HEADER]], [[LOOP9:!llvm.loop !.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
; TAILFOLD-LABEL: @scalar_predication(
; TAILFOLD-NEXT:  entry:
; TAILFOLD-NEXT:    br label [[LOOP_HEADER:%.*]]
; TAILFOLD:       loop.header:
; TAILFOLD-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP_LATCH:%.*]] ]
; TAILFOLD-NEXT:    [[GEP:%.*]] = getelementptr float, float* [[ADDR:%.*]], i64 [[IV]]
; TAILFOLD-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[IV]], 200
; TAILFOLD-NEXT:    br i1 [[EXITCOND_NOT]], label [[EXIT:%.*]], label [[LOOP_BODY:%.*]]
; TAILFOLD:       loop.body:
; TAILFOLD-NEXT:    [[TMP0:%.*]] = load float, float* [[GEP]], align 4
; TAILFOLD-NEXT:    [[PRED:%.*]] = fcmp oeq float [[TMP0]], 0.000000e+00
; TAILFOLD-NEXT:    br i1 [[PRED]], label [[LOOP_LATCH]], label [[THEN:%.*]]
; TAILFOLD:       then:
; TAILFOLD-NEXT:    store float 1.000000e+01, float* [[GEP]], align 4
; TAILFOLD-NEXT:    br label [[LOOP_LATCH]]
; TAILFOLD:       loop.latch:
; TAILFOLD-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; TAILFOLD-NEXT:    br label [[LOOP_HEADER]]
; TAILFOLD:       exit:
; TAILFOLD-NEXT:    ret void
;
entry:
  br label %loop.header

loop.header:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop.latch ]
  %gep = getelementptr float, float* %addr, i64 %iv
  %exitcond.not = icmp eq i64 %iv, 200
  br i1 %exitcond.not, label %exit, label %loop.body

loop.body:
  %0 = load float, float* %gep, align 4
  %pred = fcmp oeq float %0, 0.0
  br i1 %pred, label %loop.latch, label %then

then:
  store float 10.0, float* %gep, align 4
  br label %loop.latch

loop.latch:
  %iv.next = add nuw nsw i64 %iv, 1
  br label %loop.header

exit:
  ret void
}
