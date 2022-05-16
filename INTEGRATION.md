Every task should only be marked as _complete_ after the corresponding step is **100% complete** and the associated file(s) no longer need changes [theoretically]. The required steps are:
1. **Implementation** = complete component writing & VHDL syntax checking
2. **Simulation** = testbench creation & error-free run
3. **Synthesis** = successful elaboration & design phase.

## Implementation
- [ ] `dlx_utils`
- [ ] `DLX`
  - [ ] `CU_HW`
  - [ ] `DP`
    - [ ] `IF`
      - [x] `gen_reg`
      - [x] `pc_add`
    - [ ] `ID`
      - [x] `gen_reg`
      - [x] `sign_ext`
      - [ ] `reg_file`
    - [ ] `EXE`
      - [x] `gen_reg`
      - [x] `gen_mux21`
      - [x] `zero_check`
      - [x] `branch_cond`
      - [ ] `alu`
    - [ ] `MEM`
      - [x] `gen_reg`
      - [x] `gen_mux21`
    - [ ] `WB`
      - [x] `gen_mux21`

## Simulation
- [ ] `dlx_utils`
- [ ] `DLX`
  - [ ] `CU_HW`
  - [ ] `DP`
    - [ ] `IF`
      - [x] `gen_reg`
      - [x] `pc_add`
    - [ ] `ID`
      - [x] `gen_reg`
      - [x] `sign_ext`
      - [ ] `reg_file`
    - [ ] `EXE`
      - [x] `gen_reg`
      - [x] `gen_mux21`
      - [x] `zero_check`
      - [x] `branch_cond`
      - [ ] `alu`
    - [ ] `MEM`
      - [x] `gen_reg`
      - [x] `gen_mux21`
    - [ ] `WB`
      - [x] `gen_mux21`
###### Testbenches
- [ ] `TB_alu`
- [x] `TB_branch_cond`
- [ ] `TB_CU_HW`
- [ ] `TB_DLX`
- [ ] `TB_DP`
- [ ] `TB_EXE`
- [x] `TB_gen_mux21`
- [x] `TB_gen_reg`
- [ ] `TB_ID`
- [ ] `TB_IF`
- [ ] `TB_MEM`
- [x] `TB_pc_add`
- [ ] `TB_reg_file`
- [x] `TB_sign_ext`
- [ ] `TB_WB`
- [x] `TB_zero_check`

## Synthesis
- [ ] `dlx_utils`
- [ ] `DLX`
  - [ ] `CU_HW`
  - [ ] `DP`
    - [ ] `IF`
      - [ ] `gen_reg`
      - [ ] `pc_add`
    - [ ] `ID`
      - [ ] `gen_reg`
      - [ ] `sign_ext`
      - [ ] `reg_file`
    - [ ] `EXE`
      - [ ] `gen_reg`
      - [ ] `gen_mux21`
      - [ ] `zero_check`
      - [ ] `branch_cond`
      - [ ] `alu`
    - [ ] `MEM`
      - [ ] `gen_reg`
      - [ ] `gen_mux21`
    - [ ] `WB`
      - [ ] `gen_mux21`
