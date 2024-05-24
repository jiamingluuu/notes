# Database Storage
- Why we use buffer pool rather than rely on OS virtual memory and `mmap`
  syscall?
- If the DBMS is simply a read-only process, then we are fine. But problem 
  arises when there are multiple processes writing to the file:
  1. On transaction is modifying multiple pages, OS is possible to swap 
    out any pages at a given time. But this brought problem when 
    transaction abort/rollback.
  2. The whole DB process is blocked on page fault, which lower the 
    efficiency where it is possible to perform other queries on the page 
    fault.
  3. Hard for error handling: While trying to access corrupted memory,
    we receive a `SIGBUS` indicating bus error. So we need to re-implement 
    a signal handler for the DBMS.

The problem of database storage is managed into two categories:
1. How the DBMS represents the database in files on disk.
2. How the DBMS manages its memory and moves data back-and-forth from disk.

DBMS uses their own portable file format which OS does not know anything
about the contents of these files.

## Storage Manager 
The storage manager is
- Responsible for maintaining a database's files.
- Organizes the files as a collection of pages.
  - Each page is a fixed-size block of data.
    - The page size is varied as the DBMS changes (512B - 32KB).
  - Each page is given a unique identifier.

Different DBMSs manage pages in files on disk in different ways. 
Particularly, we are going use *heap file* in this course, which is a 
collection of pages with types that are stored in random order.
- Supported operations: Create/Get/Write/Delete Page
- Must support a way of iterating through the pages.

The DBMS maintains special pages that tracks the location of data pages in
the database files.
- A group of special pages, *page directory*, are maintained by the DBMS.
  It records metadata about available space:
  - The number of free slots per page.
  - List of free/empty pages.
- Must make sure that the directory pages are in sync with the data pages.

Every page contains a *header* of metadata about the page's content:
- page size
- checksum
- DBMS version
- transaction visibility
- etc...

### Tuple-Oriented Storage
For tuple-oriented storage, the most common layout scheme is called 
*slotted pages*:
- The slot array maps "slots" to the tuples' starting position offset.
- The tuple is a fixed-sized chunk of data that is written at the end
  of the file.
- The header keeps track of:
  - The number of used slots.
  - The offset of the starting location of the last slot used.

To identifies each tuple, we use the notion of *record ids*, where we give
each logical tuple a unique record identifier that represents its physical 
location in the database.
- File id, page id, slot number...
- Application should never rely on these IDs to mean anything.

When insert a new tuple:
- Check page directory to find a page with a free slot.
- Retrieve the page from disk.
- Check slot array to find empty space in page that will fit.

Update an existing tuple using its record id:
- Check page directory to find location of page.
- Retrieve the page from disk.
- Find offset in page using slot array.
- If new data fits, overwrite existing data, otherwise mark existing tuple as 
  deleted and insert a new version in a different page.

Problems with tuple-oriented storage:
- Fragmentation: Pages are not fully utilized.
- Useless Disk IO: DBMS must fetch the entire to update on tuple.
- Random Disk IO: Worse case scenario when updating multiple tuple is that 
  each tuple is on a separate page.

### Log-Structured Storage
As the application makes changes to the database, the DBMS appends log records
to the end of the file without checking previous log records.

Write and delete operation is simply appends the log with a key/value pair.
## Index-Organized Storage
## Data Representation
