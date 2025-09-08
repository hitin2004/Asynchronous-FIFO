# Asynchronous FIFO (Verilog)

## Overview
This project implements an **8×8 Asynchronous FIFO** in Verilog. The FIFO allows data transfer between two independent clock domains by using Gray-coded pointers and synchronization registers.

The design ensures safe and reliable data movement across clock boundaries while providing **Full** and **Empty** status flags. A testbench is included to verify correct behavior under asynchronous write and read clocks.

## Features
- 8-bit wide, 8-entry deep FIFO  
- Independent write clock and read clock domains  
- Safe clock-domain crossing with two-stage synchronizers  
- Gray code pointer scheme to prevent metastability  
- Full and Empty flag generation  

## Design Details
- **Write Logic:**  
  Data is written to the FIFO when `write_en` is high and the FIFO is not full.  
  The write pointer is updated in binary and converted to Gray code for synchronization.  

- **Read Logic:**  
  Data is read from the FIFO when `read_en` is high and the FIFO is not empty.  
  The read pointer is updated in binary and also converted to Gray code.  

- **Pointer Synchronization:**  
  - Write pointer is synchronized into the read clock domain.  
  - Read pointer is synchronized into the write clock domain.  

- **Full Condition:**  
  Occurs when the write pointer is about to wrap around and overlap with the read pointer.  

- **Empty Condition:**  
  Occurs when both pointers are equal.  
