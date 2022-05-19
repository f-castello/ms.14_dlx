# Server synchronization
The following commands are reported in a fragmented way, in order for them to be copied more easily. Any intermediate parameter (if present) is indicated by a bulleted list placed in the actual position inside the command itself. Separate multiple tokens with a _whitespace_ character.
###### From remote to local:
```
scp -r -P 10036 ms22.14@led-x3850-2.polito.it:/home/ms22.14/
```
- `#SRC_DIR#`: remote directory to **pull** from
- `#DEST_PATH#`: local path to copy into
###### From local to remote:
```
scp -r -P 10036
```
- `#SRC_DIR#`: local directory to **push**
```
ms22.14@led-x3850-2.polito.it:/home/ms22.14/
```
- `#DEST_PATH#`: remote path to send to
###### Working practices:
1. Do NOT create _any_ additional temporary directories or use _any_ arbitrary file naming other than what is described inside [the official guide](/Documentation/dlx_guide.pdf) for code versioning
2. Always keep the [GR14_DLX_pro](/GR14_DLX_pro) directory **clean** and well-structured
3. Every `.vhd` source file MUST be both **well commented** and **formatted** by using [this beautifier tool](https://marketplace.visualstudio.com/items?itemName=Vinrobot.vhdl-formatter) for VS Code before final submission.

# Project integration
Every task should only be marked as _complete_ only after the corresponding phase is 100% done (future project changes represent an exception to this rule). The required steps are:
1. [**Implementation**](https://github.com/f-castello/ms.14_dlx/blob/main/README.md#implementation) — complete component writing & VHDL syntax checking
2. [**Simulation**](https://github.com/f-castello/ms.14_dlx/blob/main/README.md#simulation) — [testbench](https://github.com/f-castello/ms.14_dlx/blob/main/README.md#testbenches) creation & error-free run
3. [**Synthesis**](https://github.com/f-castello/ms.14_dlx/blob/main/README.md#synthesis) — successful elaboration & design phase.

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
      - [x] `cpsr`
    - [ ] `MEM`
      - [x] `gen_reg`
      - [x] `gen_mux21`
    - [ ] `WB`
      - [x] `gen_mux41`

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
      - [x] `cpsr`
    - [ ] `MEM`
      - [x] `gen_reg`
      - [x] `gen_mux21`
    - [ ] `WB`
      - [x] `gen_mux41`
###### Testbenches
- [ ] `TB_alu`
- [x] `TB_branch_cond`
- [x] `TB_cpsr`
- [ ] `TB_CU_HW`
- [ ] `TB_DLX`
- [ ] `TB_DP`
- [ ] `TB_EXE`
- [x] `TB_gen_mux21`
- [x] `TB_gen_mux41`
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
      - [ ] `cpsr`
    - [ ] `MEM`
      - [ ] `gen_reg`
      - [ ] `gen_mux21`
    - [ ] `WB`
      - [ ] `gen_mux41`
