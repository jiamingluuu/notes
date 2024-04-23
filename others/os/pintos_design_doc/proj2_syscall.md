# Project 2 - System Calls
## Command Line Arguments Parsing
### Issue Elaboration
An user executable may receives

## Syscall
### Issue Elaboration
System calls (abbr. syscall) are a series of unique functions that enable an
user program to request service from the kernel of operating system(OS). In
this project we are asked to implement most of the syscalls.

### Solution
#### Initialization
Whenever a syscall is invoked by user program OS does the followings:
- A series of macro is used, namely, `sycall1`, `syscall2`, `syscall3` are
invoked to push syscall parameters onto user stack.
- Then an interrupt is triggered, OS redirect the current execution flow to an
interrupt handler.
- The interrupt handler detects the current interrupt requesting a syscall, so
redirects to syscall handler.
- In syscall handler, start the syscall routine respectively, pop the syscall
parameter from stack, then load the return value to `eax` register on return.

#### Implemented Syscall
1. 
