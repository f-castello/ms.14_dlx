quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.core/a.c.d.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.vhd
vcom -reportprogress 300 -work work ../TB_MEM.vhd
vsim -voptargs=+acc -t ps work.tb_mem
add wave -position insertpoint sim:/tb_mem/*
run 120 ns
