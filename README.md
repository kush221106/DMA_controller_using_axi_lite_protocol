# DMA_controller_using_axi_lite_protocol
Project Description

This project implements a DMA controller using the AXI-Lite protocol for efficient data transfer between memory locations. The design supports data transfers for both aligned and non-aligned memory addresses.

The architecture of the DMA controller consists of three major components: a Read Module, FIFO buffer, and Write Module.

Read Module:
The read module is responsible for generating the source memory address and controlling the read operations. It fetches data from the source memory and forwards it to the FIFO buffer.

FIFO Buffer:
The FIFO acts as an intermediate buffer between the read and write modules. It temporarily stores the data read from the source memory and ensures smooth data flow between reading and writing operations. In this design, the FIFO reads data on the positive edge of the clock and provides data for writing on the negative edge, helping maintain synchronization and preventing timing conflicts.

Write Module:
The write module controls the writing of data into the destination memory. It retrieves data from the FIFO buffer, generates the destination address, and performs the memory write operation.
This project is completed with yash dubey for i-chip 24
