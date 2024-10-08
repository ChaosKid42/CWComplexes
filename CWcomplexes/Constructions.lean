import CWcomplexes.Definition
import Mathlib.Analysis.NormedSpace.Real

set_option autoImplicit false
set_option linter.unusedVariables false
noncomputable section

open Metric Set

namespace CWComplex

variable {X : Type*} [t : TopologicalSpace X] [T2Space X] (C : Set X) [CWComplex C]

section

instance CWComplex_levelaux (n : ℕ∞) : CWComplex (levelaux C n) where
  cell l := {x : cell C l // l < n}
  map l i := map (C := C) l i
  source_eq l i:= source_eq (C := C) l i
  cont l i := cont (C := C) l i
  cont_symm l i := cont_symm (C := C) l i
  pairwiseDisjoint' := by
    simp_rw [PairwiseDisjoint, Set.Pairwise, Function.onFun, disjoint_iff_inter_eq_empty]
    intro ⟨a, ja, _⟩ _ ⟨b, jb, map_mk⟩ _ ne
    exact disjoint_openCell_of_ne (by aesop)
  mapsto := by
    intro l ⟨i, lltn⟩
    obtain ⟨I, hI⟩ := cellFrontier_subset_finite_closedCell (C := C) l i
    use fun (m : ℕ) ↦ (I m).subtype (fun j ↦ m < n)
    simp_rw [mapsTo', iUnion_subtype]
    apply subset_trans hI (iUnion_mono fun m ↦ iUnion_mono fun mltl ↦ iUnion_mono fun j ↦ ?_ )
    simp_all only [(ENat.coe_lt_of_lt mltl).trans lltn, Finset.mem_subtype, iUnion_true,
      iUnion_subset_iff]
    exact fun _ ↦ by rfl
  closed' A asublevel := by
    have : A ⊆ C := by
      apply asublevel.trans
      simp_rw [← levelaux_top]
      exact levelaux_mono le_top
    refine ⟨fun _ _ _ ↦ by simp only [(closed' A this).1], ?_⟩
    intro h
    simp_rw [Subtype.forall] at h
    apply strong_induction_isClosed this
    intro m _ j
    by_cases mlt : m < n
    · exact Or.intro_right _ (h m j mlt)
    left
    push_neg at mlt
    rw [← inter_eq_left.2 asublevel, inter_assoc, levelaux_inter_openCell_eq_empty mlt, inter_empty]
    exact isClosed_empty
  union' := by
    apply iUnion_congr fun m ↦ ?_
    rw [iUnion_subtype, iUnion_comm]
    rfl

instance CWComplex_level (n : ℕ∞) : CWComplex (level C n) := CWComplex_levelaux _ _

variable {D : Set X} [CWComplex D]

def CWComplex_disjointUnion (disjoint : Disjoint C D) : CWComplex (C ∪ D) where
  cell n := Sum (cell C n) (cell D n)
  map n := Sum.elim (map (C := C) n) (map (C := D) n)
  source_eq n i := match i with
    | Sum.inl x => source_eq n x
    | Sum.inr x => source_eq n x
  cont n i := match i with -- should something like this be a lemma?
    | Sum.inl x => cont n x
    | Sum.inr x => cont n x
  cont_symm n i := match i with
    | Sum.inl x => cont_symm n x
    | Sum.inr x => cont_symm n x
  pairwiseDisjoint' := by
    simp_rw [PairwiseDisjoint, Set.Pairwise, Function.onFun, disjoint_iff_inter_eq_empty]
    intro ⟨n, cn⟩ _ ⟨m, cm⟩ _ ne
    rcases cn with cn | cn
    rcases cm with cm | cm
    · exact disjoint_openCell_of_ne (by aesop)
    · exact subset_eq_empty (inter_subset_inter (openCell_subset_complex n cn)
        (openCell_subset_complex m cm)) (disjoint_iff_inter_eq_empty.1 disjoint)
    rcases cm with cm | cm
    · exact subset_eq_empty (inter_subset_inter (openCell_subset_complex n cn)
        (openCell_subset_complex m cm)) (disjoint_iff_inter_eq_empty.1 (disjoint_comm.1 disjoint))
    · exact disjoint_openCell_of_ne (by aesop)
  mapsto n i := by
    classical
    rcases i with ic | id
    · obtain ⟨I, hI⟩ := cellFrontier_subset_finite_closedCell n ic
      use fun m ↦ (I m).image Sum.inl
      rw [mapsTo']
      apply hI.trans
      simp only [Finset.mem_image, iUnion_exists, biUnion_and', iUnion_iUnion_eq_right]
      rfl
    · obtain ⟨I, hI⟩ := cellFrontier_subset_finite_closedCell n id
      use fun m ↦ (I m).image Sum.inr
      rw [mapsTo']
      apply hI.trans
      simp only [Finset.mem_image, iUnion_exists, biUnion_and', iUnion_iUnion_eq_right]
      rfl
  closed' A asubcd := by
    constructor
    · intro closedA n j
      rcases j with j | j
      · exact closedA.inter isClosed_closedCell
      · exact closedA.inter isClosed_closedCell
    · intro h
      suffices IsClosed ((A ∩ C) ∪ (A ∩ D)) by
        convert this using 1
        simp only [union_inter_distrib_left, union_eq_right.2 inter_subset_left,
          inter_union_distrib_right, left_eq_inter, subset_inter_iff, subset_union_left, asubcd,
          and_self]
      apply IsClosed.union
      · rw [closed (A ∩ C) inter_subset_right]
        intro n j
        rw [inter_right_comm]
        exact (h n (Sum.inl j)).inter isClosed
      · rw [closed (A ∩ D) inter_subset_right]
        intro n j
        rw [inter_right_comm]
        exact (h n (Sum.inr j)).inter isClosed
  union' := by
    simp_rw [← union (C := C), ← union (C := D), ← iUnion_union_distrib, iUnion_sum]
    rfl

example (P Q : ℕ → Prop) (h : ∀ n, P n ↔ Q n) : (∀ n, P n) ↔ (∀ n, Q n) := by
  exact forall_congr' h

end

-- it is a litlle bit weird that this now depends on the universe level,
-- not sure this should be like this ...
def CWComplex_of_Homeomorph.{u} {X Y : Type  u} [TopologicalSpace X] [TopologicalSpace Y]
    (C : Set X) (D : Set Y) [CWComplex C] (f : X ≃ₜ Y) (imf : f '' C = D) :
    CWComplex D where
  cell := cell C
  map n i := (map (C := C) n i).transEquiv f
  source_eq n i := by simp [PartialEquiv.transEquiv, source_eq (C := C) n i]
  cont n i := by simp [PartialEquiv.transEquiv_eq_trans, cont (C := C) n i]
  cont_symm n i := by
    simp only [PartialEquiv.transEquiv_eq_trans, PartialEquiv.trans_target,
      Equiv.toPartialEquiv_symm_apply, ← image_equiv_eq_preimage_symm]
    apply ContinuousOn.image_comp_continuous f.continuous_invFun
    simp [Equiv.invFun_as_coe, Homeomorph.coe_symm_toEquiv, Set.image_image, cont_symm (C := C)]
  pairwiseDisjoint' := by
    have := pairwiseDisjoint' (C := C)
    simp only [PairwiseDisjoint, Set.Pairwise, mem_univ, ne_eq, Function.onFun,
      PartialEquiv.transEquiv_apply, EquivLike.coe_coe, ← image_image] at this ⊢
    intro ⟨n, j⟩ _ ⟨m, i⟩ _ ne
    exact disjoint_image_of_injective f.injective
      (this (x := ⟨n, j⟩) trivial (y := ⟨m, i⟩) trivial ne)
  mapsto n i := by
    obtain ⟨I, hI⟩ := mapsto (C := C) n i
    use I
    rw [mapsTo'] at hI ⊢
    simp only [PartialEquiv.transEquiv_apply, EquivLike.coe_coe, ← image_image, ←
      image_iUnion (f := f)]
    exact image_mono hI
  closed' A AsubD := by
    have preAsubC : f ⁻¹' A ⊆ C := by
      simp only [← Homeomorph.image_symm, image_subset_iff, Homeomorph.symm_symm, imf, AsubD]
    calc
      IsClosed A
      _ ↔ IsClosed (f ⁻¹' A) := f.isClosed_preimage.symm
      _ ↔ ∀ n (j : cell C n), IsClosed ((f ⁻¹' A) ∩ map n j '' closedBall 0 1) := by
        rw [closed' (C := C) (f ⁻¹' A) preAsubC]
      _ ↔ ∀ n (j : cell C n),
          IsClosed (A ∩ ↑((fun n i => (map n i).transEquiv ↑f) n j) '' closedBall 0 1) := by
        apply forall_congr' fun n ↦ forall_congr' fun j ↦ ?_
        simp only [PartialEquiv.transEquiv_apply, EquivLike.coe_coe, ← image_image]
        nth_rw 2 [← f.image_preimage A]
        simp only [← image_inter f.injective]
        exact f.isClosed_image.symm
  union' := by simp [← image_image, ← image_iUnion (f := f), union' (C := C), imf]
