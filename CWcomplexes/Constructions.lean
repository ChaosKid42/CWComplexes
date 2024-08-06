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
    obtain ⟨I, hI⟩ := cellFrontier_subset (C := C) l i
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

instance CWComplex_disjointUnion (disjoint : Disjoint C D) : CWComplex (C ∪ D) where
  cell n := Sum (cell C n) (cell D n)
  map n i := match i with
    | Sum.inl x => map n x
    | Sum.inr x => map n x
  source_eq n i := by
    rcases i with i | i
    · exact source_eq n i
    · exact source_eq n i
  cont n i := by
    rcases i with i | i
    · exact cont n i
    · exact cont n i
  cont_symm n i := by
    rcases i with i | i
    · exact cont_symm n i
    · exact cont_symm n i
  pairwiseDisjoint' := by
    rw [PairwiseDisjoint, Set.Pairwise]
    simp only [mem_univ, ne_eq, forall_true_left]
    intro ⟨n, cn⟩ ⟨m, cm⟩ ne
    rcases cn with cn | cn
    rcases cm with cm | cm
    · have := pairwiseDisjoint (C := C)
      simp only [PairwiseDisjoint, Set.Pairwise, mem_univ, ne_eq, forall_true_left] at this
      have ne' : ¬({ fst := n, snd := cn } : (n : ℕ) × cell C n) = { fst := m, snd := cm } := by
        by_contra eq
        apply ne
        simp only [Sigma.mk.inj_iff] at *
        rcases eq with ⟨neqm, cnheqcm⟩
        constructor
        · exact neqm
        · subst neqm
          have := eq_of_heq cnheqcm
          subst this
          rfl
      exact @this ⟨n, cn⟩ ⟨m, cm⟩ ne'
    · simp [Function.onFun]
      exact Disjoint.mono (openCell_subset_complex n cn) (openCell_subset_complex m cm) disjoint
    rcases cm with cm | cm
    · simp only [Function.onFun]
      rw [disjoint_comm] at disjoint
      exact Disjoint.mono (openCell_subset_complex n cn) (openCell_subset_complex m cm) disjoint
    · have := pairwiseDisjoint (C := D)
      simp only [PairwiseDisjoint, Set.Pairwise, mem_univ, ne_eq, forall_true_left] at this
      have ne' : ¬({ fst := n, snd := cn } : (n : ℕ) × cell D n) = { fst := m, snd := cm } := by
        by_contra eq
        apply ne
        simp only [Sigma.mk.inj_iff] at *
        rcases eq with ⟨neqm, cnheqcm⟩
        constructor
        · exact neqm
        · subst neqm
          have := eq_of_heq cnheqcm
          subst this
          rfl
      exact @this ⟨n, cn⟩ ⟨m, cm⟩ ne'
  mapsto n i := by
    rcases i with ic | id
    · rcases mapsto n ic with ⟨I, hI⟩
      classical
      let J : (m : ℕ) → Finset (cell C m ⊕ cell D m) :=
        fun (m : ℕ) ↦ Finset.image (fun j ↦ .inl j) (I m)
      use J
      rw [mapsTo'] at *
      simp only [J]
      intro x xmem
      apply hI at xmem
      simp only [mem_iUnion, exists_prop] at *
      rcases xmem with ⟨i, ⟨iltn, ⟨j, ⟨jmem, xmem⟩⟩⟩⟩
      use i
      simp only [iltn, exists_exists_and_eq_and, true_and]
      use .inl j
      simp only [Finset.mem_image, Sum.inl.injEq, exists_eq_right, jmem, true_and, xmem]
    · rcases mapsto n id with ⟨I, hI⟩
      classical
      let J : (m : ℕ) → Finset (cell C m ⊕ cell D m) :=
        fun (m : ℕ) ↦ Finset.image (fun j ↦ .inr j) (I m)
      use J
      rw [mapsTo'] at *
      simp only [J]
      intro x xmem
      apply hI at xmem
      simp only [mem_iUnion, exists_prop] at *
      rcases xmem with ⟨i, ⟨iltn, ⟨j, ⟨jmem, xmem⟩⟩⟩⟩
      use i
      simp only [iltn, exists_exists_and_eq_and, true_and]
      use .inr j
      simp only [Finset.mem_image, Sum.inr.injEq, exists_eq_right, jmem, true_and, xmem]
  closed' A := by
    intro asubcd
    constructor
    · intro closedA n j
      apply IsClosed.inter closedA
      rcases j with j | j
      · exact isClosed_closedCell
      · exact isClosed_closedCell
    · intro h
      have : A = (A ∩ C) ∪ (A ∩ D) := by
        calc
        A = A ∩ (C ∪ A) := (inter_eq_left.2 subset_union_right).symm
        _ = (A ∪ A ∩ D) ∩ (C ∪ A ∩ D) := by
          have h1 : A ∪ A ∩ D = A := union_eq_left.2 Set.inter_subset_left
          have h2 : C ∪ A ∩ D = C ∪ A := by
            rw [union_inter_distrib_left, inter_eq_left]
            apply Set.union_subset subset_union_left asubcd
          rw [h1, h2]
        _ = (A ∩ C) ∪ (A ∩ D) := by rw [inter_union_distrib_right]
      rw [this]
      apply IsClosed.union
      · rw [closed' (A ∩ C) inter_subset_right]
        intro n j
        have := h n (Sum.inl j)
        simp at this
        rw [inter_right_comm]
        apply IsClosed.inter this isClosed
      · rw [closed' (A ∩ D) inter_subset_right]
        intro n j
        have := h n (Sum.inr j)
        simp at this
        rw [inter_right_comm]
        apply IsClosed.inter this isClosed
  union' := by
    simp_rw [← union (C := C), ← union (C := D), ← Set.iUnion_union_distrib]
    apply Set.iUnion_congr
    intro n
    ext x
    constructor
    · intro h
      rw [mem_iUnion] at h
      rcases h with ⟨i, hi⟩
      rcases i with i | i
      · simp only at hi
        left
        rw [mem_iUnion]
        use i
        exact hi
      · simp only at hi
        right
        rw [mem_iUnion]
        use i
        exact hi
    · intro h
      rcases h with h | h
      · rw [mem_iUnion] at *
        rcases h with ⟨i, hi⟩
        use Sum.inl i
        exact hi
      · rw [mem_iUnion] at *
        rcases h with ⟨i, hi⟩
        use Sum.inr i
        exact hi

end
