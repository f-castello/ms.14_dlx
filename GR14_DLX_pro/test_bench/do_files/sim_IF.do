quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.a-IF.core/a.c.a.a-gen_reg.vhd 
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.a-IF.core/a.c.a.b-pc_add.vhd 
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.a-IF.vhd
vcom -reportprogress 300 -work work ../TB_IF.vhd
vsim -t 10ps work.tb_if
add wave *
add wave -position insertpoint  \
sim:/tb_if/IR_MEM_VALS
add wave -position insertpoint sim:/tb_if/DUT/*
run 100 ns