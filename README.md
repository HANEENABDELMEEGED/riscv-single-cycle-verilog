# Single-Cycle RISC-V Processor in Verilog

This project implements a complete single-cycle RV64I RISC-V processor in Verilog.

## Features
- Supports R-type, I-type, Load, Store, and Branch instructions
- Modules: ALU, Register File, Control Unit, Instruction Memory, Data Memory, Immediate Generator, PC
- Testbench verification using Vivado XSim

## Tools
- Verilog
- Vivado Simulator (XSim)

## How to Run
1. Add all .v files to a Vivado project
2. Set tb_cpu_isa.v as top module
3. Run simulation

## CPU Design
<img width="2130" height="497" alt="cpu" src="https://github.com/user-attachments/assets/d0eacc79-212b-4d24-b809-3e3f25c09cc6" />


## Simulation Results
<img width="1840" height="993" alt="p1" src="https://github.com/user-attachments/assets/fcca6380-f64f-488a-af37-32f9925ef817" />
<img width="1360" height="757" alt="p2" src="https://github.com/user-attachments/assets/0173c406-65ed-4624-9c45-b53752e9ac31" />
<img width="1348" height="747" alt="p3" src="https://github.com/user-attachments/assets/dd110017-b172-4361-978c-2a47bcfe13c4" />




