###################################################################

# Created by write_sdc on Wed Jul 13 19:02:22 2022

###################################################################
set sdc_version 1.9

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current mA
set_wire_load_model -name 5K_hvratio_1_4 -library NangateOpenCellLibrary
set_max_dynamic_power 4.2135 mW
create_clock [get_ports Clock]  -period 3  -waveform {0 1.5}
set_max_delay 3  -from [list [get_ports Clock] [get_ports ResetN] [get_ports {Instr_In[31]}]   \
[get_ports {Instr_In[30]}] [get_ports {Instr_In[29]}] [get_ports               \
{Instr_In[28]}] [get_ports {Instr_In[27]}] [get_ports {Instr_In[26]}]          \
[get_ports {Instr_In[25]}] [get_ports {Instr_In[24]}] [get_ports               \
{Instr_In[23]}] [get_ports {Instr_In[22]}] [get_ports {Instr_In[21]}]          \
[get_ports {Instr_In[20]}] [get_ports {Instr_In[19]}] [get_ports               \
{Instr_In[18]}] [get_ports {Instr_In[17]}] [get_ports {Instr_In[16]}]          \
[get_ports {Instr_In[15]}] [get_ports {Instr_In[14]}] [get_ports               \
{Instr_In[13]}] [get_ports {Instr_In[12]}] [get_ports {Instr_In[11]}]          \
[get_ports {Instr_In[10]}] [get_ports {Instr_In[9]}] [get_ports {Instr_In[8]}] \
[get_ports {Instr_In[7]}] [get_ports {Instr_In[6]}] [get_ports {Instr_In[5]}]  \
[get_ports {Instr_In[4]}] [get_ports {Instr_In[3]}] [get_ports {Instr_In[2]}]  \
[get_ports {Instr_In[1]}] [get_ports {Instr_In[0]}] [get_ports                 \
{DataMem_Read[31]}] [get_ports {DataMem_Read[30]}] [get_ports                  \
{DataMem_Read[29]}] [get_ports {DataMem_Read[28]}] [get_ports                  \
{DataMem_Read[27]}] [get_ports {DataMem_Read[26]}] [get_ports                  \
{DataMem_Read[25]}] [get_ports {DataMem_Read[24]}] [get_ports                  \
{DataMem_Read[23]}] [get_ports {DataMem_Read[22]}] [get_ports                  \
{DataMem_Read[21]}] [get_ports {DataMem_Read[20]}] [get_ports                  \
{DataMem_Read[19]}] [get_ports {DataMem_Read[18]}] [get_ports                  \
{DataMem_Read[17]}] [get_ports {DataMem_Read[16]}] [get_ports                  \
{DataMem_Read[15]}] [get_ports {DataMem_Read[14]}] [get_ports                  \
{DataMem_Read[13]}] [get_ports {DataMem_Read[12]}] [get_ports                  \
{DataMem_Read[11]}] [get_ports {DataMem_Read[10]}] [get_ports                  \
{DataMem_Read[9]}] [get_ports {DataMem_Read[8]}] [get_ports {DataMem_Read[7]}] \
[get_ports {DataMem_Read[6]}] [get_ports {DataMem_Read[5]}] [get_ports         \
{DataMem_Read[4]}] [get_ports {DataMem_Read[3]}] [get_ports {DataMem_Read[2]}] \
[get_ports {DataMem_Read[1]}] [get_ports {DataMem_Read[0]}]]  -to [list [get_ports {ProgCount_Out[31]}] [get_ports {ProgCount_Out[30]}]     \
[get_ports {ProgCount_Out[29]}] [get_ports {ProgCount_Out[28]}] [get_ports     \
{ProgCount_Out[27]}] [get_ports {ProgCount_Out[26]}] [get_ports                \
{ProgCount_Out[25]}] [get_ports {ProgCount_Out[24]}] [get_ports                \
{ProgCount_Out[23]}] [get_ports {ProgCount_Out[22]}] [get_ports                \
{ProgCount_Out[21]}] [get_ports {ProgCount_Out[20]}] [get_ports                \
{ProgCount_Out[19]}] [get_ports {ProgCount_Out[18]}] [get_ports                \
{ProgCount_Out[17]}] [get_ports {ProgCount_Out[16]}] [get_ports                \
{ProgCount_Out[15]}] [get_ports {ProgCount_Out[14]}] [get_ports                \
{ProgCount_Out[13]}] [get_ports {ProgCount_Out[12]}] [get_ports                \
{ProgCount_Out[11]}] [get_ports {ProgCount_Out[10]}] [get_ports                \
{ProgCount_Out[9]}] [get_ports {ProgCount_Out[8]}] [get_ports                  \
{ProgCount_Out[7]}] [get_ports {ProgCount_Out[6]}] [get_ports                  \
{ProgCount_Out[5]}] [get_ports {ProgCount_Out[4]}] [get_ports                  \
{ProgCount_Out[3]}] [get_ports {ProgCount_Out[2]}] [get_ports                  \
{ProgCount_Out[1]}] [get_ports {ProgCount_Out[0]}] [get_ports DataMem_WrEn]    \
[get_ports {DataMem_BLen[1]}] [get_ports {DataMem_BLen[0]}] [get_ports         \
{DataMem_Addr[31]}] [get_ports {DataMem_Addr[30]}] [get_ports                  \
{DataMem_Addr[29]}] [get_ports {DataMem_Addr[28]}] [get_ports                  \
{DataMem_Addr[27]}] [get_ports {DataMem_Addr[26]}] [get_ports                  \
{DataMem_Addr[25]}] [get_ports {DataMem_Addr[24]}] [get_ports                  \
{DataMem_Addr[23]}] [get_ports {DataMem_Addr[22]}] [get_ports                  \
{DataMem_Addr[21]}] [get_ports {DataMem_Addr[20]}] [get_ports                  \
{DataMem_Addr[19]}] [get_ports {DataMem_Addr[18]}] [get_ports                  \
{DataMem_Addr[17]}] [get_ports {DataMem_Addr[16]}] [get_ports                  \
{DataMem_Addr[15]}] [get_ports {DataMem_Addr[14]}] [get_ports                  \
{DataMem_Addr[13]}] [get_ports {DataMem_Addr[12]}] [get_ports                  \
{DataMem_Addr[11]}] [get_ports {DataMem_Addr[10]}] [get_ports                  \
{DataMem_Addr[9]}] [get_ports {DataMem_Addr[8]}] [get_ports {DataMem_Addr[7]}] \
[get_ports {DataMem_Addr[6]}] [get_ports {DataMem_Addr[5]}] [get_ports         \
{DataMem_Addr[4]}] [get_ports {DataMem_Addr[3]}] [get_ports {DataMem_Addr[2]}] \
[get_ports {DataMem_Addr[1]}] [get_ports {DataMem_Addr[0]}] [get_ports         \
{DataMem_Write[31]}] [get_ports {DataMem_Write[30]}] [get_ports                \
{DataMem_Write[29]}] [get_ports {DataMem_Write[28]}] [get_ports                \
{DataMem_Write[27]}] [get_ports {DataMem_Write[26]}] [get_ports                \
{DataMem_Write[25]}] [get_ports {DataMem_Write[24]}] [get_ports                \
{DataMem_Write[23]}] [get_ports {DataMem_Write[22]}] [get_ports                \
{DataMem_Write[21]}] [get_ports {DataMem_Write[20]}] [get_ports                \
{DataMem_Write[19]}] [get_ports {DataMem_Write[18]}] [get_ports                \
{DataMem_Write[17]}] [get_ports {DataMem_Write[16]}] [get_ports                \
{DataMem_Write[15]}] [get_ports {DataMem_Write[14]}] [get_ports                \
{DataMem_Write[13]}] [get_ports {DataMem_Write[12]}] [get_ports                \
{DataMem_Write[11]}] [get_ports {DataMem_Write[10]}] [get_ports                \
{DataMem_Write[9]}] [get_ports {DataMem_Write[8]}] [get_ports                  \
{DataMem_Write[7]}] [get_ports {DataMem_Write[6]}] [get_ports                  \
{DataMem_Write[5]}] [get_ports {DataMem_Write[4]}] [get_ports                  \
{DataMem_Write[3]}] [get_ports {DataMem_Write[2]}] [get_ports                  \
{DataMem_Write[1]}] [get_ports {DataMem_Write[0]}]]
