import CWcomplexes.Constructions

open Metric Set

variable {X : Type*} [t : TopologicalSpace X] [T2Space X] {C : Set X} (hC : CWComplex C)


namespace CWComplex


lemma isClosed_level (n : ℕ∞) : IsClosed (hC.level n) := (hC.CWComplex_level n).isClosed

lemma isClosed_levelaux (n : ℕ∞) : IsClosed (hC.levelaux n) := by
  by_cases nzero : n = 0
  · rw [nzero, hC.levelaux_zero_eq_empty]
    exact isClosed_empty
  · push_neg at nzero
    rw [hC.levelaux_eq_level_sub_one nzero]
    exact hC.isClosed_level (n - 1)

lemma closed_iff_inter_levelaux_closed (A : Set X) (asubc : A ⊆ C) : IsClosed A ↔ ∀ (n : ℕ), IsClosed (A ∩ hC.levelaux n) := by
  constructor
  · intro closedA n
    exact IsClosed.inter closedA (hC.isClosed_levelaux n)
  · intro h
    rw [hC.closed A asubc]
    intro n j
    have : ↑(hC.map n j) '' closedBall 0 1 = hC.levelaux (n + 1) ∩ ↑(hC.map n j) '' closedBall 0 1 := by
      exact (Set.inter_eq_right.2 (hC.map_closedBall_subset_levelaux n j)).symm
    rw [this, ← inter_assoc]
    exact IsClosed.inter (h (n + 1)) (hC.isClosed_map_closedBall n j)

lemma inter_levelaux_succ_closed_iff_inter_levelaux_closed_and_inter_closedBall_closed (A : Set X) : IsClosed (A ∩ hC.levelaux (Nat.succ n)) ↔ IsClosed (A ∩ hC.levelaux n) ∧ ∀ (j : hC.cell n), IsClosed (A ∩ hC.map n j '' closedBall 0 1) := by
  constructor
  · intro closed
    constructor
    · have : A ∩ levelaux hC n = (A ∩ levelaux hC ↑(Nat.succ n)) ∩ levelaux hC n := by
        rw [inter_assoc]
        congr
        rw [inter_eq_right.2 (hC.levelaux_subset_levelaux_of_le (by norm_cast; exact Nat.le_succ n))]
      rw [this]
      exact IsClosed.inter closed (hC.isClosed_levelaux n)
    · intro j
      have : A ∩ levelaux hC ↑(Nat.succ n) ⊆ C := by
        apply subset_trans inter_subset_right
        simp_rw [← hC.levelaux_top]
        exact hC.levelaux_subset_levelaux_of_le le_top
      rw [hC.closed (A ∩ levelaux hC ↑(Nat.succ n)) this] at closed
      replace closed := closed n j
      rw [inter_assoc, Nat.succ_eq_add_one, Nat.cast_add, Nat.cast_one, inter_eq_right.2 (hC.map_closedBall_subset_levelaux n j)] at closed
      exact closed
  · intro ⟨closed1, closed2⟩
    have : A ∩ levelaux hC ↑(Nat.succ n) ⊆ C := by
      apply subset_trans inter_subset_right
      simp_rw [← hC.levelaux_top]
      exact hC.levelaux_subset_levelaux_of_le le_top
    rw [hC.closed (A ∩ levelaux hC ↑(Nat.succ n)) this]
    intro m j
    induction' m using Nat.case_strong_induction_on with m hm
    · simp [Matrix.empty_eq, isClosed_inter_singleton]
    by_cases msuccltn : Nat.succ m < n
    · have : ↑(hC.map (Nat.succ m) j) '' closedBall 0 1 ⊆ levelaux hC ↑n := by
        refine subset_trans (hC.map_closedBall_subset_levelaux _ _) (hC.levelaux_subset_levelaux_of_le ?_)
        norm_cast
      have : A ∩ levelaux hC ↑(Nat.succ n) ∩ ↑(hC.map (Nat.succ m) j) '' closedBall 0 1 = A ∩ levelaux hC ↑n ∩ ↑(hC.map (Nat.succ m) j) '' closedBall 0 1 := by
        rw [inter_assoc, inter_assoc]
        congrm A ∩ ?_
        rw [inter_eq_right.2 this]
        have : ↑(hC.map (Nat.succ m) j) '' closedBall 0 1 ⊆ levelaux hC ↑(Nat.succ n) := subset_trans this (hC.levelaux_subset_levelaux_of_le (by norm_cast; exact Nat.le_succ n))
        rw [inter_eq_right.2 this]
      rw [this]
      exact IsClosed.inter closed1 (hC.isClosed_map_closedBall _ _)
    by_cases msucceqn : Nat.succ m = n
    · subst msucceqn
      rw [inter_assoc, inter_comm (levelaux hC ↑(Nat.succ (Nat.succ m))), ← inter_assoc]
      exact IsClosed.inter (closed2 _) (hC.isClosed_levelaux _)
    have : Nat.succ n ≤ Nat.succ m := by
      push_neg at msuccltn msucceqn
      exact LE.le.lt_of_ne msuccltn msucceqn.symm
    rw [inter_assoc, hC.levelaux_inter_image_closedBall_eq_levelaux_inter_image_sphere (by norm_cast), ← inter_assoc]
    exact hC.isClosed_inter_sphere_succ_of_le_isClosed_inter_closedBall hm _

/- The following is one way of stating that `level 0` is discrete. -/
lemma isDiscrete_level_zero {A : Set X} : IsClosed (A ∩ hC.level 0) := by
  rw [hC.closed (A ∩ hC.level 0) (subset_trans Set.inter_subset_right (by simp_rw [← hC.level_top]; apply hC.level_subset_level_of_le le_top))]
  intro n
  induction' n using Nat.case_strong_induction_on with n hn
  · intro j
    have := Set.inter_eq_right.2 (hC.map_closedBall_subset_level 0 j)
    norm_cast at this
    rw [inter_assoc, this]
    have : ↑(hC.map 0 j) '' closedBall 0 1 = {(hC.map 0 j) ![]} := by
      ext x
      constructor
      · intro h
        rw [mem_image] at h
        rcases h with ⟨y, _, mapy⟩
        have : y = ![] := by simp [Matrix.empty_eq]
        rw [this] at mapy
        simp only [mapy, mem_singleton_iff]
      · intro h
        rw [h]
        apply Set.mem_image_of_mem
        simp only [Matrix.zero_empty, mem_closedBall, dist_self, zero_le_one]
    rw [this]
    by_cases h : {(hC.map 0 j) ![]} ⊆ A
    · rw [inter_eq_right.2 h]
      exact isClosed_singleton
    · simp at h
      have : A ∩ {(hC.map 0 j) ![]} = ∅ := by
        simp only [inter_singleton_eq_empty, h, not_false_eq_true]
      rw [this]
      exact isClosed_empty
  · rw [← Nat.add_one]
    intro j
    rw [inter_assoc, hC.level_inter_image_closedBall_eq_level_inter_image_sphere (by norm_cast; exact Nat.zero_lt_succ n), ← inter_assoc]
    exact hC.isClosed_inter_sphere_succ_of_le_isClosed_inter_closedBall hn j

lemma compact_inter_finite (A : t.Compacts) : _root_.Finite (Σ (m : ℕ), {j : hC.cell m // ¬ Disjoint A.1 (↑(hC.map m j) '' ball 0 1)}) := by
  by_contra h
  simp only [TopologicalSpace.Compacts.carrier_eq_coe, not_disjoint_iff, SetLike.mem_coe,
    not_finite_iff_infinite] at h
  let p (m : Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 }) :=
    Classical.choose (m.2).2
  have : Set.InjOn p (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 })) := by
    rw [InjOn]
    intro ⟨m, j, hj⟩ _ ⟨n, i, hi⟩ nimem peqp
    have hpj : p ⟨m, j, hj⟩ ∈ ↑(hC.map m j) '' ball 0 1 := by simp only [p, (Classical.choose_spec hj).2]
    have hpi : p ⟨m, j, hj⟩ ∈ ↑(hC.map n i) '' ball 0 1 := by
      rw [peqp]
      simp only [p, (Classical.choose_spec hi).2]
    have : ¬ Disjoint (↑(hC.map m j) '' ball 0 1) (↑(hC.map n i) '' ball 0 1) := by
      rw [Set.not_disjoint_iff]
      use p ⟨m, j, hj⟩
    have := hC.not_disjoint_equal this
    simp at this
    rcases this with ⟨meqn, jeqi⟩
    subst meqn
    simp only [heq_eq_eq] at jeqi
    subst jeqi
    rfl
  have infuniv : Set.Infinite (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 })) := by
    rw [infinite_univ_iff]
    exact h
  have infpoints := Set.Infinite.image this infuniv
  have subsetsclosed : ∀ (s : Set (p '' (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 })))), IsClosed (s : Set X) := by
    intro s
    have ssubc : ↑↑s ⊆ ↑C := by
      have ssub := Subtype.coe_image_subset ↑(p '' univ) s
      have subc : p '' univ ⊆ C := by
        intro x xmem
        simp only [image_univ, mem_range, Sigma.exists, Subtype.exists] at xmem
        rcases xmem with ⟨m, j, h', h⟩
        simp only [← hC.union, mem_iUnion]
        use m
        use j
        simp only [p] at h
        have := (Classical.choose_spec h').2
        rw [h] at this
        exact hC.map_ball_subset_map_closedball this
      exact subset_trans ssub subc
    rw [hC.closed_iff_inter_levelaux_closed s ssubc]
    intro n
    induction' n using Nat.case_strong_induction_on with n hn
    · rw [Nat.cast_zero, hC.levelaux_zero_eq_empty, inter_empty]
      exact isClosed_empty
    rw [hC.inter_levelaux_succ_closed_iff_inter_levelaux_closed_and_inter_closedBall_closed _]
    constructor
    · exact hn n (le_refl _)
    intro j
    simp_rw [← Metric.sphere_union_ball, image_union, inter_union_distrib_left]
    apply IsClosed.union
    · have : ↑(hC.map n j) '' sphere 0 1 ⊆ hC.levelaux n := by
        rcases hC.mapsto n j with ⟨I, hI⟩
        rw [mapsTo'] at hI
        apply subset_trans hI
        intro x xmem
        unfold levelaux
        simp only [mem_iUnion] at xmem ⊢
        rcases xmem with ⟨m, mlt, i, _, xmem⟩
        use m, (by norm_num; exact mlt), i
      have :  Subtype.val '' s ∩ ↑(hC.map n j) '' sphere 0 1 = Subtype.val '' s ∩ hC.levelaux n ∩ ↑(hC.map n j) '' sphere 0 1 := by
        rw [inter_assoc, inter_eq_right.2 this]
      rw [this]
      exact IsClosed.inter (hn n (le_refl _)) (hC.isClosed_map_sphere)
    · by_cases empty : Subtype.val '' s ∩ ↑(hC.map n j) '' ball 0 1 = ∅
      · rw [empty]
        exact isClosed_empty
      rw [eq_empty_iff_forall_not_mem, not_forall_not] at empty
      rcases empty with ⟨x, xmems, xmemball⟩
      have ssubp : Subtype.val '' s ⊆ p '' (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 })) := by
        intro a amem
        simp only [mem_image] at amem
        rcases amem with ⟨b, _, beq⟩
        rw [← beq]
        exact b.2
      have : x ∈ (p '' (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 }))) := ssubp xmems
      simp only [mem_image, p] at this
      rcases this with ⟨⟨y1, y2, yprop⟩, ymem, eq⟩
      have xprop := Classical.choose_spec yprop
      rw [eq] at xprop
      have : ¬ Disjoint (↑(hC.map y1 y2) '' ball 0 1) (↑(hC.map n j) '' ball 0 1) := by
        rw [not_disjoint_iff]
        use x
        exact ⟨xprop.2, xmemball⟩
      have := hC.not_disjoint_equal this
      simp at this
      rcases this with ⟨h1, h2⟩
      subst y1
      simp at h2
      subst y2
      have : Subtype.val '' s ∩ ↑(hC.map n j) '' ball 0 1 = {x} := by
        apply subset_antisymm
        · intro x' ⟨x'mems, x'memball⟩
          simp only [mem_singleton_iff]
          have : x' ∈ (p '' (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 }))) := ssubp x'mems
          simp only [mem_image, p] at this
          rcases this with ⟨⟨y'1, y'2, y'prop⟩, y'mem, eq'⟩
          have x'prop := Classical.choose_spec y'prop
          rw [eq'] at x'prop
          have : ¬ Disjoint (↑(hC.map y'1 y'2) '' ball 0 1) (↑(hC.map n j) '' ball 0 1) := by
            rw [not_disjoint_iff]
            use x'
            exact ⟨x'prop.2, x'memball⟩
          have := hC.not_disjoint_equal this
          simp at this
          rcases this with ⟨h1, h2⟩
          subst y'1
          simp at h2
          subst y'2
          rw [← eq, ← eq']
        · simp only [subset_inter_iff, singleton_subset_iff, xmems, xmemball, and_self]
      rw [this]
      exact isClosed_singleton
  have discrete : DiscreteTopology ↑(p '' (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 }))) := by
    simp [discreteTopology_iff_forall_isClosed]
    intro s
    simp [instTopologicalSpaceSubtype, isClosed_induced_iff]
    use s
    simp [Subtype.val_injective]
    exact subsetsclosed s
  have closed: IsClosed (p '' (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 }))) := by
    have := subsetsclosed (univ : Set (p '' (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 }))))
    rw [Subtype.coe_image_univ] at this
    exact this
  have subsetA : (p '' (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 }))) ⊆ A.1 := by
    intro x xmem
    simp only [mem_image, image_univ, mem_range, Sigma.exists, Subtype.exists, p] at xmem
    rcases xmem with ⟨n, j, hj, hjj⟩
    have := Classical.choose_spec hj
    rw [← hjj]
    exact this.1
  have compact : IsCompact (p '' (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 }))) := by
    exact IsCompact.of_isClosed_subset A.2 closed subsetA
  have finite : Set.Finite (p '' (univ : Set (Σ (m : ℕ), { j // ∃ x ∈ A, x ∈ ↑(hC.map m j) '' ball 0 1 }))) := by
    exact IsCompact.finite compact discrete
  contradiction

lemma compact_inter_finite_subset (A : t.Compacts) {I : (n : ℕ) → Set (hC.cell n)} : _root_.Finite (Σ (m : ℕ), {j : I m // ¬ Disjoint A.1 (↑(hC.map m j) '' ball 0 1)}) := by
  let f := fun (x : Σ (m : ℕ), {j : I m // ¬ Disjoint A.1 (↑(hC.map m j) '' ball 0 1)}) ↦ (⟨x.1, ⟨x.2.1, x.2.2⟩⟩ : Σ (m : ℕ), {j : hC.cell m // ¬ Disjoint A.1 (↑(hC.map m j) '' ball 0 1)})
  apply @Finite.of_injective _ _ (hC.compact_inter_finite A) f
  unfold Function.Injective
  intro ⟨x1, x2, x3⟩ ⟨y1, y2, y3⟩ eq
  simp [f] at eq
  rcases eq with ⟨rfl, eq⟩
  simp only [heq_eq_eq, Subtype.mk.injEq, Subtype.val_inj] at eq
  simp_rw [eq]

lemma compact_inter_finite' (A : t.Compacts) : _root_.Finite { x : Σ (n : ℕ), hC.cell n // ¬Disjoint A.1 (hC.map x.fst x.snd '' ball 0 1)} := by
  let f := fun (x : (Σ (m : ℕ), {j : hC.cell m // ¬ Disjoint A.1 (↑(hC.map m j) '' ball 0 1)})) ↦ (⟨⟨x.1, x.2.1⟩, x.2.2⟩ : { x : Σ (n : ℕ), hC.cell n // ¬Disjoint A.1 (hC.map x.fst x.snd '' ball 0 1)})
  apply @Finite.of_surjective _ _ (hC.compact_inter_finite A) f
  unfold Function.Surjective
  intro x
  use ⟨x.1.1, ⟨x.1.2, x.2⟩⟩

lemma compact_inter_finite_subset' (A : t.Compacts) {I : (n : ℕ) → Set (hC.cell n)} : _root_.Finite {x : Σ (n : ℕ), I n // ¬Disjoint A.1 (hC.map x.fst x.snd '' ball 0 1)} := by
  let f := fun (x : {x : Σ (n : ℕ), I n // ¬Disjoint A.1 (hC.map x.fst x.snd '' ball 0 1)}) ↦ (⟨⟨x.1.1, x.1.2⟩, x.2⟩ : {x : Σ (n : ℕ), hC.cell n // ¬Disjoint A.1 (hC.map x.fst x.snd '' ball 0 1)})
  apply @Finite.of_injective _ _ (hC.compact_inter_finite' A) f
  unfold Function.Injective
  intro ⟨⟨x1, x2⟩, x3⟩ ⟨⟨y1, y2⟩, y3⟩ eq
  simp [f] at eq
  rcases eq with ⟨rfl, eq⟩
  simp only [heq_eq_eq, Subtype.mk.injEq, Subtype.val_inj] at eq
  simp_rw [eq]

lemma subset_not_disjoint (A : Set X) : A ∩ C ⊆ ⋃ (x : Σ (m : ℕ), {j : hC.cell m // ¬ Disjoint A (hC.map m j '' ball 0 1)}), hC.map x.1 x.2 '' closedBall 0 1 := by
  intro x ⟨xmem1, xmem2⟩
  simp only [mem_iUnion]
  simp only [← hC.union', mem_iUnion] at xmem2
  rcases xmem2 with ⟨m, j, hmj⟩
  use ⟨m, j, not_disjoint_iff.2 ⟨x, xmem1, hmj⟩⟩
  exact hC.map_ball_subset_map_closedball hmj

lemma subset_not_disjoint' (A : Set X) : A ∩ C ⊆ ⋃ (x : Σ (m : ℕ), {j : hC.cell m // ¬ Disjoint A (hC.map m j '' ball 0 1)}), hC.map x.1 x.2 '' ball 0 1 := by
  intro x ⟨xmem1, xmem2⟩
  simp only [mem_iUnion]
  simp only [← hC.union', mem_iUnion] at xmem2
  rcases xmem2 with ⟨m, j, hmj⟩
  use ⟨m, j, not_disjoint_iff.2 ⟨x, xmem1, hmj⟩⟩

/- See "Topologie" p. 120 by Klaus Jänich from 2001 -/
def Subcomplex'' (E : Set X) (I : Π n, Set (hC.cell n))
    (mapsto : ∀ (n : ℕ) (i : I n), MapsTo (hC.map n i) (closedBall 0 1) E)
    (union : E = ⋃ (n : ℕ) (j : I n), hC.map n j '' ball 0 1): hC.Subcomplex E where
  I := I
  closed := by
    have EsubC : E ⊆ C := by
      simp_rw [union, ← hC.union']
      apply iUnion_mono
      intro n
      apply iUnion_subset
      intro i
      apply subset_iUnion_of_subset ↑i
      rfl
    rw [hC.closed E EsubC]
    intro n j
    have : E ∩ ↑(hC.map n j) '' closedBall 0 1 =
        (⋃ (x : {x : Σ (n : ℕ), I n // ¬ Disjoint (hC.map n j '' closedBall 0 1) (hC.map x.1 x.2 '' ball 0 1)}),
        hC.map x.1.1 x.1.2 '' ball 0 1) ∩ ↑(hC.map n j) '' closedBall 0 1 := by
      rw [union]
      apply subset_antisymm
      · simp_rw [iUnion_inter]
        apply iUnion_subset
        intro m
        apply iUnion_subset
        intro i
        by_cases h : Disjoint (hC.map n j '' closedBall 0 1) (hC.map m i '' ball 0 1)
        · rw [disjoint_iff_inter_eq_empty, inter_comm] at h
          rw [h]
          exact empty_subset _
        · apply subset_iUnion_of_subset ⟨⟨m, i⟩, h⟩
          rfl
      · apply inter_subset_inter_left
        apply iUnion_subset
        intro x
        apply subset_iUnion_of_subset x.1.1
        apply subset_iUnion_of_subset x.1.2
        rfl
    rw [this]
    have : (⋃ (x : {x : Σ (n : ℕ), I n // ¬ Disjoint (hC.map n j '' closedBall 0 1) (hC.map x.1 x.2 '' ball 0 1)}),
        hC.map x.1.1 x.1.2 '' ball 0 1) ∩ ↑(hC.map n j) '' closedBall 0 1 =
        (⋃ (x : {x : Σ (n : ℕ), I n // ¬ Disjoint (hC.map n j '' closedBall 0 1) (hC.map x.1 x.2 '' ball 0 1)}),
        hC.map x.1.1 x.1.2 '' closedBall 0 1) ∩ ↑(hC.map n j) '' closedBall 0 1 := by
      apply subset_antisymm
      · apply inter_subset_inter_left
        apply iUnion_mono
        intro _
        exact hC.map_ball_subset_map_closedball
      · rw [← this]
        apply inter_subset_inter_left
        apply iUnion_subset
        intro x
        replace mapsto:= mapsto x.1.1 x.1.2
        rw [mapsTo'] at mapsto
        exact mapsto
    rw [this]
    apply IsClosed.inter _ (hC.isClosed_map_closedBall n j)
    apply @isClosed_iUnion_of_finite _ _ _ (hC.compact_inter_finite_subset' ⟨(hC.map n j '' closedBall 0 1), by exact hC.isCompact_map_closedBall n j⟩)
    intro _
    exact hC.isClosed_map_closedBall _ _
  union := union

lemma iUnion_cells_inter_compact (A : t.Compacts) (I : (n : ℕ) →  Set (hC.cell n)) :
    ∃ (p : (n : ℕ) → I n → Prop), _root_.Finite (Σ (n : ℕ), {i : I n // p n i}) ∧  (⋃ (n : ℕ) (i : I n), hC.map n i '' ball 0 1) ∩ A.1 =
    (⋃ (n : ℕ) (i : {i : I n// p n i}), hC.map n i '' ball 0 1) ∩ A.1 := by
  use fun (n : ℕ) (i : I n) ↦ ¬ Disjoint A.1 (↑(hC.map n i) '' ball 0 1)
  refine ⟨hC.compact_inter_finite_subset _, ?_⟩
  calc
    (⋃ n, ⋃ (i : ↑(I n)), ↑(hC.map n ↑i) '' ball 0 1) ∩ A.1 = (⋃ n, ⋃ (i : I n), ↑(hC.map n ↑i) '' ball 0 1) ∩ C ∩ A.1 := by
      congr
      symm
      simp_rw [Set.inter_eq_left, ← hC.union']
      apply Set.iUnion_mono''
      intro n x
      rw [mem_iUnion, mem_iUnion]
      intro ⟨i, _⟩
      use i
    _ = (⋃ n, ⋃ (i : I n), ↑(hC.map n ↑i) '' ball 0 1) ∩ (A.1 ∩ C) := by
      rw [inter_assoc, inter_comm C]
     _ = (⋃ n, ⋃ (i : I n), ↑(hC.map n ↑i) '' ball 0 1) ∩ ((⋃ (x : Σ (m : ℕ), {j : hC.cell m // ¬ Disjoint A.1 (hC.map m j '' ball 0 1)}), hC.map x.1 x.2 '' ball 0 1) ∩ (A.1 ∩ C)) := by
      congrm (⋃ n, ⋃ (i : I n), ↑(hC.map n ↑i) '' ball 0 1) ∩ ?_
      symm
      rw [Set.inter_eq_right]
      exact hC.subset_not_disjoint' A.1
    _ = (⋃ n, ⋃ (i : { i : I n // ¬Disjoint A.carrier (↑(hC.map n ↑i) '' ball 0 1) }), ↑(hC.map n ↑↑i) '' ball 0 1) ∩ (A.1 ∩ C) := by
      rw [← inter_assoc]
      congrm ?_ ∩ (A.1 ∩ C)
      ext x
      simp only [iUnion_coe_set, TopologicalSpace.Compacts.carrier_eq_coe, mem_inter_iff,
        mem_iUnion, exists_prop, Sigma.exists,
        Subtype.exists, and_iff_right_iff_imp, forall_exists_index, and_imp]
      constructor
      · intro ⟨⟨n, i, imem, xmem1⟩, ⟨m, j, hmj, xmem2⟩⟩
        have := @not_disjoint_equal _ _ _ hC n i m j (by rw [not_disjoint_iff]; use x)
        rw [Sigma.mk.inj_iff] at this
        rcases this with ⟨eq1, eq2⟩
        subst eq1
        rw [heq_eq_eq] at eq2
        subst eq2
        use n, i
      · exact fun ⟨n, i, memI, notdisjoint, xmem⟩ ↦ ⟨⟨n, ⟨i, ⟨memI, xmem⟩⟩⟩, ⟨n, ⟨i, ⟨notdisjoint, xmem⟩⟩⟩⟩
    _ = (⋃ n, ⋃ (i : { i : ↑(I n) // ¬Disjoint A.carrier (↑(hC.map n ↑i) '' ball 0 1) }), ↑(hC.map n ↑↑i) '' ball 0 1) ∩ A.1 := by
      rw [inter_comm A.carrier, ← inter_assoc]
      congr
      simp_rw [Set.inter_eq_left, ← hC.union']
      apply Set.iUnion_mono''
      intro n x
      rw [mem_iUnion, mem_iUnion]
      intro ⟨i, _⟩
      use i

--this is quite ugly, probably because `hC.Subcomplex` shouldn't be a lemma
def subcomplex_iUnion_subcomplex (J : Type*) (sub : J → Set X) (cw : ∀ (j : J), hC.Subcomplex (sub j)) : hC.Subcomplex (⋃ (j : J), sub j) := hC.Subcomplex'' _
  (fun (n : ℕ) ↦ ⋃ (j : J), (cw j).I n)
  (by
    intro n i
    have imem := i.2
    rw [mem_iUnion] at imem
    rcases imem with ⟨j, imemj⟩
    rcases (hC.CWComplex_subcomplex (sub j) (cw j)).mapsto' n ⟨i, imemj⟩ with ⟨K, hK⟩
    rw [mapsTo'] at hK ⊢
    rw [← Metric.sphere_union_ball, image_union]
    apply union_subset
    · apply subset_iUnion_of_subset j
      apply subset_trans hK
      simp_rw [(cw j).union]
      apply iUnion_mono
      intro m
      apply iUnion_subset
      intro _
      apply iUnion_subset
      intro k
      apply iUnion_subset
      intro _
      apply subset_iUnion_of_subset k
      rfl
    · apply subset_iUnion_of_subset j
      rw [(cw j).union]
      apply subset_iUnion_of_subset n
      apply subset_iUnion_of_subset ⟨i, imemj⟩
      rfl
    )
  (by
    simp_rw [(cw _).union]
    rw [iUnion_comm]
    apply iUnion_congr
    intro n
    apply subset_antisymm
    · apply iUnion_subset
      intro j
      apply iUnion_subset
      intro i
      apply subset_iUnion_of_subset ⟨i, by rw [mem_iUnion]; use j; exact i.2⟩
      rfl
    · apply iUnion_subset
      intro ⟨i, imem⟩
      rw [mem_iUnion] at imem
      rcases imem with ⟨j, imem⟩
      apply subset_iUnion_of_subset j
      apply subset_iUnion_of_subset ⟨i, imem⟩
      rfl
    )

def _finite_subcomplex__finite_iUnion_finite_subcomplex (J : Type*) [_root_.Finite J] (sub : J → Set X) (cw : ∀ (j : J), hC.Subcomplex (sub j))
    (finite : ∀ (j : J), (hC.CWComplex_subcomplex _ (cw j)).Finite) : (hC.CWComplex_subcomplex _ (hC.subcomplex_iUnion_subcomplex J sub cw)).Finite where
  finitelevels := by
    rw [Filter.eventually_iff]
    sorry
  finitecells := sorry


/- A finite union of finite subcomplexes is again a finite subcomplex.-/
/-
lemma finite_iUnion_finitesubcomplex (m : ℕ) (mnezero : m > 0) (I : Fin m → Π n, Set (hC.cell n)) (fincw : ∀ (l : Fin m), FiniteCWComplex (⋃ (n : ℕ) (j : I l n), hC.map n j '' ball 0 1)) : FiniteCWComplex (⋃ (l : Fin m) (n : ℕ) (j : I l n), hC.map n j '' ball 0 1) where
  cwcomplex := by
    apply hC.iUnion_subcomplex
    exact (fun l ↦ (fincw l).cwcomplex)
  finitelevels := by
    let max' l := Classical.choose (fincw l).finitelevels
    let max := Finset.max' (Finset.image (fun l ↦ max' l) (@Finset.univ _ (Fin.fintype m))) (by apply Finset.Nonempty.image (@Finset.univ_nonempty _ _ ((Fin.pos_iff_nonempty).1 mnezero)))
    use max
    ext x
    constructor
    · intro xmem
      rw [mem_iUnion] at xmem
      rcases xmem with ⟨l, xmem⟩
      simp only [level, levelaux, mem_iUnion, exists_prop]
      use max' l
      constructor
      · norm_cast
        rw [Nat.add_one]
        apply Nat.lt_succ_of_le
        simp [max]
        apply Finset.le_max'
        simp
      · have := Classical.choose_spec (fincw l).finitelevels
        sorry --maybe I need to make the construction of iUnion_subcomplex explicit to progress with this...
    · sorry
  finitecells := sorry
-/
