quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.core/a.c.e.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.core/a.c.e.b-gen_mux41.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.vhd
vcom -reportprogress 300 -work work ../TB_WB.vhd
vsim work.tb_wb
add wave *
run 24 ns
