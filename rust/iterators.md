# Iterators
An iterator in rust is a trait 
```rs
pub trait Iterator {
    type Item;

    // Required method
    fn next(&mut self) -> Option<Self::Item>;

    ...
}
```

When we write for loops in Rust, we are using iterators
```rs
let vs = vec![1, 2, 3];

for v in vs { ... }
// is a sugar for 
let mut iter = vs.into_iter();
while let Some(e) = iter.next() { ... }

// and the followings are equivalent
for v in vs.iter() { ... }
for v in &vs { ... }
```

## `flatten` 
`flatten ()` methods unwraps the outer iterator and returns the inner iterators.
```rs
let vv = vec![vec![1, 2, 3], vec![4, 5, 6]];
for v in vv.iter().flatten() {
    print!("{} ", v);
}
// output:
// 1, 2, 3, 4, 5, 6
```

We can have the prototype:
```rs
pub Flatten<I> {
    outer: I,
}

pub fn flatten<I>(iter: I) -> Flatten<I> {
    Flatten::new(iter)
}

impl<I> Flatten<I> {
    fn new(iter: I) -> Self {
        Flatten { outer: iter }
    }
}

impl<I> Iterator for Flatten<I> {
    type Item = I::Item;
    fn next(&mut self) -> Option<Self::Item> {}
}
```