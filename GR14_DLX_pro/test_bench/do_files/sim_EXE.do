quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.b-gen_mux21.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.c-zero_check.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.d-cond_branch.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.e-alu.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.f-cpsr.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.vhd
vcom -reportprogress 300 -work work ../TB_EXE.vhd
vsim work.tb_exe(test) -t 10ps
add wave -position insertpoint sim:/tb_exe/*
run 30 ns
