# CAN Controller in VHDL for FPGA

A modular CAN2.0B‑compatible controller implemented in **VHDL** for FPGA platforms.  
The core is designed to highlight **CAN arbitration**, **CRC calculation**, **bit‑timing**, and **synchronisation** mechanisms, making it suitable for:  
- Embedded / automotive systems education  
- AUTOSAR‑related communication concept studies  
- FPGA‑based automotive network prototyping  

## Key Features

- **Arbitration**: Bit‑by‑bit arbitration with ID‑based priority.
- **CRC**: CRC‑15‑based transmit and receive CRC logic.
- **Bit‑Timing**: Configurable bit‑time and sample‑point model.
- **Modular design**: Clear separation of bit‑timing, protocol, buffer, and register‑layer.
- **Multiple nodes**: Simulation of multi‑node CAN arbitration and frame exchange.

## Target Use

- Learning how CAN and AUTOSAR‑style communication works at the hardware level.
- Reusable FPGA IP core for virtual CAN channels in research or lab setups.
- Teaching material for embedded systems, FPGA, or automotive communication courses.
