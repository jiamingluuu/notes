# Virtualization 
VMM (Virtual Machine Monitor):
- A thing layer of software that wirtualizes the hardware
  - Exports a virtual machine abstraction that looks like the hardware.
  - Provides the illusion that software has full control over the hardware.
- Enable multiple OSes simultaneously on the same physical machine.

Requirements of VMM: 
- **Fidelity**: OSes and applications work the same without modification.
- **Isolation**: VMM protects resources and VMs from each other.
- **Performance**: VMM is another layer of software, so the side effects of 
running such software needs to be minimized.

VMM normally performs virtualization on the followings:
- CPU
- Events (hardware and software interrupts)
- Memory
- I/O device
But notice that although VMM performs the same functionality of OS, but it 
implements different hardware interface vs OS interface.

## Approaches of Implementing VMM
### Complete Machine Simulation
This approach builds a simulation of all the hardware, where
- CPU: a loop that fetches each instruction, decodes it, simulates its effects 
on the machine state.
- Memory: physical memory is an array of bytes, we can simulates the MMU on all
on all memory access.
- I/O: simulate I/O devices, programmed I/O, DMA, interrupts.

Tradeoff:
- it works, but slow

### Virtualize the CPM/MMU
This approach give instructions to CPU to execute.
- Run virtual machine's OS directly on CPU in unprivileged user mode.
- Privileged instructions trap into monitor and run simulator on instruction.

To virtualize interrupts:
- use virtual interrupt handler table of the running OS.

To virtualize memory, we have two ways:
1. direct mapping:
  - VMM uses the page tables that a guest OS creates
  - VMM validates all updates to page table by guest OS 
    - OS can read page tables without modification 
    - but VMM needs to check all page table entry writes to ensure that 
    virtual-to-physical mapping is valid.
2. indirect mapping:
  - 
