
# e-Yantra Verilog Track

A collection of Verilog HDL implementations and digital design projects completed as part of our participation in the e-Yantra 2024 competition in Maze Solver track.

The repository covers foundational digital logic, PWM generation, sensor interfacing, single-cycle RISC-V processor design and maze exploration.

## Repository Structure

### Task 0 — Digital Logic

Foundational digital design implementations using Verilog HDL.

- **AND_GATE** — AND gate implementation.
- **two_way_switch** — Two-way switching logic
- **ripple_carry_adder** — Ripple carry adder
- **sequence_detector** — Sequence detector
- **Seven_Segment_Display** — Seven-segment display control

### Task 1 — Peripheral Interfacing and Processor Design

#### T1A — Frequency Divider and PWM (`t1a_fs_pwm`)

Implementation of a frequency divider and pulse-width modulation (PWM) module.

#### T1B — Ultrasonic Sensor (`t1b_ultrasonic`)

Implementation of an interface for an ultrasonic distance sensor using the specified task requirements.

#### T1C — Single-Cycle RISC-V CPU (`t1c_riscv_cpu`)

Extended a provided single-cycle RISC-V processor design to support additional instructions.

Instruction groups covered:
- Load and store instructions
- R-type and I-type ALU operations
- All six conditional branch instructions
- JAL and JALR
- LUI and AUIPC

This task involved understanding the supplied processor modules and extending the datapath and control logic to support the required instruction set.

### Task 2 — Sensor Interfacing and Maze Exploration

#### T2A — DHT11 Sensor (`t2a_dht`)

Implementation of a DHT11 temperature and humidity sensor interface according to the specified task requirements.


#### T2B — UART (`t2b_uart`)

UART task organized according to the assigned specifications.

The implementation files for this task does not exist in this repository.

#### T2C — Maze Explorer (`t2c_maze_explorer`)

Implementation of a maze-solving approach using the **left-hand rule algorithm**.

The algorithm follows the left-hand wall-following strategy to navigate the maze based on the available movement and sensor information.

## Repository Contents

Each task folder contains the relevant source files and any associated supporting files available for that task.

## Contributors

- Goutham 
- Hari Krishna
- Jeevith 

## Acknowledgements

Created during our participation in the e-Yantra Robotics Competition 2024.

The repository documents our work and learning across digital logic design, processor implementation, peripheral interfacing and algorithmic problem-solving.
