_CAP Theorem_ states that a distributed data store can only provides two of the three guarantees:
- _Consistency_: Every read receives the most recent write of or an error.
- _Availability_: Every request received by a non-failing node in the system must result in a response.
- _Partition Tolerance_: The system continues to operate despite an arbitrary number of messages being dropped (or delayed) by the network between nodes.

Since network partition is not something we can control in practice, CAP Theorem usually is re-stated as _choose between data consistency and node availability_ when partition occurs. That is:
- if we choose data consistency, then some nodes cannot process requests while they are disconnected from the cluster: they must wait until the network problem is fixed, or return an error.
- if we choose availability, then it can be written in a way that each node scan process requests independently, even if it is disconnected from other nodes.

An extended version of CAP Theorem is _PACLEC Theorem_, which is stating that:
- when a network partition (P) occurs, one has to choose between availability (A) and consistency (C),
- but else (E), even when the system is running normally in the absence of partition, one has to choose between latency (L) and loss of consistency (C).