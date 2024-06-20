---
Title: The Basics of OCaml
Brief: (TODO) Finish this.
Created date: Jun. 18, 2024
Author: Jiaming Lu
Tags: Programming Language, Functional Programming, OCaml
---

# Data and Types
## Lists
### Building Lists
OCaml lists are:
- Immutable: Element within the list cannot be changed once instantiated.
- Singly-linked.

Syntax:
- `[]` is the empty list.
  - Pronounced as "nil".
- `e1 :: e2` prepends element `e1` to list `e2`.
  - The double-colon operator is pronounced "cons".
- `[e1 ; e2]` is sugar for `e1 :: e2 :: []`.
- And similarly for longer lists.

Dynamic semantics:
- `[]` is a value.
- If `e1 ==> v1`, and if `e2 ==> v2`, then `e1 :: e2 ==> v1 :: v2`.
- If `ei` evaluates to `vi` for all `i` in `1..n`, then `[e1; ...; en]` 
evaluates to `[v1; ...; vn]`.
> From now on, we use `e ==> v` to represents expression `e` is evaluated to 
> `v`. This is not the syntax supported by OCaml, we use it just for 
> convenience.

Static semantics
- `[] : 'a list`.
- If `e1 : t` and `e2 : t list` then `e1 :: e2 : t list`.
> All the elements of a list must have the same type.

### Accessing Lists
A good friend of list object is *pattern matching*.

Syntax:
```ml
match e with
  | p1 -> e1
  | p2 -> e2
  | ...
  | pn -> en
```
Notice that
- Each of the clauses `pi -> ei` is called a *branch* or a *case* of the
pattern match.
- The first vertical bar in the entire pattern match is optional.
- `p` is a new syntactic class: *pattern expressions*.

Dynamic semantics:
- If `e ==> v`,
  - and `pi` is the first pattern, top-to-bottom, that matches `v`,
  - and `ei ==> vi`,
  - then `(match e ...) ==> vi`.
- But if no patterns match, raise an exception `Match_failure`.

Static semantics:
- If `e` and `pi` have type `ta` and `ei` have type `tb`, then entire match 
expression has type `tb`.

Data type patterns:
- `[]`
- `p1 :: p2`
- `[p1; p2]`
- `(p1, p2)`
- `{f1 = p1; f2 = p2}`

```ml
let rec sum xs =
  match xs with
  | [] -> 0
  | x :: xs' -> x + sum xs'

let rec length lst =
  match lst with
  | [] -> 0
  | _ :: t -> 1 + length t

let rec append lst1 lst2 =
  match lst1 with
  | [] -> lst2
  | h :: t -> h :: append t lst2
```

Notice that OCaml has built-in list appending operator
```ml
[1; 2; 3] @ [4; 5; 6];;
(* Gives [1; 2; 3; 4; 5; 6] *)
```

`::`, the cons list operator 
- has type `'a -> 'a list -> 'a list`,
- $O(1)$ time complexity

`@`, the append list operator
- has type `'a list -> 'a list -> 'a list`,
- for `u @ v`, the time complexity is $O(n)$, where $n$ is the length of `u`.

### (Not) Mutating Lists
Lists are immutable, in the following code 
```ml
let inc_first lst =
  match lst with
  | [] -> []
  | h :: t -> h + 1 :: t
```
Instead of cloning the entire list `t` for each function call, the list `t` is 
shared for each function call.

### Tail Recursion
Tail recursion also can be employed in pattern matching
```ml
let rec sum (l : int list) : int = 
  match l with 
  | [] -> 0 
  | x :: xs -> x + (sum xs) 

let rec sum_plus_acc (acc : int) (l : int list) : int = 
  match l with 
  | [] -> acc
  | x :: xs -> x + (sum_plus_acc (acc + x) xs)

let sum_tr : int list -> int =
  sum_plus_acc 0
```

## Variants
Syntax:
```ml
type t = C1 | ... | Cn
```

Dynamic semantics:
- A constructor is already value is simply its name.

Static semantics:
- If `t` is a type defined as `type t = ... | C | ...`, then `C : t`.

## Unit Testing with OUnit 
















