# Intro
Cloud is lots of storage with compute cycles nearby.
- a single-site cloud (aka datacenter) consists of 
  - compute nodes
  - switches, connecting the racks
  - a network  topology
  - storage nodes connected to the network
  - front-end for submitting jobs and receiving client requests
  - software services
- a geographically distributed cloud consists of
  - multiple such sites
  - each site possibly has different structure

# Clouds are distributed system 
distributed system is a collection of entities, each of which is autonomous,
programmable, asynchronous and failure-prone, and which communicate through an 
unreliable communication medium.

# Map reduce
- Map: parallelly process a large number of individual records to generate 
intermediate KV pairs.
- Reduce: takes in the output of map phase and merges all intermediate value 
associated per key.
  - each key assigned to one reduce 
  - parallelly processes and merges all intermediate values by partitioning keys
  - popular method: **hash partitioning**
    - each key is assigned to reduce server R such that
      ```R = hash(key) % number of reduce servers```

## MapReduce Scheduling
Jobs for user:
- write map and reduce program
- submit job; wait for result

Jobs for the paradigm and scheduler
- parallelize map
- transfer data from map to reduce
- parallelize reduce
- implement storage for map input, map output, reduce input and reduce output

Notice that reduce phase can start before map phase finishes.

Shuffle: transfer data from map output to reduce input.

In side MapReduce
- parallelize map is easy: each map task is independent
- partition the data and transfer map output to reduce input
- parallelize reduce is easy as data are disjoint so no race condition 
- implement storage for map input and output, reduce input and output
  - map input: distributed file system 
  - map output: local file system because these data are invisible and not 
  important for user, the data rw need to be fast
  - reduce input: from multiple remote disks; uses local file system 
  - reduce output: distributed file system

## The YARN Scheduler 
- YARN = Yet Another Resource Negotiator
- It has 3 main components
  1. global resource manager (RM), managing and allocating resources across the 
  entire cluster.
  2. per-server node manager (NM), managing resources (CPU, memory...) and 
  monitoring container execution.
  3. per-application application manager (AM), negotiating resources with the
  RM, tracking the application's progress, handling failures, coordinating the 
  execution of tasks on the NM

## Fault-Tolerance
For server failure:
- NM periodically sends heartbeat to RM 
  - if server fails, RM lets all affected AMs know, and AMs take action
- NM keeps track of each task running at its server
  - if task fails while in-progress, mark the task as idle and restart it.
- AM sends heartbeats to RM 
  - on failure, RM restarts AM, which then syncs up with its running tasks.

For RM failure:
- use old checkpoints and bring up the second RM 

### Slow Servers 
Slow nodes are call stragglers
- we keep track of progress of each task 
- perform backup (replicated) execution of straggler task: task considered 
done when first replica complete.

### Locality 


