# Bitcask
## Required data structures
A Bitcask instance is a directory
```
                  Bitcask
+-----------------------------------------+
|                                         |
|     +----------------------------+      |
|     |  active   file 1           |      |
|     +----------------------------+      |
|     |   old     file 2           |      |
|     +----------------------------+      |
|     |   old     file 3           |      |
|     +----------------------------+      |
|     |   old     file 4           |      |
|     +----------------------------+      |
|                                         |
+-----------------------------------------+
```
Each KV entry has the following fields:
- CRC (cyclic redundancy code) checksum
- timestamps
- key size
- value size
- key 
- value

A *keydir* is  is a has table that maps every key in a Bitcask to a fixed-sized structure giving the file, offset, and size of the most recently written entry for that key.

- A file is *active* if it is written by a writer.
- When a file is closed, it is immutable and will never be opened again.
- Active file is only written by appending (no disk seeking).

## Read, Write and Merge
On writing:
- keydir is atomically updated with the location of the newest data. Old data of the written file is still on on disk.

On reading:
- Look up the key in keydir
- read the data using the `file_id`, `position`, and `size` that is returned by the lookup

We spawn a process to *merge* the new data in keydir into the old data in disk. On merging
1. merge process iterates over all non-active files and produces as output a set of data files containing only the latest version of each present key.
2. create a table *hint file* next to each data file, where each entry contains
  - time stamp
  - key size
  - value size
  - value position 
  - key
3. When Bitcask is opted by an 


