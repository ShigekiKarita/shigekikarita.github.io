(* Boolean *)
Inductive bool : Type :=
  | true : bool
  | false : bool.

Definition negb (b : bool) : bool :=
  match b with
    | true => false
    | false => true
  end.

Definition andb lhs rhs :=
  match lhs with
    | true => rhs
    | false => false
  end.

Definition orb lhs rhs :=
  match lhs with
    | true => true
    | false => rhs
  end.

Example test_orb1 : (orb true false) = true.
Proof. simpl. reflexivity. Qed.
Example test_orb2: (orb false false) = false.
Proof. simpl. reflexivity. Qed.
Example test_orb3: (orb false true ) = true.
Proof. simpl. reflexivity. Qed.
Example test_orb4: (orb true true ) = true.
Proof. simpl. reflexivity. Qed.


Definition admit {T: Type} : T. Admitted.

(* Ex. nandb *)
Definition nandb (b1:bool) (b2:bool) : bool :=
  negb (andb b1 b2).

Example test_nandb1: (nandb true false) = true.
Proof. simpl. reflexivity. Qed.
Example test_nandb2: (nandb false false) = true.
Proof. simpl. reflexivity. Qed.
Example test_nandb3: (nandb false true) = true.
Proof. simpl. reflexivity. Qed.
Example test_nandb4: (nandb true true) = false.
Proof. simpl. reflexivity. Qed.

(* Ex. andb3 *)
Definition andb3 (b1:bool) (b2:bool) (b3:bool) : bool :=
  andb (andb b1 b2) b3.

Example test_andb31: (andb3 true true true) = true.
Proof. simpl. reflexivity. Qed.
Example test_andb32: (andb3 false true true) = false.
Proof. simpl. reflexivity. Qed.
Example test_andb33: (andb3 true false true) = false.
Proof. simpl. reflexivity. Qed.
Example test_andb34: (andb3 true true false) = false.
Proof. simpl. reflexivity. Qed.

(* 型の表示 *)
Check (negb true).              (* bool *)
Check negb.                     (* bool -> bool *)

(* モジュール *)
Module Playground1.
  Inductive nat : Type :=
    | O : nat
    | S : nat -> nat.

  Definition pred(n: nat): nat :=
    match n with
      | O => O
      | S n => n
    end.
  Check pred (S O).
End Playground1.

Definition minustwo(n: nat): nat :=
  match n with
    | O => O
    | S O => O
    | S (S n') => n'
  end.
Check (S (S (S (S O)))).
Eval simpl in (minustwo 4).
Check pred.


(* 再帰関数 *)
Fixpoint evenb(n: nat): bool :=
  match n with
    | O => true
    | S O => false
    | S (S n') => evenb n'
  end.

Definition oddb(n : nat) : bool :=
  negb (evenb n).

Module Playground2.
  Fixpoint plus(n m: nat): nat :=
    match n with
      | O => m
      | S n' => S (plus n' m)
    end.
  Eval simpl in (plus (S (S (S O))) (S (S O))).

  Fixpoint mult(n m: nat): nat :=
    match n with
      | O => O
      | S n' => plus m (mult n' m)
    end.
  Eval simpl in (mult (S (S (S O))) (S (S O))).

  Fixpoint minus(n m: nat): nat :=
    match n, m with
      | O, _       => O
      | S _, O     => n
      | S n', S m' => minus n' m'
    end.

  Fixpoint exp(base power: nat):nat :=
    match power with
      | O => S O
      | S p => mult base (exp base p)
    end.

End Playground2.

(* 記法の追加。強そう *)
Notation "x + y" := (plus x y)(at level 50, left associativity): nat_scope.
Eval simpl in (1 + 2).


(* 数値の比較 *)
Fixpoint beq_nat(n m: nat): bool :=
  match n with
    | O =>
      match m with
        | O => true             (* 0 == 0 *)
        | S _ => false          (* 0 != 1 *)
      end
    | S n' =>
      match m with
        | O => false            (* n-1 != 0 *)
        | S m' => beq_nat n' m' (* n-1, m-1 *)
      end
  end.

Fixpoint ble_nat(n m: nat): bool :=
  match n with
    | O => true                 (* 0 <= m *)
    | S n' =>
      match m with
        | O => false
        | S m' => ble_nat n' m' (* n-1, m-1 *)
      end
  end.

Example test_ble_nat1: (ble_nat 2 2) = true.
Proof. simpl. reflexivity. Qed.
Example test_ble_nat2: (ble_nat 2 4) = true.
Proof. simpl. reflexivity. Qed.
Example test_ble_nat3: (ble_nat 4 2) = false.
Proof. simpl. reflexivity. Qed.

(* Ex. blt_nat *)
Definition blt_nat (n m : nat) : bool :=
  negb (ble_nat m n).

Example test_blt_nat1: (blt_nat 2 2) = false.
Proof. simpl. reflexivity. Qed.
Example test_blt_nat2: (blt_nat 2 4) = true.
Proof. simpl. reflexivity. Qed.
Example test_blt_nat3: (blt_nat 4 2) = false.
Proof. simpl. reflexivity. Qed.

(* 簡約による証明 *)
Theorem plus_O_n:
  forall n: nat, n = 0 + n.
Proof. simpl. reflexivity. Qed.

(* + は最初の引数を再帰的にとるから *)
Eval simpl in (forall n:nat, n + 0 = n).
Eval simpl in (forall n:nat, 0 + n = n).


(* intros タクティック *)
Theorem plus_O_n'': forall n: nat, 0 + n = n.
Proof. intros n. reflexivity. Qed.

Theorem plus_1_l: forall n: nat, 1 + n = S n.
Proof. intros n. reflexivity. Qed.


(* rewrite タクティック *)
Theorem plus_id_example:
  forall n m: nat,
    n = m -> n + n = m + m.
Proof.
  intros n m H.
  rewrite -> H.                 (* 仮定 H: n = m を n + n = m + m に代入 *)
  reflexivity.
Qed.

Theorem plus_id_exercise : forall n m o: nat,
  n = m ->
  m = o ->
  n + m = m + o.
Proof.
  intros n m o H0 H1.
  rewrite -> H0.
  rewrite -> H1.
  reflexivity.
Qed.

Theorem mult_0_plus:
  forall n m: nat,
    (0 + n) * m = n * m.
Proof.
  intros n m.
  rewrite -> plus_O_n.          (* 定理の再利用 *)
  reflexivity.
Qed.

Theorem mult_1_plus:
  forall n m: nat,
    (1 + n) * m = m + (n * m).
Proof.
  intros n m.
  rewrite -> plus_1_l.
  reflexivity.
Qed.


(* destruct 分解タクティック *)
Theorem plus_1_neq_0: forall n: nat,
  beq_nat (n + 1) 0 = false.
Proof.
  intros n.
  destruct n as [| n'].         (* データ型に分解、 | n' はSコンストラクタの引数名
                                   | の左側はOが無引数だから空 *)
  reflexivity.                  (* n = O *)
  reflexivity.                  (* n = S n' *)
Qed.

Theorem negb_involtive: forall b: bool,
  negb (negb b) = b.
Proof.
  intros b.
  destruct b.                   (* すべて無引数なので as 句を省略 *)
  reflexivity.
  reflexivity.
Qed.

Theorem zero_nbeq_plus_1:
  forall n: nat,
    beq_nat 0 (n + 1) = false.
Proof.
  intros n.
  destruct n as [| n'].
  reflexivity.
  reflexivity.
Qed.


(* Case タクティック *)
Require String.
Open Scope string_scope.

Ltac move_to_top x :=            (* カスタムタクティックの定義 *)
  match reverse goal with
    | H: _ |- _ => try move x after H
  end.

Tactic Notation "assert_eq" ident(x) constr(v) :=
  let H := fresh in
  assert (x = v) as H by reflexivity;
  clear H.

Tactic Notation "Case_aux" ident(x) constr(name) :=
  first [
    set (x := name); move_to_top x
  | assert_eq x name; move_to_top x
  | fail 1 "because we are working on a different case" ].

Tactic Notation "Case" constr(name) := Case_aux Case name.
Tactic Notation "SCase" constr(name) := Case_aux SCase name.
Tactic Notation "SSCase" constr(name) := Case_aux SSCase name.
Tactic Notation "SSSCase" constr(name) := Case_aux SSSCase name.
Tactic Notation "SSSSCase" constr(name) := Case_aux SSSSCase name.
Tactic Notation "SSSSSCase" constr(name) := Case_aux SSSSSCase name.
Tactic Notation "SSSSSSCase" constr(name) := Case_aux SSSSSSCase name.
Tactic Notation "SSSSSSSCase" constr(name) := Case_aux SSSSSSSCase name.

Theorem andb_true_elim1:
  forall b c: bool,
    andb b c = true -> b = true.
Proof.
  intros b c H.
  destruct b.
  Case "b = true".               (* andb true c = true *)
    reflexivity.
  Case "b = false".               (* andb false c = true *)
    rewrite <- H.              (*  *)
    reflexivity.
Qed.


Theorem andb_true_elim2 : forall b c : bool,
  andb b c = true -> c = true.
Proof.
  intros b c H.
  destruct c.
  Case "c = true".
    reflexivity.
  Case "c = false".
    rewrite <- H.
    destruct b.
    reflexivity.
    reflexivity.
Qed.



(* induction タクティック: 帰納法 *)
Theorem plus_0_r: forall n: nat,
  n + 0 = n.
Proof.
  intros n.
  induction n as [| n'].
  Case "n = 0".
    reflexivity.                (* 0 + 0 = 0 *)
  (* n-1 で成立すると仮定 *)
  Case "n = S n'".              (* S n' + 0 = S n' *)
    simpl.                      (* S (n' + 0) = S n' *)
    rewrite -> IHn'.            (* Induction Hypothesis for n', IHn' : n' + 0 = n' *)
    reflexivity.
Qed.


Theorem minus_diag: forall n, minus n n = 0.
Proof.
  intros n.
  induction n as [| n'].
  Case "n = 0".
    reflexivity.
  Case "n = S n'".
    simpl.
    rewrite -> IHn'.
    reflexivity.
Qed.

Theorem mult_0_r: forall n: nat, n * 0 = 0.
Proof.
  intros n.
  induction n as [| n'].
  Case "n = 0".
    reflexivity.
  Case "n = S n'".
    simpl.
    rewrite -> IHn'.
    reflexivity.
Qed.

Theorem plus_n_Sm: forall n m: nat,
  S (n + m) = n + (S m).
Proof.
  intros n m.
  induction n as [| n'].
  Case "n = 0".
    simpl.
    reflexivity.
  Case "n = S n'".
    simpl.
    rewrite -> IHn'.
    reflexivity.
Qed.

Theorem plus_comm: forall n m: nat,
  n + m = m + n.
Proof.
  intros n m.
  induction n as [| n'].
  Case "n = 0".
    simpl.
    rewrite -> plus_0_r.
    reflexivity.
  Case "n = S n'".
    simpl.
    rewrite -> IHn'.
    rewrite -> plus_n_Sm.
    reflexivity.
Qed.

Fixpoint double (n: nat) :=
  match n with
    | O => O
    | S n' => S (S (double n'))
  end.

Lemma double_plus: forall n,
  double n = n + n.
Proof.
  intros n.
  induction n as [| n'].
  Case "n = 0".
    simpl.
    reflexivity.
  Case "n = S n'".
    simpl.
    rewrite -> IHn'.
    rewrite -> plus_n_Sm.
    reflexivity.
Qed.


(* 形式的証明と非形式的証明 *)
(* 機械の解釈するコードは形式的、人間の解釈する文とかは非形式的 *)

Theorem plus_assoc: forall n m p: nat,
 n + (m + p) = (n + m) + p.
Proof.
  intros n m p.
  induction n as [| n'].
  Case "n = 0".                 (* 0 + (m + p) = (0 + m) + p *)
    reflexivity.                (* + の定義より直接成立 *)
  Case "n = S n'".              (* S n' + (m + p) = (S n' + m) + p に特殊化*)
    simpl.                      (* S (n' + (m + p)) = S (n' + m + p) に簡約 *)
    rewrite -> IHn'.            (* n' のとき成立という仮定を代入 *)
    reflexivity.                (* 等号成立 *)
Qed.


(* 非形式的証明を意識してわかりやすく書こう！ *)

Theorem beq_nat_refl: forall n: nat,
  true = beq_nat n n.
Proof.
  intros n.
  induction n as [| n'].
  Case "n = 0".
    simpl.
    reflexivity.
  Case "n = S n'".
    simpl.
    rewrite -> IHn'.
    reflexivity.
Qed.


(* assert タクティック 証明の中で証明 *)

Theorem mult_0_plus': forall n m: nat,
  (0 + n) * m = n * m.
Proof.
  intros n m.
  assert (H: 0 + n = n).        (* 部分的な証明 *)
    Case "Proof of assertion".
    reflexivity.
  rewrite -> H.
  reflexivity.
Qed.

Theorem plus_rearrange: forall n m p q: nat,
  (n + m) + (p + q) = (m + n) + (p + q).
Proof.
  intros.
  assert (H: n + m = m + n).    (* 部分的な証明 *)
    case "Proof of assertion".
    rewrite -> plus_comm.
    reflexivity.
  rewrite -> H.
  reflexivity.
Qed.

Theorem plus_swap: forall n m p: nat,
  n + (m + p) = m + (n + p).
Proof.                          (* no induction *)
  intros.
  rewrite -> plus_assoc.       (* n + m + p = m + (n + p) *)
  assert (H: n + m = m + n).
    Case "Proof of assertion".
    rewrite -> plus_comm.
    reflexivity.
  rewrite -> H.                 (* m + n + p = m + (n + p) *)
  rewrite -> plus_assoc.       (* m + n + p = m + n + p *)
  reflexivity.
Qed.

Theorem plus_swap_induction: forall n m p: nat,
  n + (m + p) = m + (n + p).
Proof.
  intros.
  induction n as [| n'].
  Case "n = 0".
    simpl.
    reflexivity.
  Case "n = S n'".
    simpl.
    rewrite -> IHn'.
    rewrite -> plus_n_Sm.
    reflexivity.
Qed.


Lemma mult_1: forall n m: nat,
   n + n * m = n * S m.
Proof.
  intros n m.
  induction n as [| n'].
  Case "n = 0".
    simpl.
    reflexivity.
  Case "n = S n'".
    simpl.
    rewrite <- IHn'.
    rewrite -> plus_assoc.
    rewrite -> plus_assoc.
    assert (H: n' + m = m + n').
      rewrite -> plus_comm.
      reflexivity.
    rewrite -> H.
    reflexivity.
Qed.

Theorem mult_comm: forall n m: nat,
  m * n = n * m.
Proof.
  intros.
  induction m as [|m'].
  Case "m = 0".
    rewrite -> mult_0_r.
    reflexivity.
  Case "m = S m'".
    simpl.
    rewrite -> IHm'.
    rewrite -> mult_1.
    reflexivity.
Qed.


Theorem evenb_n__oddb_Sn : forall n : nat,
  evenb n = negb (evenb (S n)).
Proof.
  intros n.
  simpl.
  induction n.
  Case "n = 0".
    simpl.
    reflexivity.
  Case "n = S n'".
    simpl.
    rewrite -> IHn.
    rewrite -> negb_involtive.
    reflexivity.
Qed.


(* さらなる練習問題 *)

Theorem ble_nat_refl : forall n:nat,
  true = ble_nat n n.
Proof.
  intros n.
  induction n as [| n'].
  Case "n = 0".
    simpl.
    reflexivity.
  Case "n = Sn'".
    simpl.
    rewrite -> IHn'.
    reflexivity.
Qed.


Theorem zero_nbeq_S : forall n:nat,
  beq_nat 0 (S n) = false.
Proof.
  intros n.
  simpl.
  reflexivity.
Qed.


Theorem andb_false_r : forall b : bool,
  andb b false = false.
Proof.
  intros.
  destruct b.
  simpl.
  reflexivity.
  simpl.
  reflexivity.
Qed.


Theorem plus_ble_compat_l : forall n m p : nat,
  ble_nat n m = true -> ble_nat (p + n) (p + m) = true.
Proof.
  intros.
  rewrite <- H.
  induction p.
  Case "p = 0".
    simpl.
    reflexivity.
  Case "p = S p'".
    simpl.
    rewrite -> IHp.
    reflexivity.
Qed.


Theorem S_nbeq_0 : forall n:nat,
  beq_nat (S n) 0 = false.
Proof.
  intros.
  simpl.
  reflexivity.
Qed.


Lemma mult_1_r: forall n: nat, n = n * 1.
Proof.
  intros.
  rewrite <- mult_1.
  rewrite -> mult_0_r.
  rewrite -> plus_0_r.
  reflexivity.
Qed.

Theorem mult_1_l : forall n:nat,
  1 * n = n.
Proof.
  intros.
  rewrite -> mult_comm.
  rewrite <- mult_1_r.
  reflexivity.
Qed.


Theorem all3_spec : forall b c : bool,
  orb (andb b c)
      (orb (negb b)
           (negb c))
  = true.
Proof.
  intros.
  destruct b.
    simpl.
    destruct c.
      simpl.
      reflexivity.
      simpl.
      reflexivity.
    simpl.
    reflexivity.
Qed.


Theorem mult_plus_distr_r : forall n m p : nat,
  (n + m) * p = (n * p) + (m * p).
Proof.
  intros.
  induction p as [|p'].
  Case "p = 0".
    rewrite -> mult_0_r.
    rewrite -> mult_0_r.
    rewrite -> mult_0_r.
    reflexivity.
  Case "p = S p'".
    rewrite <- mult_1.
    rewrite <- mult_1.
    rewrite <- mult_1.
    rewrite -> plus_assoc.
    rewrite -> IHp'.
    rewrite -> plus_assoc.
    assert (H: n + m + n * p' = n + n * p' + m).
      rewrite -> plus_comm.
      rewrite -> plus_swap.
      rewrite -> plus_assoc.
      reflexivity.
    rewrite -> H.
    reflexivity.
Qed.



Theorem mult_assoc : forall n m p : nat,
  n * (m * p) = (n * m) * p.
Proof.
  intros.
  induction p as [|p'].
  Case "p = 0".
    rewrite -> mult_0_r.
    rewrite -> mult_0_r.
    rewrite -> mult_0_r.
    reflexivity.
  Case "p = S p'".
    rewrite <- plus_1_l.
    rewrite -> mult_comm.
    assert (H: m * (1 + p') = m + m * p').
      rewrite -> mult_comm.
      rewrite -> mult_1_plus.
      rewrite -> mult_comm.
      reflexivity.
    rewrite -> H.
    rewrite <- mult_1.
    rewrite -> mult_plus_distr_r.
    rewrite -> mult_comm.
    assert (H1: m * p' * n = n * m * p').
      rewrite -> mult_comm.
      rewrite -> IHp'.
      reflexivity.
    rewrite -> H1.
    reflexivity.
Qed.




(* replace タクティック *)
Theorem plus_swap': forall n m p: nat,
  n + (m + p) = m + (n + p).
Proof.
  intros.
  replace (n + p) with (p + n).
    rewrite -> plus_comm.
    rewrite -> plus_assoc.
    reflexivity.

  rewrite -> plus_comm.
  reflexivity.
Qed.


(* Ex. binary *)
Inductive bit: Type :=
  | Zero : bit
  | Twice : bit -> bit
  | TwicePlus1 : bit -> bit.

Fixpoint inc_bit (b: bit): bit :=
  match b with
    | Zero => TwicePlus1 Zero           (* 0 => 2 * 0 + 1 *)
    | Twice x => TwicePlus1 x           (* 2 a => 2 a + 1 *)
    | TwicePlus1 x => Twice (inc_bit x) (* 2 b + 1 => 2 (b + 1) *)
  end.

Fixpoint bit_to_nat(b: bit): nat :=
  match b with
    | Zero => 0
    | Twice x => 2 * (bit_to_nat x)
    | TwicePlus1 x => 2 * (bit_to_nat x) + 1
  end.

Example b2n_0: (bit_to_nat Zero) = 0.
Proof. simpl. reflexivity. Qed.
Example b2n_1: (bit_to_nat (inc_bit Zero)) = 1.
Proof. simpl. reflexivity. Qed.
Example b2n_2: (bit_to_nat (inc_bit (inc_bit Zero))) = 2.
Proof. simpl. reflexivity. Qed.
Example b2n_3: (bit_to_nat (inc_bit (inc_bit (inc_bit Zero)))) = 3.
Proof. simpl. reflexivity. Qed.

Theorem inc_bit_nat_comm: forall b: bit,
  bit_to_nat (inc_bit b) = bit_to_nat b + 1.
Proof.
  intros.
  induction b as [| b' | b''].
  Case "b = Zero".
    simpl.
    reflexivity.
  Case "b = Twice b'".
    simpl.
    reflexivity.
  Case "b = TwicePlus1 b''".
    simpl.
    rewrite -> IHb''.
    rewrite -> plus_0_r.
    rewrite -> plus_0_r.
    rewrite -> plus_assoc.
    assert (H:  bit_to_nat b'' + 1 + bit_to_nat b'' = bit_to_nat b'' +  bit_to_nat b'' + 1).
      rewrite -> plus_comm.
      rewrite -> plus_assoc.
      reflexivity.
    rewrite <- H.
    reflexivity.
Qed.


(* Ex. bitary_inverse *)
Fixpoint nat_to_bit(n: nat): bit :=
  match n with
    | 0 => Zero
    | S n' => inc_bit (nat_to_bit n')
  end.

Theorem nat_bit_nat: forall n: nat,
   bit_to_nat (nat_to_bit n) = n.
Proof.
  intros n.
  induction n as [O | n'].
  Case "n = O".
    simpl.
    reflexivity.
  Case "n = S n'".
    simpl.
    rewrite -> inc_bit_nat_comm.
    rewrite -> plus_comm.
    rewrite -> plus_1_l.
    rewrite -> IHn'.
    reflexivity.
Qed.


(* (b) 理由. Zero = Twice Zero でないから?? *)
(* (c) 題意がつかめず *)

(* Ex. decreasing *)
(* Coq の停止性判定が微妙となる例をかけ *)
(*
Fixpoint test_dec(n: nat): nat :=
  match n with
    | O => test_dec (S O)       (* 下の行で停止するけど *)
    | S O => 0
    | S n' => test_dec n'
  end.
*)