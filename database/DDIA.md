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
    - NOTE: A *fault* is defined as one component of the system deviating from 
        its spec, where as *failure* is when the system as a whole stops 
        providing the required service to the user.
    - Faults can be classified to:
        - Hardware fault, e.g. hard disk crash, faulty RAM, blackout power 
            gride, unplugged network cable.
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
        - Response time: The tie between a client sending a request and 
            receiving the response.
            - NOTE: *Latency* characterizes the actual time of handling the 
                request, which is measured at the backend, whereas response 
                time normally counts the time spent for the entire 
                request/response cycle.
    - To cope with load, we can either:
        - *Scaling up*: Developing more powerful machines.
        - *Scaling down*: Distributing the load across multiple smaller machines.
        - There is no one-size-fits -all scalable architecture.
        - *Stateless service*: Each service is handled independent from the state of local host.

#### Maintainability 
Fixing bugs, keeping its systems operational, investigating failures...

Design principles for software systems:
- *Operability*: Easy for teams to keep the system running smoothly.
- *Simplicity*: Easy for new engineers to understand the system.
- *Evolvability*: Easy for engineers to make change in the future.

## 2. Data Models and Query Languages
### Relational Model vs. Document Model
#### Relational Model
For instance, SQL, organizes data into *relations* (an unordered collection of tuples).
- Pros: 
    - Hides implementation detail behind a cleaner interface.
    - Generalizable, fits the diverse use cases.
- Cons: 
    - *Impedance mismatch*: Awkward translation layer is required between the objects in the application code and the database model of tables, rows, and columns. 

NoSQL
    - Pros: Easy to achieve greater scalability, open source, can handle queries that are not well supported in relational model.
    - Cons: Does not support ACID transactions across multiple document.

#### Document Model
- Data structure like a resume, a self-contained document.
- Normally stored as JSON and XML.
- Pros:
    - JSON has better *locality* than the multi-table schema used in relational model. While fetching data, we do not need to perform multiple queries or/and join subordinate tables.
    - We can explicitly write down a one-to-many relationships.
- Cons:
    - However, it is hard to perform *normalization* (the removal of duplication) where many-to-one relation is required. Particularly, `JOIN` operation in document model is slow.
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
*Index* is an additional structure, that is derived from the primary data, which develops an efficient way of key lookup.

### Hash Indexes