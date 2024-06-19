let rec sum xs =
  match xs with
  | [] -> 0
  | x :: xs' -> x + sum xs' in

print_int @@ sum [1; 2; 3];
print_newline
