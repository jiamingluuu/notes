# Part I. Foundations of Data Systems
## 1. Reliable, Scalable, and Maintainable Applications
*Data-intensive*, on the contrary of compute-intensive, application is mainly 
responsible for:
- store data (database)
- remember result of expensive operations (cache)
- allow users to search data by keywords and filter data (search indexes)
- send a message (async) to another process (stream processing)
- periodically crunch a large amount of accumulated data (batch processing)

### Metrics of distributed systems
#### Reliability
The system continue to work correctly even in the face of adversity.
- NOTE: A *fault* is defined as one component of the system deviating from its
  spec, where as *failure* is when the system as a whole stops providing the
  required service to the user.
- Faults can be classified to:
  - Hardware fault, e.g. hard disk crash, faulty RAM, blackout power grid,
    unplugged network cable.
  - Software fault, e.g. systematic error, software bug, running process
    running up shared resources.
  - Human errors.

#### Scalability
The system's ability to cope with increased load.
- *Load* can be describe in various way:
  - Request per second (web server)
  - Ratio of reads to writes (database)
  - The number of simultaneously active users in a chat room.
- *Performance* can be characterized by
  - Throughput: The number of records we can process per second.
  - Response time: The tie between a client sending a request and receiving
  the response.
    - NOTE: *Latency* characterizes the actual time of handling the request,
    which is measured at the backend, whereas response time normally counts
    the time spent for the entire request/response cycle.
- To cope with load, we can either:
  - *Scaling up*: Developing more powerful machines.
  - *Scaling down*: Distributing the load across multiple smaller machines.
  - There is no one-size-fits -all scalable architecture.
  - *Stateless service*: Each service is handled independent from the state of 
  local host.

#### Maintainability 
Fixing bugs, keeping its systems operational, investigating failures...

Design principles for software systems:
- *Operability*: Easy for teams to keep the system running smoothly.
- *Simplicity*: Easy for new engineers to understand the system.
- *Evolvability*: Easy for engineers to make change in the future.

## 2. Data Models and Query Languages
### Relational Model vs. Document Model
#### Relational Model
For instance, SQL, organizes data into *relations* (an unordered collection of 
tuples).
- Pros: 
    - Hides implementation detail behind a cleaner interface.
    - Generalizable, fits the diverse use cases.
- Cons: 
    - *Impedance mismatch*: Awkward translation layer is required between the
    objects in the application code and the database model of tables, rows,
    and columns. 

NoSQL
- Pros: Easy to achieve greater scalability, open source, can handle
  queries that are not well supported in relational model.
- Cons: Does not support ACID transactions across multiple document.


#### Document Model
- Data structure like a resume, a self-contained document.
- Normally stored as JSON and XML.
- Pros:
  - JSON has better *locality* than the multi-table schema used in relational
  model. While fetching data, we do not need to perform multiple queries
  or/and join subordinate tables.
  - We can explicitly write down a one-to-many relationships.
- Cons:
  - However, it is hard to perform *normalization* (the removal of
  duplication) where many-to-one relation is required. Particularly,
  `JOIN` operation in document model is slow.
  - Cannot directly refer to a nested item within a document.
- MongoDB, RethinkDB, CouchDB.

#### Graph-Like Data Model
A good way of expressing many-to-many relationships.

A graph consists of:
- *Vertices* V (aka. nodes, entities), consists of 
  - A unique identifier.
  - A set of outgoing edges.
  - A set of incoming edges.
  - A collection of properties (kv pairs).
- *Edges* E (aka. relationships, arcs), consists of
  - A unique identifier.
  - The vertex at which the edge starts (tail vertex).
  - The vertex at which the edge ends (head vertex).
  - A label to describe the kind of relationship between the two vertices.
  - A collection of properties (kv pairs).
- Normally used for storing 
  - Social graphs, V = people, E = which people know each other.
  - The web graph, V = web pages, E = HTML links to other pages.
  - Road or rail networks, V = junctions, E = rods or railway lines.

## 3. Storage and Retrieval 
*Index* is an additional structure, that is derived from the primary data, 
which develops an efficient way of key lookup.
- Tradeoff: well-chosen indexes speed up read queries, but every index slows 
down writes.

### Hash Indexes
Keep an in-memory hash map where every key is mapped to a byte offset in the 
data file.

#### Bitcask
A log-structured storage engine that
- Stores key in RAM, values on disk.
- Break the log into segments of a certain size by closing a segment file when 
it reaches a certain size. Keys are mapped (using hash) to the file offset of 
each segment file.
  - On key lookup, we check the most recent segment, and if not present, check 
  the second-recent and so on.
  - *File formate*: Binary, encodes each record with the length of string, then 
  followed by the row data
  - *Deleting records*: Overwrite a *tombstone*
  - *Crash recovery*: Restore each segment's hash map by reading the entire 
  segment file, noting the offset of the most recent value for every key.
    - A snapshot of each segment's hash map is stored to speed up this process.
  - *Partially written records*: add checksum.
  - *Concurrency control*: Enforcing only one writer thread.
- Perform *compaction*, the removal of duplicate key, in a background thread.
- Suited to the situation where the value of each key is updated frequently.

Limitations:
- Hash table must fit in memory.
- Range queries are not efficient. Cannot easily scan over all keys between 
`kitty000` and `kitty999`.

### SSTables and LSM-Trees
Similar for bitcask having segment files, but with the an extra feature: 
- All the sequence of kv pairs is sorted by key.
- The following algorithm described also known as LSM-Tree (log-structured 
  merge-tree)

On merging two SSTable:
- Read input files side by side, and look at the first key in each file, copy 
  the key with smallest key to the result file.
- If two key are the same, copy the one from the most recent file.
- Fast on writing, but slow for seeking non-existing key (must iterate 
  through all segment and in memory map).

Key lookup:
- Store a sparse key-indexing in memory. 
  - In terms of sparse, it means we don't need to record the indexing of all 
  keys, instead, we can skip several keys.
- On finding a key, for instance `handiwork`, look for the offset for keys 
  `handbag` and `handsome`, then jump to `handbag` and scan from there.

Constructing and maintaining SSTables:
- Add the write query to a balanced tree called *memtable*
- When memtable is too large, write it out to the disk as an SSTable file.
- On read, first try to find in memtable, if absent, find on disk.
- Run a merge process if needed.

### B-Trees
Break the database down into fixed-size *blocks* or *pages*, 4KB each.
- One page is designated as the root of B-tree
- Each chile is responsible for a continuous range of keys.
- Leaf page stores each individual key, which either contains the value for each 
  key inline or contains references to the pages where the values can be found.
- *Branching factor* describes the number of references to child pages in one 
  page.
- Efficiency: n keys has O(log n) depth.

Key lookup: 
- Simply read from each page until reaches the leaf node.
- Similar for value update on existing key.

Insert
- When insert a non-existing key, 
  - Find the page whose rage encompasses the new key and add it to that page.
  - If there is no enough space for the page P, splits P into two half-full 
  pages to accommodate the new key.

If the program crashes in the middle of child split, index is corrupted, 
countermeasure like WAL (write-ahead log) is used.

And to perform concurrency control, *latches* (lightweight locks) is used.

### Tradeoff 
- LSM-tree is faster for writes, B-tree is faster for reads.
- B-tree need must write every piece of data at least twice: WAL, tree page, and 
sometime even the third time for split child.
- LSM-tree has high write throughput, partially because they have lower write 
amplification, and partially because they sequentially write compact SSTable 
files rather than having to overwrite several pages in the tree.