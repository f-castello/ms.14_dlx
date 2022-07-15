quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.a-IF.core/a.c.a.a-gen_reg.vhd 
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.a-IF.core/a.c.a.b-pc_add.vhd 
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.a-IF.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.b-sign_ext.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.b-gen_mux21.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.c-reg_file.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.b-gen_mux21.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.c-zero_check.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.d-cond_branch.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.e-alu.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.f-cpsr.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.core/a.c.d.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.core/a.c.d.b-gen_mux21.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.core/a.c.e.a-gen_mux41.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.core/a.c.e.b-sign_ext_alt.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.vhd
vcom -reportprogress 300 -work work ../../a.b-CU_HW.vhd
vcom -reportprogress 300 -work work ../../a-DLX.vhd

vcom -reportprogress 300 -work work ../../memories/rwmem/rwmem.vhd
vcom -reportprogress 300 -work work ../../memories/romem/romem.vhd
vcom -reportprogress 300 -work work ../TB_DLX.vhd

vsim -voptargs=+acc work.tb_dlx
add wave *
add wave -position insertpoint  \
sim:/tb_dlx/DATA_MEM/DRAM_mem
add wave -position insertpoint  \
sim:/tb_dlx/INST_MEM/Memory
add wave -position insertpoint  \
sim:/tb_dlx/INST_MEM/idout
add wave -position insertpoint  \
sim:/tb_dlx/INST_MEM/DATA
add wave -position insertpoint  \
sim:/tb_dlx/DUT/DATAPATH/JUMP_EN
add wave -position insertpoint  \
sim:/tb_dlx/DUT/DATAPATH/EXECUTE/ALU_OUT_INT
add wave -position insertpoint  \
sim:/tb_dlx/DUT/DATAPATH/WRITE_BACK/MUX_OUT
add wave -position insertpoint  \
sim:/tb_dlx/DUT/DATAPATH/WRITE_BACK/SIGN_EXTEND/ctrl_in
add wave -position insertpoint  \
sim:/tb_dlx/DUT/CONTROL/BYTE_LEN
add wave -position insertpoint  \
sim:/tb_dlx/DUT/CONTROL/ZERO_PADDING5
add wave -position insertpoint  \
sim:/tb_dlx/DUT/DATAPATH/WRITE_BACK/SIGN_EXTEND/data_ext
add wave -position insertpoint  \
sim:/tb_dlx/DUT/DATAPATH/DECODE/RF/REGISTERS
add wave -position insertpoint  \
sim:/tb_dlx/DUT/DATAPATH/IF_LATCH_EN
add wave -position insertpoint  \
sim:/tb_dlx/DUT/DATAPATH/DEC_OUTREG_EN
add wave -position insertpoint  \
sim:/tb_dlx/DUT/DATAPATH/EXE_OUTREG_EN
add wave -position insertpoint  \
sim:/tb_dlx/DUT/DATAPATH/MEM_OUTREG_EN
run 150 ns
