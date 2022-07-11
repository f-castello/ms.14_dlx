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

# Integration tracking
Refer to the table below to record the general progress of this project (note that _WIP_ = work-in-progress, whereas a blank cell indicates that the corresponding step is not _DONE_ and nobody has started working on it yet, and finally _N/A_ means that the required step is not available or not required in this context):
| COMPONENT      | VHDL | _TB_ |  SIM | SYNTH |
|----------------|:----:|:----:|:----:|:-----:|
| `alu`          | DONE | DONE | DONE |  WIP  |
| `cond_branch`  | DONE | DONE | DONE |  WIP  |
| `cpsr`         | DONE | DONE | DONE |  WIP  |
| `CU_HW`        | DONE | DONE | DONE |  WIP  |
| `DLX`          | DONE |  WIP |  WIP |  WIP  |
| `DP`           | DONE |  N/A |  WIP |  WIP  |
| `EXE`          | DONE | DONE | DONE |  WIP  |
| `gen_mux_21`   | DONE | DONE | DONE |  WIP  |
| `gen_mux_41`   | DONE | DONE | DONE |  WIP  |
| `gen_reg`      | DONE | DONE | DONE |  WIP  |
| `ID`           | DONE | DONE | DONE |  WIP  |
| `IF`           | DONE | DONE | DONE |  WIP  |
| `MEM`          | DONE | DONE | DONE |  WIP  |
| `pc_add`       | DONE | DONE | DONE |  WIP  |
| `reg_file`     | DONE | DONE | DONE |  WIP  |
| `ROMEM`        | DONE | DONE | DONE |  N/A  |
| `RWMEM`        | DONE | DONE | DONE |  N/A  |
| `sign_ext_alt` | DONE | DONE | DONE |  WIP  |
| `sign_ext`     | DONE | DONE | DONE |  WIP  |
| `WB`           | DONE | DONE | DONE |  WIP  |
| `zero_check`   | DONE | DONE | DONE |  WIP  |
