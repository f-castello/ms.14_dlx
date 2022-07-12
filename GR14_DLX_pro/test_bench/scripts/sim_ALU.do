quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.e-alu.vhd
vcom -reportprogress 300 -work work ../TB_alu.vhd
vsim -voptargs=+acc work.tb_alu
add wave *
run 74 ns
