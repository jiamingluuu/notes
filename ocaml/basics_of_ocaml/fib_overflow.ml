(**
 * This file contains a function calculates the fibonacci number of with given
 * natural number n. It is optimized with tail optimization to ensure the
 * efficiency.
 *)

let rec h n p pp =
  if n == 1 then p
  else h (n-1) pp (p+pp)

let fib n =
  if n <= 2 then 1
  else h n 0 1

let find_overflow_fib () =
  let rec find_fib n =
    let fib_n = fib n in
    if fib_n < 0 then n else find_fib (n+1)
  in
  find_fib 0

let () =
  let overflow_fib = find_overflow_fib () in 
  print_string "The overflow occurs when n = ";
  print_int overflow_fib;
  print_newline ()
