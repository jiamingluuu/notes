---
Title: The Basics of OCaml
Brief: This notes covers the fundamental ascpects of OCaml, including the 
  basic usage of expression, function, as well as how to debug and compile 
  a OCaml program.
Created date: Jun. 18, 2024
Author: Jiaming Lu
Tags: Programming Language, Functional Programming, OCaml
---

> Notes from the open course 
> [CS3110](https://cs3110.github.io/textbook/cover.html) at Cornell.

# The Basics of OCaml
## Expressions
Every kind of expression has:
- Syntax
- Semantics
  - Type-checking rules (static semantics): produce a type, or fail with an
  error message.
  - Evaluation rules (dynamic semantics): produce a value, or exception or
  infinite loop.
> A *value* is an expression that does not need any further evaluation.

### Types and Values
#### Primitive Types and Values
Primitive types of ocaml consists of
- `int`: Integer, ranged from $- 2^{62}$ to $2^{62}-1$, the missing on bit is 
used to distinguish an integer from pointer.
  - Supported operations: `+`, `-`, `*`, `/`, `mod`.
- `float`: Floating-point numbers, follows IEEE 754 standard.
  - Supported operations: `+.`, `-.`, `*.`, `/.`.
- `bool`: Booleans, contains `true` and `false` only.
  - Supported operations: `&&`, `||`.
- `char`: Characters, each is a bytes, can be initiated like `'a'`.
- `string`: Strings, a sequence of `char`, initiated like `"abc"`.
  - Supported operations: `^`, for string concatenation.
  - Indexed by `"abc".[0]`.

#### Assertions
```ml
let () = assert (f input = output)
```

#### `if` Expression
Syntax:
```ml
if e1 then e2 else e3
```

Dynamic semantics:
- If `e1` evaluates to `true`, and if `e2` evaluates to a value `v`, then 
`if e1 then e2 else e3` evaluates to `v`.
- If `e1` evaluates to `false`, and if `e3` evaluates to a value `v`, then 
`if e1 then e2 else e3` evaluates to `v`.

Static semantics:
- if `e1` has type `bool` and `e2` has type `t` and `e3` has type `t`, then 
`if e1 then e2 else e3` has type `v`.

#### `let` Expression
A let expression *binds* a value to an *identifier*. Keyword `let` often used 
together with keyword `in`.
```ml
# (let x = 32 in x) + 1;;
- : int = 43
```

Syntax:
```ml
let x = e1 in e2
```
Where
- `x` is an identifier begins with lower-case letter, and written with 
`snake_case`,
- `e1` is the *binding expression*,
- `e2` is the *body expression*.

Dynamic semantics:
- Evaluate `e1` to a value `v1`.
- Substitute `v1` for x in `e2`, yielding a new expression `e2'`.
- Evaluate `e2'` to a value `v2`.
- The result of evaluating the let expression is `v2`.

Static semantics
- If `e1 : t1` and if under the assumption that `x : t1` it holds that
`e2 : t2`, then `(let x = e1 in e2) : t2`.

#### Scope
Declaration of variable is simple another format of value substitution:
```ml
let a = "big";;
let b = "red";;
let c = a ^ b;;
```
is interpreted by utop as
```ml
let a = "big" in
  let b = "red" in
    let c = a ^ b in ...
```

Principle of Name Irrelevance:
- The name of a variable shouldn't intrinsically matter.

## Functions
### Function Definitions
Syntax:
```ml
let <rec> f x1 x2 ... xn = e;;
```
The syntax for function types is:
```ml
t -> u
t1 -> t2 -> u
t1 -> ... -> tn -> u
```

Dynamic semantics:
- There is no dynamic semantics of function definitions.

Static semantics:
- For non-recursive functions: if by assuming that `x1 : t1` and `x2 : t2` and
`xn : tn`, we can conclude that `e : u`, then `f : t1 -> t2 -> ... -> tn -> u`.
- For recursive functions: if by assuming that `x1 : t1` and `x2 : t2` and
`xn : tn`, we can conclude that `e : u`, then `f : t1 -> t2 -> ... -> tn -> u`.

There are two ways of declaring a function. They are *semantically equivalent*
and the latter is a *syntactic sugar* of the former.
```ml
let inc = fun x -> x + 1;;
let inc x = x + 1;;
```

For recursive functions, annotate  `rec` keyword in the let expression:
```ml
(* Requires n is a natural number. *)
let rec fact n =
  if n = 0 then 1
  else n * fact (n - 1);;

let rec pow x y =
  if y = 0 then 1
    else x * pow x (y - 1);;
```

We can also declares mutually recursive functions
```ml
let rec even n = 
  n = 0 || odd (n - 1);;
let rec odd n = 
  n <> 0 && even (n - 1);;
```

### Anonymous Functions
Syntax:
```ml
fun x1 ... xn -> e
```

Dynamic semantics:
- There is no dynamic semantics for anonymous function, it is already a value.

Static semantics:
- If by assuming that `x1 : t1` and `x2 : t2` and ... and `xn : tn`, we can
conclude that `e : u`, then `fun x1 ... xn -> e : t1 -> t2 -> ... -> tn -> u`.

Let expression can be applied on binding lambda expression to an identifier
```ml
let inc x = x + 1;;        (* function declaration *)
let inc = fun x -> x + 1;; (* lambda expression binding *)
```
They are syntactically different but semantically equivalent.

### Function Application
Syntax:
```ml
e0 e1 ... en
```
> Note that no parentheses for function invocation, unless you need to enforce
> operation precedence.

Dynamic semantics:
- Evaluate `e0` to a function. Also evaluate the argument expression `e1`
through `en` to values `v1` through `vn`.
- Substitute each value `vi` for the corresponding argument name `xi` in the
body `e` of the function. That substitution results in a new expression `e'`.
- Evaluate `e'` to a value `v`, which is the result of evaluating 
`e0 e1 ... en`.

> Expression `let x = e1 in e2` and `(fun x -> e2) e1` are syntactically 
> different but semantically equivalent. `let` expression is a syntactic sugar
> for anonymous function application.

### Pipeline
Application operators:
- Application:
```ml
let (@@) f x = f x
```
  - Example:
```ml
let succ x = x + 1;;
(* The following yields a value of 30. *)
succ 2 * 10;;
(* On the contrary of the following yields a value of 21. *)
succ @@ 2 * 10;;
```
- Reverse application:
```ml
let (|>) x f = f x
```
  - Example:
```ml
let succ x = x + 1;;
let square x = x * x;;
(* The followings are equivalent. *)
5 |> inc |> square |> inc |> inc |> square;;
square (inc (inc (square (inc 5))));;
```

### Polymorphic function
The function 
```ml
let id x = x
```
has type 
```ml
val id : 'a -> 'a = <fun>
```
The `'a` is a *type variable*: it stands for an unknown type.

Function `id` is a polymorphic function, the type variable can be instantiated
by using type annotation or function application.
```ml
(* Type annotation. *)
let id' (x: int) : int = x;;
(* Function application. *)
id x;;
```

### Labeled and Optional Arguments
To name a function parameter 
```ml
let f ~name1:(arg1: int) ~name2:(arg2: int) = arg1 + arg2;;
(**
 * This gives a type name of:
 * val f : name1:int -> name2:int -> int = <fun>
 *)

(**
 * And for function application, we can even pass parameter not in the order
 * that they are declared.
 *)
f ~name2:3 ~name1:1;;
```

It is also possible to make some function parameter optional, and gives it a 
default value:
```ml
let f ?name:(arg=8) arg2 = arg1 + arg2;;
(* val f : ?name:int -> int -> int = <fun> *)

f ~name:2 7;;
(* - : int = 9 *)

f 7;;
(* - : int = 15 *)
```

### Partial Application
There is no multi-parameter in functional programming languages, they are all 
a chain of partial application of anonymous function. For instance 
```ml
let add x y = x + y;;
```
is a syntactic sugar for 
```ml
let add = fun x -> (fun y -> x + y);;
```
So the function `add` can be seen as a pseudo-higher-ordered function that 
- firstly takes a input parameter `x`,
- and returns a function `(fun y -> x + y)`.


### Function Associativity
In general 
```ml
let f x0 x1 ... xn = e
```
is semantically equivalent to 
```ml
let f = 
  fun x1 -> 
    (fun x2 -> 
      (...
        (fun xn -> e)...))
```

Function types are *right associative*:
```ml
t1 -> t2 -> t3 -> t4
```
essentially is 
```ml
t1 -> (t2 -> (t3 -> t4))
```

Function application is `left associative`:
```ml
e1 e2 e3 e4
```
essentially is 
```ml
((e1 e2) e3) e4
```

### Operators as Functions
The operator `+` has type `int -> int -> int`. So we can use it to make lower 
order functions:
```ml
let add2 = ( + ) 3;;
```
And we can define our own infix operator:
```ml
let ( ^^ ) x y = max x y;;
3 ^^ 2;;
(* - : int = 3 *)
```

### Tail Recursion
Consider the following function
```ml
let rec count n = 
  if n = 0 then 0 else 1 + count (n - 1);;
```
This function is terminated indeed, but potentially causes stack overflow if
the value of `n` is large. This is because the *call stack* of the function is
limited by preventing a single function uses up all operating system resource.

To optimized this function we can use the trick called *tail optimization*
```ml
let rec count_aux n acc =
  if n = 0 then acc else count_aux (n - 1) (acc + 1);;
let count_tr n = count_aux n 0;;
```
The OCaml compiler in this case will notice that: we do not need to allocate a 
new stack frame for the up coming function call, use the existing one is enough,
because what we actually return is the `acc` variable.

The recipe for tail recursion:
- Change the function into a helper function. Add an extra argument: the 
accumulator, often named `acc`.
- Write a new "main" version of the function that calls the helper. It passes
the original base case's return value as the initial value of the accumulator.
- Change the helper function to return the accumulator in the base case.
- Change the helper function's recursive case. It now needs to do the extra 
work on the accumulator argument, before the recursive call.












