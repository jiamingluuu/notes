# Project 1 - Thread
## Alarm Clock
### Issue Elaboration
Suppose a thread T invokes `timer_sleep ()` method, The original implementation
busy waits (that is, whenever a thread is called this function, yield) T for
`ticks` ticks. This waste CPU resource as context switching may happens
frequently. Even worse, if T calling `timer_sleep` has the highest priority,
the whole system is entirely malfunctioned as it just schedule the calling
thread and yield repeatedly.

### Solution
To solve this issue, we adopted the following modification

#### Added Data Structure
In `device/timer.c`
```c
/* List containing all the threads that have called timer_sleep (). 
   All elements are sorted in increasing order with respect to TICK_TO_WAKE. */
static struct list sleep_list;
```

In `threads/thread.h`
```c
struct thread
  {
    [...]
    /* owned by device/timer.c */
    uint64_t tick_to_wake;        /* Timer interrupts wake up the thread when
                                     the CPU TICKS reaches TICK_TO_WAKE. */
    [...]
  };
```

#### Algorithm
On thread T invoking `timer_sleep (int64_t ticks)`:
1. turn off interrupts
2. acquire the current CPU `ticks`, assign it to a variable `start`
3. set `tick_to_wake` attribute of T to `start + ticks`,
4. blocks T,
5. insert T into `sleep_list` using `list_insert_ordered`,
6. resume to old interrupt level.

In ever invocation of `timer_interrupt ()`, we traverse `sleep_list`, so for
every thread T in the list
1. If T's `tick_to_wake` is smaller than CPU `ticks`, unblock T.
2. Otherwise break the traversal and return. This is because all the threads
in `sleep_list` are in ascending order with respect to `tick_to_wake`, so if
the current is greater than CPU `ticks`, then so is the after.


#### Synchronization 
- For `timer_sleep ()`, we disable interrupts at the beginning of function call,
then resume to the old level on exit.

- For `timer_interrupt ()`, because this it is an external interrupt, so
interrupts have already been disabled. There is not issue with Synchronization.

## Priority Scheduling
### Issue Elaboration
1. In the initial Pintos implementation, the scheduling algorithm is simply a
round-robin algorithm without  preemption. We want to enable a preemption to
the scheduling, that is, whenever a newly created thread T has highest priority
among all the threads (no matter for those on the ready list or the currently
running one), operating system yields the currently running thread and runs T 
instead.
2. Once preemption is enabled for the scheduling algorithm a new issue is lead
regarding synchronization resources like lock and semaphore. Imaging the
following situation: 
  - Suppose we have three threads with high, medium, and low priority
  respectively, named H, M and L.
  - At first L is created and acquire a lock.
  - Then, before L releases the lock, H, M are spawned, and H try to acquire
  the lock, we have a issue here:
    - Because H needs to wait for L, so it is unblocked.
    - But because L has the lowest priority, hence there would be a starvation 
    on L, since M currently has the highest priority, so both H and L needs to 
    wait for M exits.

To fix this issue, we can modifies the semaphore implementation into the
following (no need to change lock's implementation is because lock is
implemented based on semaphore):
1. Whenever a thread H with higher priority is trying to acquire a lock that is 
holding by a thread L with lower priority, H donates its priority to L by 
setting L's priority to the same level.
2. When L releases the lock, resume to its original priority.

You may find usefulness in this diagram
```
priority 
 ^
 |
 |                               H
 |                    ---*------------------#---
 |
 |                               M
 |                ---------------------------
 |
 |              L
 |  ---*---------------------------#-
 |
-+---------------------------------------------------------------------------->
 |                                                                       time
```

#### Solution
I didn't do this part.
