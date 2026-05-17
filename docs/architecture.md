# CAN Controller Architecture

## 1. Purpose and Scope

This project implements a modular CAN controller in VHDL for FPGA-based systems.
The initial goal of version 1 (v1) is not to build a complete production-ready CAN IP core, but to demonstrate and verify the most important protocol mechanisms of Classical CAN in a clean and reusable architecture.

The main focus of v1 is on:
- Bit-wise arbitration
- CRC generation and checking
- Bit timing and synchronization
- Basic frame transmission and reception
- A modular architecture suitable for simulation-driven development

The design is intended for educational and research purposes, especially in the context of automotive communication systems and AUTOSAR-related concepts.

## 2. Design Goals

The architecture is designed with the following goals:

- **Modularity**: Separate protocol functions into independent and testable VHDL blocks.
- **Traceability**: Keep protocol decisions visible and understandable during simulation.
- **Reusability**: Allow extension towards CAN 2.0B, CAN FD, filtering, register interfaces, or embedded CPU integration.
- **Verification-first development**: Enable unit-level and integration-level testbenches from the beginning.
- **Didactic clarity**: Prioritize architectural clarity over feature completeness in v1.

## 3. System Overview

A CAN node does not rely on a global shared clock on the bus.
Instead, each node uses its own local clock and synchronizes itself to bus edges by using time quanta, sampling points, and resynchronization rules.
Therefore, timing logic must be treated as a first-class architectural block and not as a hidden implementation detail. [web:95][web:111]

At a high level, the controller consists of:
- A Bit Timing Logic block
- A Bit Stream / Protocol Engine
- Dedicated Arbitration logic
- Dedicated CRC logic
- Error management logic
- A simple top-level integration layer

The architecture is intentionally organized so that protocol control and timing control are separated.

## 4. Top-Level Block Diagram

```text
                +----------------------------------+
                |          can_controller_top      |
                |                                  |
                |  +----------------------------+  |
System Clock -->|  |       can_btl              |  |
Reset --------->|  |  Bit Timing Logic          |  |
bus_rx -------->|  +-------------+--------------+  |
                |                |                 |
                |                v                 |
                |  +----------------------------+  |
                |  |       can_bsp              |  |
                |  |  Bit Stream Processor      |  |
                |  |  / Protocol Engine         |  |
                |  +------+------+------+-------+  |
                |         |      |      |          |
                |         |      |      |          |
                |         v      v      v          |
                |  +--------+ +------+ +---------+ |
                |  | arb    | | crc  | | error   | |
                |  | unit   | | unit | | mgmt    | |
                |  +--------+ +------+ +---------+ |
                |                                  |
                +----------------+-----------------+
                                 |
                                 v
                               bus_tx
```

## 5. Architectural Decomposition

### 5.1 `can_controller_top`

This is the integration layer of the controller.
It instantiates all functional submodules and routes timing, control, transmit, receive, and status signals between them.

Responsibilities:
- Instantiate all submodules
- Connect internal control and status signals
- Provide a simplified external node interface
- Expose key debug and verification signals if needed

This block should remain structurally simple.
Protocol intelligence should not be hidden here.

### 5.2 `can_btl` – Bit Timing Logic

The Bit Timing Logic (BTL) defines when the bus is sampled and when a transmitted bit is shifted out.
This block models the local clock-driven time base of the CAN node.

Responsibilities:
- Generate time quanta
- Define bit timing segments
- Generate sample point timing
- Generate transmit update timing
- Detect synchronization edges
- Perform hard synchronization and resynchronization
- Support a configurable Synchronization Jump Width (SJW)

Typical outputs:
- `tq_tick`
- `sample_now`
- `shift_now`
- `sync_event`
- `resync_event`

This module is one of the most important architectural blocks because CAN communication depends on distributed local timing rather than on a shared network clock. [web:95][web:111]

### 5.3 `can_bsp` – Bit Stream Processor / Protocol Engine

The Bit Stream Processor is the protocol control core.
It coordinates frame progression and decides which protocol field is currently active.

Responsibilities:
- Detect bus idle and Start of Frame (SOF)
- Sequence through frame fields
- Control transmitter and receiver data flow
- Enable arbitration checking during the arbitration field
- Enable CRC accumulation during relevant frame fields
- Control ACK and End of Frame handling
- Trigger error handling when protocol violations are reported

Typical internal states:
- `IDLE`
- `SOF`
- `ARBITRATION`
- `CONTROL`
- `DATA`
- `CRC`
- `CRC_DELIM`
- `ACK`
- `ACK_DELIM`
- `EOF`
- `INTERMISSION`
- `ERROR`

This block should act as the protocol orchestrator, not as a monolithic implementation of every protocol detail.

### 5.4 `can_arbitration`

This unit handles bit-wise arbitration.
CAN arbitration is non-destructive and based on the fact that a dominant bit (`0`) overwrites a recessive bit (`1`) on the bus. [web:103][web:110][web:114]

Responsibilities:
- Compare transmitted bit with observed bus bit
- Detect arbitration loss if the node transmits recessive and observes dominant
- Inform the protocol engine when transmission must stop
- Hand over cleanly from transmitter mode to receiver mode after arbitration loss

Typical inputs:
- `tx_bit`
- `bus_sample`
- `arb_enable`

Typical outputs:
- `arb_lost`
- `arb_active`

The arbitration unit is active only during the arbitration field.
Outside that field, a mismatch has a different meaning and may indicate a bit error instead of arbitration loss.

### 5.5 `can_crc`

This unit performs CRC generation and checking for Classical CAN.
Classical CAN uses a 15-bit CRC polynomial:
\[
G(x) = x^{15} + x^{14} + x^{10} + x^8 + x^7 + x^4 + x^3 + 1
\]
The CRC field is derived from the relevant destuffed frame content before transmission and is checked again during reception. [web:48][web:108][web:113]

Responsibilities:
- Serial CRC accumulation over the relevant frame bits
- Separate TX and RX usage modes, or internally controlled direction handling
- CRC comparison on received frames
- Report CRC validity to the protocol engine

Typical inputs:
- `crc_enable`
- `data_bit`
- `crc_reset`
- `crc_mode`

Typical outputs:
- `crc_value`
- `crc_ok`
- `crc_error`

For v1, CRC handling is limited to Classical CAN.
CAN FD support is intentionally out of scope.

### 5.6 `can_error_mgmt`

This block centralizes error detection feedback and error state tracking.
Its purpose is to prevent error-related behavior from being spread across the entire design.

Responsibilities:
- Collect error indications from other blocks
- Classify error types where applicable
- Maintain transmit and receive error counters
- Report controller error status
- Support future extension towards error passive and bus-off behavior

Potential error sources:
- Bit error
- CRC error
- Form error
- ACK error
- Stuff error

For v1, this module may initially expose simple status signals even if full ISO-compliant fault confinement is not yet implemented.

## 6. Timing and Synchronization Concept

The CAN bus is asynchronous at the system level in the sense that nodes do not share a global communication clock.
Each node generates its own internal timing from a local oscillator and aligns itself to the observed bus edges. [web:95][web:111]

The architecture models this using:
- Time quanta as the smallest timing unit
- A configurable sample point
- Edge-based synchronization
- Resynchronization by shifting the bit timing within a bounded Synchronization Jump Width

This is architecturally important because:
- Arbitration depends on all transmitting nodes sampling the same logical bit at compatible times
- CRC is only meaningful if sender and receiver interpret the same bit boundaries
- Error handling depends on reliable bit interpretation

For v1, timing should be configurable but kept simple enough to remain simulation-friendly.

## 7. Arbitration Concept

The controller shall implement non-destructive bit-wise arbitration.
While transmitting the arbitration field, the node continuously compares the bit it intends to send with the actual bus level. [web:103][web:110]

Arbitration rule:
- If the node transmits dominant and sees dominant, it remains active
- If the node transmits recessive and sees recessive, it remains active
- If the node transmits recessive and sees dominant, it loses arbitration immediately
- After arbitration loss, the node stops transmitting and continues as a receiver

This mechanism ensures that the frame with the numerically lowest identifier wins access to the bus without destroying the winning transmission. [web:103][web:106]

Architectural consequence:
- Arbitration must be implemented as a dedicated check path
- Arbitration must only be active during the arbitration field
- Arbitration loss must be cleanly handed back to the protocol engine

## 8. CRC Concept

CRC provides frame-level error detection.
In Classical CAN, CRC-15 is used for payload lengths up to 8 bytes. [web:48]

The architecture uses a dedicated CRC block rather than embedding CRC logic directly into the transmitter or receiver FSM.
This separation improves:
- Unit-level verification
- Future migration towards CAN FD CRC schemes
- Readability of the protocol engine

For v1:
- CRC accumulation is performed serially
- CRC is reset at frame start
- CRC is updated only over the relevant frame bits
- CRC check result is provided to the protocol engine and error management

## 9. Error Handling Concept

Error handling is architecturally separated from normal protocol sequencing.
This allows the protocol engine to focus on legal frame progression while the error management block evaluates failure conditions.

In v1, the following error classes should be considered:
- Arbitration loss during arbitration field
- CRC mismatch on receive path
- Bit monitoring mismatch outside valid arbitration conditions
- Form errors in fixed-format fields
- ACK-related failures

A minimal first implementation may only flag errors and count them.
A more complete later implementation may introduce:
- Error active / error passive states
- Bus-off entry and recovery
- Error frame generation

## 10. External Interfaces

The exact top-level interface may evolve, but v1 should expose a simple node-oriented interface instead of a full CPU register map.

Suggested external inputs:
- `clk`
- `rst`
- `bus_rx`
- `tx_start`
- `tx_identifier`
- `tx_dlc`
- `tx_data`

Suggested external outputs:
- `bus_tx`
- `rx_valid`
- `rx_identifier`
- `rx_dlc`
- `rx_data`
- `tx_busy`
- `arb_lost`
- `crc_error`
- `error_flag`

This keeps the initial implementation focused on protocol behavior rather than software integration.

## 11. v1 Limitations

Version 1 intentionally excludes several features in order to keep the architecture focused and verifiable.

Out of scope for v1:
- CAN FD
- Extended identifier support, if not explicitly added later
- Acceptance filtering
- Full host register file
- DMA or interrupt controller integration
- Complete ISO fault confinement behavior
- Physical transceiver implementation details

These limitations are intentional and support a verification-first development strategy.

## 12. Development Strategy

The recommended implementation order is:

1. Define packages, constants, and shared types
2. Implement `can_crc`
3. Implement `can_arbitration`
4. Implement `can_btl`
5. Implement `can_bsp`
6. Implement `can_error_mgmt`
7. Integrate in `can_controller_top`
8. Build unit and integration testbenches

This order prioritizes the protocol mechanisms that are most critical to the educational and architectural goals of the project.

## 13. Summary of Key Architectural Principles

The controller architecture follows these core principles:

- Timing is a dedicated architectural concern
- Arbitration is a dedicated protocol check path
- CRC is implemented as a reusable and isolated functional unit
- The protocol engine coordinates, but does not absorb, all functionality
- Verification is treated as part of the architecture from the beginning

This structure provides a clear path from an educational v1 controller towards a more capable automotive communication IP core.